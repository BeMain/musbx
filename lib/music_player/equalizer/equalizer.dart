import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/music_player_component.dart';

class Equalizer extends MusicPlayerComponent {
  /// The [AndroidEqualizer] used internally to adjust the gain for different frequency bands.
  final AndroidEqualizer androidEqualizer = AndroidEqualizer();

  /// The parameters of this equalizer, or null if no song has been loaded.
  AndroidEqualizerParameters? get parameters => parametersNotifier.value;
  final ValueNotifier<AndroidEqualizerParameters?> parametersNotifier =
      ValueNotifier(null);

  /// Reset the gain on all bands in [parameters].
  ///
  /// If [parameters] is null, does nothing.
  void resetGain() {
    if (parameters == null) return;

    for (var band in parameters!.bands) {
      band.setGain((parameters!.maxDecibels + parameters!.minDecibels) / 2);
    }
  }

  @override
  void initialize(MusicPlayer musicPlayer) {
    enabled = false;
    enabledNotifier.addListener(() {
      androidEqualizer.setEnabled(enabled);
    });

    androidEqualizer.parameters.then(
      (value) {
        parametersNotifier.value = value;
        resetGain();
      },
    );
  }
}