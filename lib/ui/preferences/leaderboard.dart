import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/lap_counter.dart';
import '../../preferences/leaderboard_and_rank.dart';
import '../../preferences/show_pacer.dart';
import 'preferences_screen_mixin.dart';

class LeaderboardPreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Leaderboard";
  static String title = "$shortTitle Preferences";

  const LeaderboardPreferencesScreen({Key? key}) : super(key: key);

  @override
  LeaderboardPreferencesScreenState createState() => LeaderboardPreferencesScreenState();
}

class LeaderboardPreferencesScreenState extends State<LeaderboardPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    List<Widget> leaderboardPreferences = [
      PrefCheckbox(
        title: const Text(leaderboardFeature),
        subtitle: const Text(leaderboardFeatureDescription),
        pref: leaderboardFeatureTag,
        onChange: (value) {
          if (!value) {
            setState(() {
              PrefService.of(context).set(rankRibbonVisualizationTag, false);
              PrefService.of(context).set(rankTrackVisualizationTag, false);
            });
          }
        },
      ),
      PrefCheckbox(
        title: const Text(rankingForSportOrDevice),
        subtitle: const Text(rankingForSportOrDeviceDescription),
        pref: rankingForSportOrDeviceTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
      PrefCheckbox(
        title: const Text(rankRibbonVisualization),
        subtitle: const Text(rankRibbonVisualizationDescription),
        pref: rankRibbonVisualizationTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
      PrefCheckbox(
        title: const Text(rankTrackVisualization),
        subtitle: const Text(rankTrackVisualizationDescription),
        pref: rankTrackVisualizationTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
      PrefCheckbox(
        title: const Text(rankInfoOnTrack),
        subtitle: const Text(rankInfoOnTrackDescription),
        pref: rankInfoOnTrackTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(rankTrackVisualizationTag, true);
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
      const PrefCheckbox(
        title: Text(displayLapCounter),
        subtitle: Text(displayLapCounterDescription),
        pref: displayLapCounterTag,
      ),
      PrefCheckbox(
        title: const Text(avgSpeedOnTrack),
        subtitle: const Text(avgSpeedOnTrackDescription),
        pref: avgSpeedOnTrackTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
      PrefCheckbox(
        title: const Text(showPacer),
        subtitle: const Text(showPacerDescription),
        pref: showPacerTag,
        onChange: (value) {
          if (value) {
            setState(() {
              PrefService.of(context).set(leaderboardFeatureTag, true);
            });
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(LeaderboardPreferencesScreen.title)),
      body: PrefPage(children: leaderboardPreferences),
    );
  }
}
