import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/workout_mode.dart';
import 'preferences_base.dart';

class WorkoutPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Workout";
  static String title = "$shortTitle Preferences";

  const WorkoutPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> workoutPreferences = [
      const PrefLabel(
        title: Text(workoutMode),
        subtitle: Text(workoutModeDescription),
      ),
      const PrefRadio<String>(
        title: Text(workoutModeIndividualTitle),
        subtitle: Text(workoutModeIndividualDescription),
        value: workoutModeIndividual,
        pref: workoutModeTag,
      ),
      const PrefRadio<String>(
        title: Text(workoutModeCircuitTitle),
        subtitle: Text(workoutModeCircuitDescription),
        value: workoutModeCircuit,
        pref: workoutModeTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: workoutPreferences),
    );
  }
}
