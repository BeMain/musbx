import 'package:flutter/material.dart';
import 'package:musbx/music_player/music_player.dart';

class LoopButtons extends StatelessWidget {
  /// A set of buttons for controlling looping.
  ///
  /// Includes a button for enabling/disabling looping, and buttons for setting
  /// the loopSection's start or end to the player's current position.
  const LoopButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicPlayer musicPlayer = MusicPlayer.instance;

    final bool disabled = (musicPlayer.songTitle == null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Set the loopSection's start to position
        IconButton(
          onPressed: musicPlayer.nullIfNoSongElse(() {
            musicPlayer.loopSection = LoopSection(
              start: musicPlayer.position,
              end: musicPlayer.loopSection.end,
            );
          }),
          icon: const Icon(Icons.arrow_circle_right_outlined),
        ),
        // Toggle loopEnabled
        ValueListenableBuilder(
          valueListenable: musicPlayer.loopEnabledNotifier,
          builder: (context, loopEnabled, child) => TextButton(
            onPressed: musicPlayer.nullIfNoSongElse(() {
              musicPlayer.loopEnabled = !loopEnabled;
            }),
            child: Icon(
              loopEnabled ? Icons.trending_flat_rounded : Icons.loop_rounded,
              size: 50,
            ),
          ),
        ),
        // Set the loopSection's end to position
        IconButton(
          onPressed: musicPlayer.nullIfNoSongElse(() {
            musicPlayer.loopSection = LoopSection(
              start: musicPlayer.loopSection.start,
              end: musicPlayer.position,
            );
          }),
          icon: const Icon(Icons.arrow_circle_left_outlined),
        ),
      ],
    );
  }
}
