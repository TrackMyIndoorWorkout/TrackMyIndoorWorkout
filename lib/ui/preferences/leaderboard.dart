import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class LeaderboardPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Leaderboard";
  static String title = "$shortTitle Preferences";

  const LeaderboardPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> leaderboardPreferences = [
      PrefCheckbox(
        title: const Text(LEADERBOARD_FEATURE),
        subtitle: const Text(LEADERBOARD_FEATURE_DESCRIPTION),
        pref: LEADERBOARD_FEATURE_TAG,
        onChange: (value) {
          if (!value) {
            PrefService.of(context).set(RANK_RIBBON_VISUALIZATION_TAG, false);
            PrefService.of(context).set(RANK_TRACK_VISUALIZATION_TAG, false);
            PrefService.of(context).set(RANKING_FOR_DEVICE_TAG, false);
            PrefService.of(context).set(RANKING_FOR_SPORT_TAG, false);
          }
        },
      ),
      PrefCheckbox(
        title: const Text(RANK_RIBBON_VISUALIZATION),
        subtitle: const Text(RANK_RIBBON_VISUALIZATION_DESCRIPTION),
        pref: RANK_RIBBON_VISUALIZATION_TAG,
        onChange: (value) {
          if (value) {
            PrefService.of(context).set(LEADERBOARD_FEATURE_TAG, true);
          }
        },
      ),
      PrefCheckbox(
        title: const Text(RANK_TRACK_VISUALIZATION),
        subtitle: const Text(RANK_TRACK_VISUALIZATION_DESCRIPTION),
        pref: RANK_TRACK_VISUALIZATION_TAG,
        onChange: (value) {
          if (value) {
            PrefService.of(context).set(LEADERBOARD_FEATURE_TAG, true);
          }
        },
      ),
      PrefCheckbox(
        title: const Text(RANK_INFO_ON_TRACK),
        subtitle: const Text(RANK_INFO_ON_TRACK_DESCRIPTION),
        pref: RANK_INFO_ON_TRACK_TAG,
        onChange: (value) {
          if (value) {
            PrefService.of(context).set(RANK_TRACK_VISUALIZATION_TAG, true);
            PrefService.of(context).set(LEADERBOARD_FEATURE_TAG, true);
          }
        },
      ),
      PrefCheckbox(
        title: const Text(RANKING_FOR_DEVICE),
        subtitle: const Text(RANKING_FOR_DEVICE_DESCRIPTION),
        pref: RANKING_FOR_DEVICE_TAG,
        onChange: (value) {
          if (value) {
            PrefService.of(context).set(LEADERBOARD_FEATURE_TAG, true);
          }
        },
      ),
      PrefCheckbox(
        title: const Text(RANKING_FOR_SPORT),
        subtitle: const Text(RANKING_FOR_SPORT_DESCRIPTION),
        pref: RANKING_FOR_SPORT_TAG,
        onChange: (value) {
          if (value) {
            PrefService.of(context).set(LEADERBOARD_FEATURE_TAG, true);
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: leaderboardPreferences),
    );
  }
}
