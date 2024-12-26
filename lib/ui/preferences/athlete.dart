import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_height.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_email.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_name.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import 'pref_integer.dart';
import 'preferences_screen_mixin.dart';

class AthletePreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Athlete";
  static String title = "$shortTitle Preferences";

  const AthletePreferencesScreen({super.key});

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
        divisions: athleteBodyWeightDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: athleteBodyWeightIntTag,
        min: athleteBodyWeightMin,
        max: athleteBodyWeightMax,
      ),
      PrefSlider<int>(
        title: const Text(athleteBodyHeight),
        subtitle: const Text(athleteBodyHeightDescription),
        pref: athleteBodyHeightTag,
        trailing: (num value) => Text("$value cm"),
        min: athleteBodyHeightMin,
        max: athleteBodyHeightMax,
        divisions: athleteBodyHeightDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: athleteBodyHeightTag,
        min: athleteBodyHeightMin,
        max: athleteBodyHeightMax,
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
        divisions: athleteAgeDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: athleteAgeTag,
        min: athleteAgeMin,
        max: athleteAgeMax,
      ),
      PrefLabel(
        title: Text(athleteGender, style: Get.textTheme.headlineSmall!, maxLines: 3),
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
        divisions: athleteVO2MaxDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: athleteVO2MaxTag,
        min: athleteVO2MaxMin,
        max: athleteVO2MaxMax,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefLabel(
        title: Text(athleteLifeFitness, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(athleteLifeFitnessDescription),
      ),
      PrefText(
        label: athleteFirstName,
        pref: athleteFirstNameTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[\w\d\s\,.']"))],
      ),
      PrefText(
        label: athleteLastName,
        pref: athleteLastNameTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[\w\d\s\,.']"))],
      ),
      PrefText(
        label: athleteEmail,
        pref: athleteEmailTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[\w\d\_.@]"))],
        validator: (str) {
          if (str == null || str.isEmpty) {
            return null;
          }

          if (!EmailValidator.validate(str)) {
            return "Doesn't look like a valid email address";
          }

          return null;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AthletePreferencesScreen.title)),
      body: PrefPage(children: athletePreferences),
    );
  }
}
