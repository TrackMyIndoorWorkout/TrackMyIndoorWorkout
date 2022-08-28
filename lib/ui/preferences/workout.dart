import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/time_display_mode.dart';
import '../../preferences/workout_mode.dart';
import 'preferences_screen_mixin.dart';

class WorkoutPreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Workout";
  static String title = "$shortTitle Preferences";

  const WorkoutPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> workoutPreferences = [
      PrefLabel(
        title: Text(workoutMode, style: Theme.of(context).textTheme.headline5!, maxLines: 3),
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
      PrefLabel(
        title: Text(timeDisplayMode, style: Theme.of(context).textTheme.headline5!, maxLines: 3),
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
