import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musbx/music_player/demixer/demixer_api.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/music_player_component.dart';
import 'package:musbx/music_player/song.dart';
import 'package:musbx/widgets.dart';

final DemixerApi _api = DemixerApi();

class Stem {
  Stem(this.type) {
    player.volumeStream.listen((value) => volumeNotifier.value = value);
  }

  final StemType type;

  /// Whether this stem is enabled and should be played.
  set enabled(bool value) {
    if (value == false) player.pause();
    if (value == true &&
        MusicPlayer.instance.demixer.enabled &&
        MusicPlayer.instance.isPlaying) player.play();
    enabledNotifier.value = value;
  }

  bool get enabled => enabledNotifier.value;
  final ValueNotifier<bool> enabledNotifier = ValueNotifier(true);

  /// The volume this stem is played at. Must be between 0 and 1.
  set volume(double value) => player.setVolume(value.clamp(0, 1));
  double get volume => volumeNotifier.value;
  final ValueNotifier<double> volumeNotifier = ValueNotifier(1.0);

  final AndroidEqualizer equalizer = AndroidEqualizer();
  late final AudioPlayer player = AudioPlayer(
    audioPipeline: AudioPipeline(androidAudioEffects: [
      if (Platform.isAndroid) equalizer,
    ]),
  );

  /// Download and prepare [player] for playing this stem of [song].
  Future<void> loadStemFile(String song) async {
    File? file = await _api.downloadStem(song, type);
    if (file == null) return;
    await player.setAudioSource(AudioSource.file(file.path));
  }
}

class StemsNotifier extends ValueNotifier<List<Stem>> {
  StemsNotifier(super.value) {
    for (Stem stem in value) {
      stem.enabledNotifier.addListener(notifyListeners);
      stem.volumeNotifier.addListener(notifyListeners);
    }
  }
}

enum DemixerState {
  /// Loading hasn't started. E.g. the user hasn't selected a song yet.
  inactive,

  /// The song is being uploaded to the server.
  uploading,

  /// The server has begun separating the song into stems.
  separating,

  /// The stem files are being downloaded..
  downloading,

  /// The song has been separated and is ready to be played.
  done,

  /// Something went wrong while loading the song.
  error,
}

class Demixer extends MusicPlayerComponent {
  final Stem drums = Stem(StemType.drums);
  final Stem bass = Stem(StemType.bass);
  final Stem vocals = Stem(StemType.vocals);
  final Stem other = Stem(StemType.other);

  List<Stem> get stems => stemsNotifier.value;
  late final StemsNotifier stemsNotifier =
      StemsNotifier([drums, bass, vocals, other]);

  DemixerState get state => loadingStateNotifier.value;
  final ValueNotifier<DemixerState> loadingStateNotifier =
      ValueNotifier(DemixerState.inactive);

  /// Whether the Demixer is ready to play the current song.
  ///
  /// If `true`, the current song has been separated and mixed, and the Demixer is ready to use.
  bool get isReady => state == DemixerState.done;

  bool get isLoading => [
        DemixerState.uploading,
        DemixerState.separating,
        DemixerState.downloading,
      ].contains(state);

  /// The progress of the loading action.
  ///
  /// This is `null` if [state] is not [DemixerState.separating].
  int? get loadingProgress => loadingProgressNotifier.value;
  ValueNotifier<int?> loadingProgressNotifier = ValueNotifier(null);

  /// Separate, mix and load a [song] for [MusicPlayer] to play.
  Future<String?> separateSong(Song song) async {
    if (song.source != SongSource.youtube) {
      return null; // TODO: Implement separating files
    }

    loadingStateNotifier.value = DemixerState.uploading;

    UploadResponse response = await _api.uploadYoutubeSong(song.id);
    String songName = response.songName;

    if (response.jobId != null) {
      loadingStateNotifier.value = DemixerState.separating;
      var subscription = _api.jobProgress(response.jobId!).handleError((error) {
        print("ERROR: $error");
        if (error is! JobNotFoundException) throw error;
      }).listen((response) {
        loadingProgressNotifier.value = response.progress;
      }, cancelOnError: true);

      await subscription.asFuture();
      loadingProgressNotifier.value = null;
    }

    return songName;
  }

  @override
  void initialize(MusicPlayer musicPlayer) {
    musicPlayer.songNotifier.addListener(onNewSongLoaded);
    musicPlayer.isPlayingNotifier.addListener(onIsPlayingChanged);
    musicPlayer.positionNotifier.addListener(onPositionChanged);
    musicPlayer.player.speedStream.listen(onSpeedChanged);
    musicPlayer.player.pitchStream.listen(onPitchChanged);
    musicPlayer.equalizer.parametersNotifier.addListener(onEqualizerChanged);
    enabledNotifier.addListener(onEnabledToggle);

    musicPlayer.equalizer.enabledNotifier.addListener(() {
      // For now, disable when demixer is enabled since they don't work together.
      // TODO: Get the Demixer to work with the Equalizer.
      if (musicPlayer.equalizer.enabled) enabled = false;
    });
  }

