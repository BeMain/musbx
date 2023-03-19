import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/music_player_component.dart';

/// A component for [MusicPlayer] that is used to change the gain on specific frequencies.
class EqualizerComponent extends MusicPlayerComponent {
  /// The [Equalizer] used internally to adjust the gain for different frequency bands.
  final Equalizer androidEqualizer = Equalizer(
    darwinMessageParameters: DarwinEqualizerParametersMessage(
      minDecibels: -19,
      maxDecibels: 19,
      bands: [
        DarwinEqualizerBandMessage(index: 0, centerFrequency: 750, gain: 0.0),
        DarwinEqualizerBandMessage(index: 1, centerFrequency: 2875, gain: 0.0),
        DarwinEqualizerBandMessage(index: 2, centerFrequency: 11375, gain: 0.0),
        DarwinEqualizerBandMessage(index: 3, centerFrequency: 45000, gain: 0.0),
        DarwinEqualizerBandMessage(
            index: 4, centerFrequency: 175000, gain: 0.0),
      ],
    ),
  );

  /// The parameters of this equalizer, or null if no song has been loaded.
  EqualizerParameters? get parameters => parametersNotifier.value;
  final ValueNotifier<EqualizerParameters?> parametersNotifier =
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
