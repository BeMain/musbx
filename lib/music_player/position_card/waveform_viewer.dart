import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/position_card/waveform_painter.dart';

class WaveformViewer extends StatefulWidget {
  const WaveformViewer({
    Key? key,
    this.stepPadding = 3.0,
    this.durationCovered = const Duration(seconds: 5),
    this.stepDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  final double stepPadding;
  final Duration stepDuration;
  final Duration durationCovered;

  @override
  WaveformViewerState createState() => WaveformViewerState();
}

class WaveformViewerState extends State<WaveformViewer> {
  final MusicPlayer musicPlayer = MusicPlayer.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: musicPlayer.waveformNotifier,
        builder: (_, waveform, __) {
          if (waveform == null) {
            return Container(
              height: 100,
            );
          }

          final List<WaveformPixel> steps = generateSteps(waveform);
          return ValueListenableBuilder(
            valueListenable: MusicPlayer.instance.positionNotifier,
            builder: (context, position, _) {
              return LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  painter: WaveformPainter(
                    steps: getStepsAroundPosition(waveform, position, steps),
                    waveColor: Theme.of(context).colorScheme.primary,
                    scale: 1,
                    stepPadding: widget.stepPadding,
                    flags: waveform.flags,
                  ),
                  size: Size(constraints.maxWidth, 100),
                ),
              );
            },
          );
        });
  }

  List<WaveformPixel> generateSteps(Waveform waveform) {
    int pixelsPerStep = (widget.stepDuration.inMilliseconds / 1000) *
        waveform.sampleRate ~/
        waveform.samplesPerPixel;

    int nSteps = musicPlayer.duration.inMilliseconds ~/
        widget.stepDuration.inMilliseconds;
    int nPixels = pixelsPerStep * nSteps;

    // Sum up the pixels for each step
    List<WaveformPixel> stepSums =
        List.generate(nSteps, (i) => WaveformPixel(0, 0));
    for (int pixel = 0; pixel < nPixels; pixel++) {
      stepSums[pixel ~/ pixelsPerStep] +=
          WaveformPixel.fromWaveform(waveform, pixel);
    }

    return stepSums.map((sum) => sum ~/ pixelsPerStep).toList();
  }

  List<WaveformPixel> getStepsAroundPosition(
      Waveform waveform, Duration position, List<WaveformPixel> allSteps) {
    int pixelsPerStep = (widget.stepDuration.inMilliseconds / 1000) *
        waveform.sampleRate ~/
        waveform.samplesPerPixel;
    int startIdx =
        waveform.positionToPixel(position - widget.durationCovered) ~/
            pixelsPerStep;
    int endIdx = waveform.positionToPixel(position + widget.durationCovered) ~/
        pixelsPerStep;
    return allSteps.sublist(max(0, startIdx), min(endIdx, allSteps.length));
  }
}
