import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class AthletePreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Athlete";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> athletePreferences = [
      PrefLabel(title: Text(ATHLETE_BODY_WEIGHT_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: ATHLETE_BODY_WEIGHT,
        pref: ATHLETE_BODY_WEIGHT_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 1, 1000)) {
            return "Invalid weight (expected integer: 1 <= weight <= 1000)";
          }

          return null;
        },
      ),
      PrefCheckbox(
        title: Text(REMEMBER_ATHLETE_BODY_WEIGHT),
        subtitle: Text(REMEMBER_ATHLETE_BODY_WEIGHT_DESCRIPTION),
        pref: REMEMBER_ATHLETE_BODY_WEIGHT_TAG,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: athletePreferences),
    );
  }
}
