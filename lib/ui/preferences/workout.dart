import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/time_display_mode.dart';
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
      const PrefLabel(
        title: Text(timeDisplayMode),
        subtitle: Text(timeDisplayModeDescription),
      ),
      const PrefRadio<String>(
        title: Text(timeDisplayModeElapsedTitle),
        subtitle: Text(timeDisplayModeElapsedDescription),
        value: timeDisplayModeElapsed,
        pref: timeDisplayModeTag,
      ),
      const PrefRadio<String>(
        title: Text(timeDisplayModeMovingTitle),
        subtitle: Text(timeDisplayModeMovingDescription),
        value: timeDisplayModeMoving,
        pref: timeDisplayModeTag,
      ),
      const PrefRadio<String>(
        title: Text(timeDisplayModeHIITMovingTitle),
        subtitle: Text(timeDisplayModeHIITMovingDescription),
        value: timeDisplayModeHIITMoving,
        pref: timeDisplayModeTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: workoutPreferences),
    );
  }
}
