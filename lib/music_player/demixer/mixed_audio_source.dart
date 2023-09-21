import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musbx/music_player/demixer/demixer.dart';
import 'package:musbx/music_player/demixer/host.dart';
import 'package:musbx/music_player/demixer/stem.dart';
import 'package:musbx/music_player/music_player.dart';

class StemFileData {
  StemFileData({required this.stemType, required this.fileData});

  final StemType stemType;
  final List<int> fileData;
}

class MixedAudioSource extends StreamAudioSource {
  /// An [AudioSource] that mixes multiple .wav files.
  ///
  /// All [files] must have the same duration
  MixedAudioSource(this.files) : super(tag: 'MixedAudioSource');

  final Map<StemType, File> files;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    int sourceLength = await files.values.first.length();

    List<Stream<StemFileData>> readStreams = files.entries
        .map((entry) => entry.value
            .openRead(start, end)
            .map((data) => StemFileData(stemType: entry.key, fileData: data)))
        .toList();
    Stream<List<int>> mixed =
        StreamZip<StemFileData>(readStreams).map(mixWavFiles);

    return StreamAudioResponse(
      sourceLength: sourceLength,
      contentLength: (end ?? sourceLength) - (start ?? 0),
      offset: start ?? 0,
      stream: mixed,
      contentType: 'audio/wav',
    );
  }

  /// Mix multiple `wav` files together by taking the average value of each byte.
  ///
  /// 16 bits per sample and the files having identical headers is assumed.
  /// TODO: Check header for audio format (16, 32 bit...)
  List<int> mixWavFiles(List<StemFileData> dataLists) {
    Demixer demixer = MusicPlayer.instance.demixer;
    List<Stem> enabledStems =
        demixer.stems.where((stem) => stem.enabled).toList();

    // Try to detect wav header
    // This method isn't fool proof (might by accident be these bytes at the start of the audio sample...) but it works for now
    bool headerPresent = dataLists.every((stemFileData) =>
        listEquals(
          stemFileData.fileData.sublist(0, 4), [82, 73, 70, 70], // RIFF
        ) &&
        listEquals(stemFileData.fileData.sublist(8, 16),
            [87, 65, 86, 69, 102, 109, 116, 32] // WAVEfmt
            ));

    List<List<double>> listsToMix = [];
    for (Stem stem in enabledStems) {
      StemFileData stemFileData = dataLists
          .where((stemFileData) => stemFileData.stemType == stem.type)
          .first;

      List<int> data = headerPresent
          ? stemFileData.fileData.sublist(44) // Remove header
          : stemFileData.fileData;

      // Convert byte lists from 8 bit to 16 bit
      Uint16List uint16list = Uint8List.fromList(data).buffer.asUint16List();

      List<double> processedList = [
        for (var i = 0; i < uint16list.length; i++)
          // Shift all values to between `[-32768, 32767]`
          (fold(uint16list[i], 16) - 32768) * stem.volume // Apply volume
      ];
      listsToMix.add(processedList);
    }

    // Mix all byte lists into one
    List<int> mixed = [
      for (int i = 0; i < listsToMix.first.length; i++)
        (listsToMix.fold(0.0, (sum, list) => sum + list[i]) / 4).round()
    ];

    // Shift all values back to between `[0, 65536]`
    List<int> unshifted = [
      for (var i = 0; i < mixed.length; i++) (fold(mixed[i], 16) + 32768)
    ];

    // Convert back to 8 bit
    Uint8List uint8list = Uint16List.fromList(unshifted).buffer.asUint8List();

    if (headerPresent) {
      // Return header and then data
      return dataLists.first.fileData.sublist(0, 44) + uint8list;
    }

    return uint8list;
  }
}

/// Shifts int [x] of bit width [bits] up by half the total range, then wraps
/// any overflowing values around to maintain the bit width. This is used to
/// convert between signed and unsigned PCM.
int fold(int x, int bits) => (x + (1 << (bits - 1))) % (1 << bits);
