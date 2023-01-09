import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musbx/custom_icons.dart';
import 'package:musbx/music_player/loop_card/looper.dart';
import 'package:musbx/music_player/music_player.dart';

class LoopButtons extends StatelessWidget {
  /// A set of buttons for controlling looping.
  ///
  /// Includes a button for enabling/disabling looping, and buttons for setting
  /// the loopSection's start or end to the player's current position.
  LoopButtons({super.key});

  final MusicPlayer musicPlayer = MusicPlayer.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Set the loopSection's start to position
        IconButton(
          onPressed: musicPlayer.nullIfNoSongElse(() {
            musicPlayer.looper.section = LoopSection(
              start: Duration(
                milliseconds: min(
                  musicPlayer.looper.section.end.inMilliseconds - 1000,
                  musicPlayer.position.inMilliseconds,
                ),
              ),
              end: musicPlayer.looper.section.end,
            );
          }),
          icon: const Icon(Icons.arrow_circle_right_outlined),
        ),
        // Toggle loopEnabled
        ValueListenableBuilder(
          valueListenable: musicPlayer.looper.enabledNotifier,
          builder: (context, loopEnabled, _) => TextButton(
            onPressed: musicPlayer.nullIfNoSongElse(() {
              musicPlayer.looper.enabled = !loopEnabled;
            }),
            child: Icon(
              loopEnabled ? CustomIcons.repeat_off : CustomIcons.repeat,
              size: 50,
            ),
          ),
        ),
        // Set the loopSection's end to position
        IconButton(
          onPressed: musicPlayer.nullIfNoSongElse(() {
            musicPlayer.looper.section = LoopSection(
              start: musicPlayer.looper.section.start,
              end: Duration(
                milliseconds: max(
                  musicPlayer.position.inMilliseconds,
                  musicPlayer.looper.section.start.inMilliseconds + 1000,
                ),
              ),
            );
          }),
          icon: const Icon(Icons.arrow_circle_left_outlined),
        ),
      ],
    );
  }
}
