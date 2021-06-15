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
      PrefSlider<int>(
        title: Text(ATHLETE_BODY_WEIGHT),
        subtitle: Text(ATHLETE_BODY_WEIGHT_DESCRIPTION),
        pref: ATHLETE_BODY_WEIGHT_INT_TAG,
        trailing: (num value) => Text("$value kg"),
        min: ATHLETE_BODY_WEIGHT_MIN,
        max: ATHLETE_BODY_WEIGHT_MAX,
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
