import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';
import 'package:musbx/tuner/note.dart';
import 'package:musbx/tuner/tuner.dart';

class TunerGauge extends StatelessWidget {
  /// Gauge for showing how out of tune [note] is.
  ///
  /// Includes labels displaying the name of [note]
  /// and how many cents out of tune it is.
  ///
  /// If [note] is `null`, instead displays a "listening" label.
  const TunerGauge({super.key, required this.note});

  /// The note to display. Shows how out of tune it is and what note it is.
  final Note? note;

  @override
  Widget build(BuildContext context) {
    return (note == null)
        ? buildListeningGauge(context)
        : buildGaugeAndText(context, note!);
  }

  /// Build gauge with "listening" text.
  Widget buildListeningGauge(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, 0.5),
            child: Text(
              "Listening...",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        buildGauge(context),
      ],
    );
  }

  /// Build gage showing [note]'s name and tuning.
  Widget buildGaugeAndText(BuildContext context, Note note) {
    // If note is in tune, make needle green
    List<Color> needleColors = (note.pitchOffset.abs() < Tuner.inTuneThreshold)
        ? [
            Colors.lightGreen
                .harmonizeWith(Theme.of(context).colorScheme.primary),
            Colors.green.harmonizeWith(Theme.of(context).colorScheme.primary),
          ]
        : (Theme.of(context).colorScheme.brightness == Brightness.light)
            ? [
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onSurface,
              ]
            : [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.inversePrimary,
              ];

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: const Alignment(-0.55, 0.7),
            child: Text(
              note.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.6, 0.7),
            child: Text(
              (note.pitchOffset.toInt().isNegative)
                  ? "${note.pitchOffset.toInt()}¢"
                  : "+${note.pitchOffset.toInt()}¢",
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
        buildGauge(context, [
          RadialNeedlePointer(
            value: note.pitchOffset,
            thicknessStart: 20,
            thicknessEnd: 0,
            length: 0.8,
            knobRadiusAbsolute: 10,
            gradient: LinearGradient(
              colors: needleColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.5, 0.5],
            ),
          ),
        ]),
      ],
    );
  }

  /// Build a radial gauge with the "in-tune"-section highlighted green,
  /// and optionally with some [pointers].
  Widget buildGauge(
    BuildContext context, [
    List<RadialGaugePointer>? pointers,
  ]) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.53,
        child: RadialGauge(
          axes: [
            RadialGaugeAxis(
              minValue: -1,
              maxValue: 1,
              minAngle: -18,
              maxAngle: 18,
              radius: 0,
              width: 0.8,
              color: Colors.green
                  .harmonizeWith(Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
            ),
            RadialGaugeAxis(
              minValue: -50,
              maxValue: 50,
              minAngle: -90,
              maxAngle: 90,
              ticks: [
                RadialTicks(
                  interval: 10,
                  alignment: RadialTickAxisAlignment.inside,
                  length: 0.1,
                  color: Theme.of(context).colorScheme.primary,
                  children: [
                    RadialTicks(
                      ticksInBetween: 4,
                      length: 0.05,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  ],
                ),
                RadialTicks(
                  values: [for (double i = -9; i <= 9; i++) i]..remove(0),
                  length: 0.05,
                  color: Colors.green
                      .harmonizeWith(Theme.of(context).colorScheme.primary),
                )
              ],
              pointers: pointers,
            ),
          ],
        ),
      ),
    );
  }
}
