import 'package:flutter/material.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/music_player_component.dart';

/// A component for [MusicPlayer] that is used to loop a section of a song.
class Looper extends MusicPlayerComponent {
  /// The section being looped.
  LoopSection get section => sectionNotifier.value;
  set section(LoopSection section) => sectionNotifier.value = section;
  final ValueNotifier<LoopSection> sectionNotifier =
      ValueNotifier(LoopSection());

  @override
  void initialize(MusicPlayer musicPlayer) {
    // When loopSection changes, trigger ssek
    sectionNotifier.addListener(() async {
      if (!enabled) return;
      if (musicPlayer.position < section.start ||
          musicPlayer.position > section.end) {
        await musicPlayer.seek(musicPlayer.position);
      }
    });

    // When loopEnabled changes, trigger seek
    enabledNotifier.addListener(() async {
      if (musicPlayer.position < section.start ||
          musicPlayer.position > section.end) {
        await musicPlayer.seek(musicPlayer.position);
      }
    });
  }

  /// Clamp [position] to between [section.start] and [section.end], or between 0 and [duration] if this component is not [enabled].
  Duration clampPosition(Duration position, {required Duration duration}) {
    return Duration(
      milliseconds: position.inMilliseconds.clamp(
        (enabled) ? section.start.inMilliseconds : 0,
        (enabled) ? section.end.inMilliseconds : duration.inMilliseconds,
      ),
    );
  }

  /// Load settings from a [json] map.
  ///
  /// [json] can contain the following key-value pairs (beyond "enabled"):
  ///   "start": [int] The start position of the section being looped, in milliseconds.
  ///   "end": [int] The end position of the section being looped, in milliseconds.
  @override
  void loadSettingsFromJson(Map<String, dynamic> json) {
    super.loadSettingsFromJson(json);

    section = LoopSection(
      start: Duration(milliseconds: (json["start"] as int?) ?? 0),
      end: Duration(milliseconds: (json["end"] as int?) ?? 0),
    );
  }
}

/// Representation of a sect by [Looper] to select what section of the song to loop.
class LoopSection {
  LoopSection({
    this.start = Duration.zero,
    this.end = const Duration(seconds: 1),
  }) {
    assert(start <= end);
  }

  final Duration start;
  final Duration end;

  /// Duration between [start] and [end].
  Duration get length => end - start;

  @override
  bool operator ==(Object other) =>
      other is LoopSection && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
