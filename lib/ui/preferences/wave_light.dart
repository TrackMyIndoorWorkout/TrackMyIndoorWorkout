import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class WaveLightPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Wavelight";
  static String title = "$shortTitle Pref";

  @override
  Widget build(BuildContext context) {
    List<Widget> waveLightPreferences = [
      SwitchPreference(
        LEADERBOARD_FEATURE,
        LEADERBOARD_FEATURE_TAG,
        defaultVal: LEADERBOARD_FEATURE_DEFAULT,
        desc: LEADERBOARD_FEATURE_DESCRIPTION,
        onDisable: () {
          PrefService.setBool(WAVE_LIGHT_FOR_DEVICE_TAG, false);
          PrefService.setBool(WAVE_LIGHT_FOR_SPORT_TAG, false);
        },
      ),
      SwitchPreference(
        WAVE_LIGHT_FOR_DEVICE,
        WAVE_LIGHT_FOR_DEVICE_TAG,
        defaultVal: WAVE_LIGHT_FOR_DEVICE_DEFAULT,
        desc: WAVE_LIGHT_FOR_DEVICE_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
      SwitchPreference(
        WAVE_LIGHT_FOR_SPORT,
        WAVE_LIGHT_FOR_SPORT_TAG,
        defaultVal: WAVE_LIGHT_FOR_SPORT_DEFAULT,
        desc: WAVE_LIGHT_FOR_SPORT_DESCRIPTION,
        onEnable: () {
          PrefService.setBool(LEADERBOARD_FEATURE_TAG, true);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(waveLightPreferences),
    );
  }
}
