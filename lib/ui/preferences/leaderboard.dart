import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class LeaderboardPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Leaderboard";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> leaderboardPreferences = [
      SwitchPreference(
        LEADERBOARD_FEATURE,
        LEADERBOARD_FEATURE_TAG,
        defaultVal: LEADERBOARD_FEATURE_DEFAULT,
        desc: LEADERBOARD_FEATURE_DESCRIPTION,
        onDisable: () {
          PrefService.setBool(RANK_RIBBON_VISUALIZATION_TAG, false);
          PrefService.setBool(RANK_TRACK_VISUALIZATION_TAG, false);
          PrefService.setBool(RANKING_FOR_DEVICE_TAG, false);
          PrefService.setBool(RANKING_FOR_SPORT_TAG, false);
        },
      ),
      SwitchPreference(
        RANK_RIBBON_VISUALIZATION,
        RANK_RIBBON_VISUALIZATION_TAG,
        defaultVal: RANK_RIBBON_VISUALIZATION_DEFAULT,
        desc: RANK_RIBBON_VISUALIZATION_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
      SwitchPreference(
        RANK_TRACK_VISUALIZATION,
        RANK_TRACK_VISUALIZATION_TAG,
        defaultVal: RANK_TRACK_VISUALIZATION_DEFAULT,
        desc: RANK_TRACK_VISUALIZATION_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
      SwitchPreference(
        RANK_INFO_ON_TRACK,
        RANK_INFO_ON_TRACK_TAG,
        defaultVal: RANK_INFO_ON_TRACK_DEFAULT,
        desc: RANK_INFO_ON_TRACK_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(RANK_TRACK_VISUALIZATION_TAG, true);
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
      SwitchPreference(
        RANKING_FOR_DEVICE,
        RANKING_FOR_DEVICE_TAG,
        defaultVal: RANKING_FOR_DEVICE_DEFAULT,
        desc: RANKING_FOR_DEVICE_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
      SwitchPreference(
        RANKING_FOR_SPORT,
        RANKING_FOR_SPORT_TAG,
        defaultVal: RANKING_FOR_SPORT_DEFAULT,
        desc: RANKING_FOR_SPORT_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(leaderboardPreferences),
    );
  }
}
