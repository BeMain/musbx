import 'package:flutter/material.dart';
import 'package:musbx/editable_screen/editable_screen.dart';
import 'package:musbx/metronome/beat_sound_viewer.dart';
import 'package:musbx/metronome/bpm_buttons.dart';
import 'package:musbx/metronome/bpm_slider.dart';
import 'package:musbx/metronome/bpm_tapper.dart';
import 'package:musbx/metronome/play_button.dart';
import 'package:musbx/metronome/metronome.dart';

class MetronomeScreen extends StatelessWidget {
  /// Screen for controlling [Metronome], including:
  /// - Play / pause button
  /// - Buttons for adjusting bpm
  /// - Slider for adjusting bpm
  /// - Button for setting bpm by tapping.
  /// - Buttons for setting what sound is played each beat.
  const MetronomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditableScreen(
      title: "Metronome",
      widgets: [
        Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              BpmButtons(
                iconSize: 50,
                fontSize: 45,
              ),
              BpmTapper()
            ],
          ),
          const BpmSlider(),
        ]),
        Column(children: const [
          Center(
            child: PlayButton(
              size: 150,
            ),
          ),
          BeatSoundViewer(),
        ]),
      ],
    );
  }
}