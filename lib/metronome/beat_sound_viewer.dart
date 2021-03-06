import 'package:flutter/material.dart';
import 'package:musbx/metronome/beat_sound.dart';
import 'package:musbx/metronome/metronome.dart';

class BeatSoundViewer extends StatefulWidget {
  /// Widget for displaying and editing the sounds played by the [Metronome] on
  /// each of the beats.
  ///
  /// Displays the beats as circles, using the color of the beat's [BeatSound].
  /// Clicking a circle changes the sound played on that beat.
  ///
  /// Pressing long on a circle removes that beats. Also offers a plus button
  /// for adding new beats.
  ///
  /// The beat that was most recently played ([Metronome.count]) is highlighted.
  const BeatSoundViewer({super.key});

  @override
  State<StatefulWidget> createState() => BeatSoundViewerState();
}

class BeatSoundViewerState extends State<BeatSoundViewer> {
  @override
  void initState() {
    super.initState();

    // Listen for changes to:
    // - sounds: change number of circles
    // - count: change which circle is highlighted.
    Metronome.beatSounds.addListener(() => setState(() {}));
    Metronome.countNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ..._buildBeatButtons(),
            IconButton(
              onPressed: (() {
                Metronome.beatSounds.add(BeatSound.sticks);
              }),
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
          ]),
    );
  }

  List<Widget> _buildBeatButtons() {
    return Metronome.beatSounds.sounds
        .asMap()
        .map((int index, BeatSound sound) => MapEntry(
              index,
              Ink(
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    // Change beat sound
                    var sound = Metronome.beatSounds[index];
                    Metronome.beatSounds[index] = BeatSound
                        .values[(sound.index + 1) % BeatSound.values.length];
                  },
                  onLongPress: () {
                    if (Metronome.beatSounds.length >= 2) {
                      Metronome.beatSounds.removeAt(index);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.circle,
                      color: sound.color,
                      shadows: (Metronome.count == index)
                          ? [const Shadow(blurRadius: 10)]
                          : [], // Highlight current beat
                    ),
                  ),
                ),
              ),
            ))
        .values
        .toList();
  }
}
