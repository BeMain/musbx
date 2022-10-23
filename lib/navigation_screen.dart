import 'package:flutter/material.dart';
import 'package:musbx/metronome/metronome_screen.dart';
import 'package:musbx/music_player/music_player_screen.dart';
import 'package:musbx/tuner/tuner_screen.dart';

class NavigationScreen extends StatefulWidget {
  /// Navigation screen offering a bottom bar for switching between the different screens.
  const NavigationScreen({super.key});

  @override
  State<StatefulWidget> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const [
        MetronomeScreen(),
        MusicPlayerScreen(),
        TunerScreen(),
      ][selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
            label: "Metronome",
            icon: Icon(Icons.more_horiz),
          ),
          NavigationDestination(
            label: "Music player",
            icon: Icon(Icons.music_note_rounded),
          ),
          NavigationDestination(
            label: "Tuner",
            icon: Icon(Icons.speed_rounded),
          ),
        ],
      ),
    );
  }
}