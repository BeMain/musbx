import 'package:flutter/material.dart';
import 'package:musbx/custom_icons.dart';

enum BeatSound {
  primary(fileName: "sticks.wav", icon: CustomIcons.drumsticks_circle),
  accented(fileName: "cowbell.mp3", icon: CustomIcons.cowbell_circle),
  none(fileName: "", icon: Icons.circle_outlined);

  const BeatSound({required this.fileName, required this.icon});

  /// File used when playing this sound, e.g. in BeatSounds.
  final String fileName;

  /// The icon used to represent this sound, e.g. in BeatSoundViewer
  final IconData icon;
}

/// The color used when displaying [BeatSound], e.g. in BeatSoundViewer.
Color beatSoundColor(BuildContext context, BeatSound beatSound) {
  switch (beatSound) {
    case BeatSound.primary:
      return Theme.of(context).colorScheme.primary;
    case BeatSound.accented:
      return Theme.of(context).colorScheme.inversePrimary;
    case BeatSound.none:
      return Theme.of(context).colorScheme.background;
  }
}
