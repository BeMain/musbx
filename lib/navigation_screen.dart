import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:musbx/custom_icons.dart';
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
  int currentIndex = 1;
  final PageController controller = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();

    // Setup in-app review
    AdvancedInAppReview()
        .setMinDaysBeforeRemind(7)
        .setMinDaysAfterInstall(7)
        .setMinLaunchTimes(5)
        .setMinSecondsBeforeShowDialog(4)
        .monitor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          const MetronomeScreen(),
          MusicPlayerScreen(),
          const TunerScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          controller.jumpToPage(index);
          setState(() {
            currentIndex = index;
          });
        },
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            label: "Metronome",
            icon: Icon(CustomIcons.metronome),
          ),
          NavigationDestination(
            label: "Music player",
            icon: Icon(Icons.music_note),
          ),
          NavigationDestination(
            label: "Tuner",
            icon: Icon(CustomIcons.tuning_fork),
          ),
        ],
      ),
    );
  }
}
