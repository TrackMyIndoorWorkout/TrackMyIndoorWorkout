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
      PrefCheckbox(
        title: Text(USE_HEART_RATE_BASED_CALORIE_COUNTING),
        subtitle: Text(USE_HEART_RATE_BASED_CALORIE_COUNTING_DESCRIPTION),
        pref: USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG,
      ),
      PrefSlider<int>(
        title: Text(ATHLETE_AGE),
        subtitle: Text(ATHLETE_AGE_DESCRIPTION),
        pref: ATHLETE_AGE_TAG,
        trailing: (num value) => Text("$value"),
        min: ATHLETE_AGE_MIN,
        max: ATHLETE_AGE_MAX,
      ),
      PrefLabel(
        title: Text(ATHLETE_GENDER),
        subtitle: Text(ATHLETE_GENDER_DESCRIPTION),
      ),
      PrefRadio<String>(
        title: Text(ATHLETE_GENDER_MALE_DESCRIPTION),
        value: ATHLETE_GENDER_MALE,
        pref: ATHLETE_GENDER_TAG,
      ),
      PrefRadio<String>(
        title: Text(ATHLETE_GENDER_FEMALE_DESCRIPTION),
        value: ATHLETE_GENDER_FEMALE,
        pref: ATHLETE_GENDER_TAG,
      ),
      PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: Text(ATHLETE_VO2MAX),
        subtitle: Text(ATHLETE_VO2MAX_DESCRIPTION),
        pref: ATHLETE_VO2MAX_TAG,
        trailing: (num value) => Text("$value"),
        min: ATHLETE_VO2MAX_MIN,
        max: ATHLETE_VO2MAX_MAX,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: athletePreferences),
    );
  }
}
