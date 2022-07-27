import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import 'preferences_screen_mixin.dart';

class AthletePreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Athlete";
  static String title = "$shortTitle Preferences";

  const AthletePreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> athletePreferences = [
      PrefSlider<int>(
        title: const Text(athleteBodyWeight),
        subtitle: const Text(athleteBodyWeightDescription),
        pref: athleteBodyWeightIntTag,
        trailing: (num value) => Text("$value kg"),
        min: athleteBodyWeightMin,
        max: athleteBodyWeightMax,
        direction: Axis.vertical,
      ),
      const PrefCheckbox(
        title: Text(rememberAthleteBodyWeight),
        subtitle: Text(rememberAthleteBodyWeightDescription),
        pref: rememberAthleteBodyWeightTag,
      ),
      const PrefCheckbox(
        title: Text(useHeartRateBasedCalorieCounting),
        subtitle: Text(useHeartRateBasedCalorieCountingDescription),
        pref: useHeartRateBasedCalorieCountingTag,
      ),
      PrefSlider<int>(
        title: const Text(athleteAge),
        subtitle: const Text(athleteAgeDescription),
        pref: athleteAgeTag,
        trailing: (num value) => Text("$value"),
        min: athleteAgeMin,
        max: athleteAgeMax,
        direction: Axis.vertical,
      ),
      PrefLabel(
        title: Text(athleteGender, style: Get.textTheme.headline5!, maxLines: 3),
        subtitle: const Text(athleteGenderDescription),
      ),
      const PrefRadio<String>(
        title: Text(athleteGenderMaleDescription),
        value: athleteGenderMale,
        pref: athleteGenderTag,
      ),
      const PrefRadio<String>(
        title: Text(athleteGenderFemaleDescription),
        value: athleteGenderFemale,
        pref: athleteGenderTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(athleteVO2Max),
        subtitle: const Text(athleteVO2MaxDescription),
        pref: athleteVO2MaxTag,
        trailing: (num value) => Text("$value"),
        min: athleteVO2MaxMin,
        max: athleteVO2MaxMax,
        direction: Axis.vertical,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: athletePreferences),
    );
  }
}
