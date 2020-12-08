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
    INSTANT_SCAN_TAG: INSTANT_SCAN_DEFAULT,
    SCAN_DURATION_TAG: SCAN_DURATION_DEFAULT,
    INSTANT_WORKOUT_TAG: INSTANT_WORKOUT_DEFAULT,
    LAST_EQUIPMENT_ID_TAG: LAST_EQUIPMENT_ID_DEFAULT,
    INSTANT_UPLOAD_TAG: INSTANT_UPLOAD_DEFAULT,
    SIMPLER_UI_TAG: await getSimplerUiDefault(),
    DEVICE_FILTERING_TAG: DEVICE_FILTERING_DEFAULT,
    FONT_SELECTION_TAG: FONT_SELECTION_DEFAULT,
    VIRTUAL_WORKOUT_TAG: VIRTUAL_WORKOUT_DEFAULT,
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
