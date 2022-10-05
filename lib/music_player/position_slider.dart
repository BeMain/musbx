import 'package:flutter/material.dart';
import 'package:musbx/music_player/highlighted_section_slider_track_shape.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/widgets.dart';

class PositionSlider extends StatelessWidget {
  /// Slider for seeking a position in the current song.
  ///
  /// Includes labels displaying the current position and duration of the current song.
  /// If looping is enabled, highlights the section of the slider being looped.
  PositionSlider({super.key});

  final MusicPlayer musicPlayer = MusicPlayer.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: musicPlayer.durationNotifier,
      builder: (_, duration, __) => ValueListenableBuilder(
        valueListenable: musicPlayer.loopEnabledNotifier,
        builder: (_, loopEnabled, __) => ValueListenableBuilder(
          valueListenable: musicPlayer.loopSectionNotifier,
          builder: (_, loopSection, __) => ValueListenableBuilder(
            valueListenable: musicPlayer.positionNotifier,
            builder: (context, position, _) => _buildSlider(
              context,
              duration,
              position,
              loopEnabled,
              loopSection,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    Duration duration,
    Duration position,
    bool loopEnabled,
    LoopSection loopSection,
  ) {
    return Row(
      children: [
        _buildDurationText(context, position),
        Expanded(
          child: SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                trackShape: !loopEnabled
                    ? null
                    : musicPlayer.nullIfNoSongElse(_buildSliderTrackShape(
                        context,
                        duration,
                        loopSection,
                      ))),
            child: Slider(
              activeColor: loopEnabled
                  ? Theme.of(context).colorScheme.background.withOpacity(0.24)
                  : null,
              inactiveColor: loopEnabled
                  ? Theme.of(context).colorScheme.background.withOpacity(0.24)
                  : null,
              thumbColor: Theme.of(context).colorScheme.primary,
              min: 0,
              max: duration.inMilliseconds.roundToDouble(),
              value: position.inMilliseconds.roundToDouble(),
              onChanged: musicPlayer.nullIfNoSongElse((double value) {
                musicPlayer.seek(Duration(milliseconds: value.round()));
              }),
            ),
          ),
        ),
        _buildDurationText(context, duration),
      ],
    );
  }

  Widget _buildDurationText(BuildContext context, Duration duration) {
    return Text(
      (musicPlayer.songTitle == null) ? "-- : --" : durationString(duration),
      style: Theme.of(context).textTheme.caption,
    );
  }

  SliderTrackShape _buildSliderTrackShape(
    BuildContext context,
    Duration duration,
    LoopSection loopSection,
  ) {
    return HighlightedSectionSliderTrackShape(
      highlightStart:
          loopSection.start.inMilliseconds / duration.inMilliseconds,
      highlightEnd: loopSection.end.inMilliseconds / duration.inMilliseconds,
      activeHighlightColor: Theme.of(context).colorScheme.primary,
      inactiveHighlightColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.24),
    );
  }
}
