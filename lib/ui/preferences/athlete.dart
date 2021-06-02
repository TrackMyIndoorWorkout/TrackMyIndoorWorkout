import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class AthletePreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Athlete";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> athletePreferences = [
      PreferenceTitle(ATHLETE_BODY_WEIGHT_DESCRIPTION),
      TextFieldPreference(
        ATHLETE_BODY_WEIGHT,
        ATHLETE_BODY_WEIGHT_TAG,
        defaultVal: ATHLETE_BODY_WEIGHT_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 1, 1000)) {
            return "Invalid weight (expected integer: 1 <= weight <= 1000)";
          }
          return null;
        },
      ),
      SwitchPreference(
        REMEMBER_ATHLETE_BODY_WEIGHT,
        REMEMBER_ATHLETE_BODY_WEIGHT_TAG,
        defaultVal: REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT,
        desc: REMEMBER_ATHLETE_BODY_WEIGHT_DESCRIPTION,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(athletePreferences),
    );
  }
}
