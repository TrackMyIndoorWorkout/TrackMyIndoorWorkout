import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preferences/preferences.dart';
import 'persistence/preferences.dart';
import 'track_my_indoor_exercise_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await PrefService.init(prefix: 'pref_');
  Map<String, String> prefDefaults = {};
  preferencesSpecs.forEach((prefSpec) {
    prefDefaults.addAll({
      prefSpec.thresholdTag: prefSpec.thresholdDefault,
      prefSpec.zonesTag: prefSpec.zonesDefault,
    });
  });
  PrefService.setDefaultValues(prefDefaults);

  runApp(TrackMyIndoorExerciseApp());
}