  AudioSource? originalAudioSource;

  Future<void> onNewSongLoaded() async {
    MusicPlayer musicPlayer = MusicPlayer.instance;
    Song? song = musicPlayer.song;
    if (song == null) return;

    originalAudioSource = song.audioSource;

    try {
      String? songName = await separateSong(song);

      if (songName == null) return;

      loadingStateNotifier.value = DemixerState.downloading;

      for (Stem stem in stems) {
        await stem.loadStemFile(songName);
      }

      // Make sure all players have the same duration
      assert(stems.every(
          (stem) => stem.player.duration == stems.first.player.duration));
    } catch (error) {
      loadingStateNotifier.value = DemixerState.error;
      return;
    }

    // Trigger enable
    await onEnabledToggle();

    loadingStateNotifier.value = DemixerState.done;
  }

  void onIsPlayingChanged() {
    if (!isReady || !enabled) return;
    MusicPlayer musicPlayer = MusicPlayer.instance;

    for (Stem stem in stems) {
      if (musicPlayer.isPlaying) {
        if (stem.enabled) stem.player.play();
      } else {
        stem.player.pause();
      }
    }
  }

  void onPositionChanged() {
    if (!isReady || !enabled) return;
    MusicPlayer musicPlayer = MusicPlayer.instance;

    final Duration minAllowedPositionError = const Duration(milliseconds: 20) *
        (musicPlayer.slowdowner.enabled ? musicPlayer.slowdowner.speed : 1);

    for (Stem stem in stems) {
      if (stem.enabled &&
          (musicPlayer.position - stem.player.position).abs() >
              minAllowedPositionError) {
        print(
            "DEMIXER: Correcting position for stem ${stem.type.name}. Error: ${(musicPlayer.position - stem.player.position).abs().inMilliseconds}ms");
        stem.player.seek(musicPlayer.position);
      }
    }
  }

  void onSpeedChanged(double speed) {
    for (Stem stem in stems) {
      stem.player.setSpeed(speed);
    }
  }

  void onPitchChanged(double pitch) async {
    for (Stem stem in stems) {
      stem.player.setPitch(pitch);
    }
  }

  Future<void> onEqualizerChanged() async {
    // TODO: Get this to work. Currently, there is no trigger for when the Equalizer's parameters changes.
    var musicPlayerBands = MusicPlayer.instance.equalizer.parameters?.bands;
    if (musicPlayerBands == null) return;

    for (Stem stem in stems) {
      var bands = (await stem.equalizer.parameters).bands;
      for (int i = 0; i < bands.length; i++) {
        await bands[i].setGain(musicPlayerBands[i].gain);
      }
    }
  }

  Future<void> onEnabledToggle() async {
    MusicPlayer musicPlayer = MusicPlayer.instance;
    Song? song = musicPlayer.song;
    if (song == null) return;

    Duration position = musicPlayer.position;
    bool wasPlaying = musicPlayer.isPlaying;

    for (Stem stem in stems) {
      await stem.player.pause();
    }
    await musicPlayer.pause();

    if (enabled) {
      // Disable "normal" audio
      await musicPlayer.player.setAudioSource(
        SilenceAudioSource(duration: stems.first.player.duration!),
        initialPosition: position,
      );
    } else {
      // Restore "normal" audio
      if (originalAudioSource == null) return;
      await musicPlayer.player.setAudioSource(
        originalAudioSource!,
        initialPosition: position,
      );
    }
    await musicPlayer.seek(position);
    if (wasPlaying) musicPlayer.play();
  }

  /// Load settings from a [json] map.
  ///
  /// [json] can contain the following stems (beyond "enabled"):
  ///  - "drums"
  ///  - "bass"
  ///  - "vocals"
  ///  - "other"
  ///
  /// Each stem can contain the following key-value pairs:
  ///  - "enabled": [bool] Whether this stem is enabled and should be played.
  ///  - "volume": [double] The volume this stem is played back at. Must be between 0 and 1.
  @override
  void loadSettingsFromJson(Map<String, dynamic> json) {
    super.loadSettingsFromJson(json);

    for (Stem stem in stems) {
      Map<String, dynamic> stemData = json[stem.type.name];
      bool? enabled = tryCast<bool>(stemData["enabled"]);

      if (enabled != null) stem.enabled = enabled;
      double? volume = tryCast<double>(stemData["volume"]);
      if (volume != null) stem.volume = volume;
    }
  }

  /// Save settings for a song to a json map.
  ///
  /// Saves the following key-value pairs (beyond "enabled"):
  ///  - "pitchSemitones": [double] How much the pitch will be shifted, in semitones..
  ///  - "speed": [double] The playback speed of the audio, as a fraction.
  @override
  Map<String, dynamic> saveSettingsToJson() {
    return {
      ...super.saveSettingsToJson(),
      for (Stem stem in stems)
        stem.type.name: {
          "enabled": stem.enabled,
          "volume": stem.volume,
        }
    };
  }
}
