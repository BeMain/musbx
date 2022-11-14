import 'package:flutter/material.dart';
import 'package:musbx/card_list.dart';
import 'package:musbx/permission_builder.dart';
import 'package:musbx/tuner/tuner.dart';
import 'package:musbx/tuner/tuner_gauge.dart';
import 'package:musbx/tuner/tuning_graph.dart';
import 'package:permission_handler/permission_handler.dart';

class TunerScreen extends StatefulWidget {
  /// Screen that detects the pitch from the microphone and displays it.
  ///
  /// Includes:
  ///  - Gauge showing what note is being played and how out of tune it is.
  ///  - Graph showing how the tuning has changed over time.
  const TunerScreen({super.key});

  @override
  State<StatefulWidget> createState() => TunerScreenState();
}

class TunerScreenState extends State<TunerScreen> {
  final Tuner tuner = Tuner.instance;

  @override
  Widget build(BuildContext context) {
    if (!tuner.initialized) {
      return PermissionBuilder(
          permission: Permission.microphone,
          permissionName: "microphone",
          permissionText:
              "To use the tuner, give the app permission to access the microphone.",
          onPermissionGranted: () async {
            await tuner.initialize();
            if (mounted) setState(() {});
          });
    }
    return StreamBuilder(
      stream: tuner.noteStream,
      builder: (context, snapshot) => CardList(
        children: [
          TunerGauge(
              note: (tuner.noteHistory.isNotEmpty)
                  ? tuner.noteHistory.last
                  : null),
          TuningGraph(noteHistory: tuner.noteHistory),
        ],
      ),
    );
  }
}
