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
  Map<String, dynamic> prefDefaults = {
    UNIT_SYSTEM_TAG: UNIT_SYSTEM_DEFAULT,
    DEVICE_FILTERING_TAG: DEVICE_FILTERING_DEFAULT,
  };
  preferencesSpecs.forEach((prefSpec) {
    prefDefaults.addAll({
      prefSpec.thresholdTag: prefSpec.thresholdDefault,
      prefSpec.zonesTag: prefSpec.zonesDefault,
    });
  });
  PrefService.setDefaultValues(prefDefaults);

  runApp(TrackMyIndoorExerciseApp());
}
