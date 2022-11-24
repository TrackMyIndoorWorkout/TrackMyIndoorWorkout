import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import 'preferences_screen_mixin.dart';

class AthletePreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Athlete";
  static String title = "$shortTitle Preferences";

  const AthletePreferencesScreen({Key? key}) : super(key: key);

  @override
  AthletePreferencesScreenState createState() => AthletePreferencesScreenState();
}

class AthletePreferencesScreenState extends State<AthletePreferencesScreen> {
  int _athleteBodyWeightEdit = 0;
  int _athleteAgeEdit = 0;
  int _athleteVO2MaxEdit = 0;

  void onAthleteBodyWeightSpinTap(int delta) {
    setState(() {
      final bodyWeight = PrefService.of(context).get(athleteBodyWeightIntTag);
      PrefService.of(context).set(athleteBodyWeightIntTag, bodyWeight + delta);
      _athleteBodyWeightEdit++;
    });
  }

  void onAthleteAgeSpinTap(int delta) {
    setState(() {
      final age = PrefService.of(context).get(athleteAgeTag);
      PrefService.of(context).set(athleteAgeTag, age + delta);
      _athleteAgeEdit++;
    });
  }

  void onAthleteVO2MaxSpinTap(int delta) {
    setState(() {
      final vo2Max = PrefService.of(context).get(athleteVO2MaxTag);
      PrefService.of(context).set(athleteVO2MaxTag, vo2Max + delta);
      _athleteVO2MaxEdit++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> athletePreferences = [
      PrefSlider<int>(
        key: Key("athleteBodyWeight$_athleteBodyWeightEdit"),
        title: const Text(athleteBodyWeight),
        subtitle: const Text(athleteBodyWeightDescription),
        pref: athleteBodyWeightIntTag,
        trailing: (num value) => Text("$value kg"),
        min: athleteBodyWeightMin,
        max: athleteBodyWeightMax,
        divisions: athleteBodyWeightDivisions,
        direction: Axis.vertical,
      ),
      PrefButton(
        onTap: () => onAthleteBodyWeightSpinTap(1),
        child: const Text("+1 kg"),
      ),
      PrefButton(
        onTap: () => onAthleteBodyWeightSpinTap(-1),
        child: const Text("-1 kg"),
      ),
      PrefButton(
        onTap: () => onAthleteBodyWeightSpinTap(10),
        child: const Text("+10 kgs"),
      ),
      PrefButton(
        onTap: () => onAthleteBodyWeightSpinTap(-10),
        child: const Text("-10 kgs"),
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
        key: Key("athleteAge$_athleteAgeEdit"),
        title: const Text(athleteAge),
        subtitle: const Text(athleteAgeDescription),
        pref: athleteAgeTag,
        trailing: (num value) => Text("$value"),
        min: athleteAgeMin,
        max: athleteAgeMax,
        divisions: athleteAgeDivisions,
        direction: Axis.vertical,
      ),
      PrefButton(
        onTap: () => onAthleteAgeSpinTap(1),
        child: const Text("+1 year"),
      ),
      PrefButton(
        onTap: () => onAthleteAgeSpinTap(-1),
        child: const Text("-1 year"),
      ),
      PrefButton(
        onTap: () => onAthleteAgeSpinTap(10),
        child: const Text("+10 years"),
      ),
      PrefButton(
        onTap: () => onAthleteAgeSpinTap(-10),
        child: const Text("-10 years"),
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
        key: Key("athleteVO2Max$_athleteVO2MaxEdit"),
        title: const Text(athleteVO2Max),
        subtitle: const Text(athleteVO2MaxDescription),
        pref: athleteVO2MaxTag,
        trailing: (num value) => Text("$value"),
        min: athleteVO2MaxMin,
        max: athleteVO2MaxMax,
        divisions: athleteVO2MaxDivisions,
        direction: Axis.vertical,
      ),
      PrefButton(
        onTap: () => onAthleteVO2MaxSpinTap(1),
        child: const Text("+1 ml/kg*min"),
      ),
      PrefButton(
        onTap: () => onAthleteVO2MaxSpinTap(-1),
        child: const Text("-1 ml/kg*min"),
      ),
      PrefButton(
        onTap: () => onAthleteVO2MaxSpinTap(10),
        child: const Text("+10 ml/kg*min"),
      ),
      PrefButton(
        onTap: () => onAthleteVO2MaxSpinTap(-10),
        child: const Text("-10 ml/kg*min"),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AthletePreferencesScreen.title)),
      body: PrefPage(children: athletePreferences),
    );
  }
}
