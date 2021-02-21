import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../persistence/preferences.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class PreferencesScreen extends StatelessWidget {
  bool isInteger(String str, lowerLimit, upperLimit) {
    int integer = int.tryParse(str);
    return integer != null &&
        (lowerLimit < 0 || integer >= lowerLimit) &&
        (upperLimit < 0 || integer <= upperLimit);
  }

  bool isMonotoneIncreasingList(String zonesSpecStr) {
    if (!intListRule.hasMatch(zonesSpecStr)) return false;

    List<int> intList =
        zonesSpecStr.split(',').map((zs) => int.tryParse(zs)).toList(growable: false);

    for (int i = 0; i < intList.length - 1; i++) {
      if (intList[i] == null || intList[i + 1] == null) return false;

      if (intList[i] >= intList[i + 1]) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> appPreferences = [
      PreferenceTitle(UX_PREFERENCES),
      SwitchPreference(
        UNIT_SYSTEM,
        UNIT_SYSTEM_TAG,
        defaultVal: UNIT_SYSTEM_DEFAULT,
        desc: UNIT_SYSTEM_DESCRIPTION,
        onEnable: () => preferencesSpecs[1].unit = 'kmh',
        onDisable: () => preferencesSpecs[1].unit = 'mph',
      ),
      SwitchPreference(
        INSTANT_SCAN,
        INSTANT_SCAN_TAG,
        defaultVal: INSTANT_SCAN_DEFAULT,
        desc: INSTANT_SCAN_DESCRIPTION,
      ),
      SwitchPreference(
        INSTANT_WORKOUT,
        INSTANT_WORKOUT_TAG,
        defaultVal: INSTANT_WORKOUT_DEFAULT,
        desc: INSTANT_WORKOUT_DESCRIPTION,
      ),
      SwitchPreference(
        INSTANT_UPLOAD,
        INSTANT_UPLOAD_TAG,
        defaultVal: INSTANT_UPLOAD_DEFAULT,
        desc: INSTANT_UPLOAD_DESCRIPTION,
      ),
      SwitchPreference(
        DEVICE_FILTERING,
        DEVICE_FILTERING_TAG,
        defaultVal: DEVICE_FILTERING_DEFAULT,
        desc: DEVICE_FILTERING_DESCRIPTION,
      ),
      SwitchPreference(
        SIMPLER_UI,
        SIMPLER_UI_TAG,
        defaultVal: SIMPLER_UI_FAST_DEFAULT,
        desc: SIMPLER_UI_DESCRIPTION,
      ),
      PreferenceTitle(TUNING_PREFERENCES),
      SwitchPreference(
        COMPRESS_DOWNLOAD,
        COMPRESS_DOWNLOAD_TAG,
        defaultVal: COMPRESS_DOWNLOAD_DEFAULT,
        desc: COMPRESS_DOWNLOAD_DESCRIPTION,
      ),
      PreferenceTitle(THROTTLE_POWER_DESCRIPTION),
      TextFieldPreference(
        THROTTLE_POWER,
        THROTTLE_POWER_TAG,
        defaultVal: THROTTLE_POWER_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 100)) {
            return "Invalid throttle (should be 0 <= percent <= 100)";
          }
          return null;
        },
      ),
      SwitchPreference(
        THROTTLE_OTHER,
        THROTTLE_OTHER_TAG,
        defaultVal: THROTTLE_OTHER_DEFAULT,
        desc: THROTTLE_OTHER_DESCRIPTION,
      ),

      TextFieldPreference(
        STROKE_RATE_SMOOTHING,
        STROKE_RATE_SMOOTHING_TAG,
        defaultVal: STROKE_RATE_SMOOTHING_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 1, 50)) {
            return "Invalid window size (should be 1 <= size <= 50)";
          }
          return null;
        },
      ),
    ];

    if (kDebugMode) {
      appPreferences.add(SwitchPreference(
        APP_DEBUG_MODE,
        APP_DEBUG_MODE_TAG,
        defaultVal: APP_DEBUG_MODE_DEFAULT,
        desc: APP_DEBUG_MODE_DESCRIPTION,
      ));
    }

    appPreferences.add(PreferenceTitle(ZONE_PREFERENCES));
    preferencesSpecs.forEach((prefSpec) {
      appPreferences.addAll([
        TextFieldPreference(
          THRESHOLD_CAPITAL + prefSpec.fullTitle,
          prefSpec.thresholdTag,
          defaultVal: prefSpec.thresholdDefault,
          validator: (str) {
            if (!isInteger(str, 1, -1)) {
              return "Invalid threshold (should be integer >= 1)";
            }
            return null;
          },
        ),
        TextFieldPreference(
          prefSpec.title + ZONES_CAPITAL,
          prefSpec.zonesTag,
          defaultVal: prefSpec.zonesDefault,
          validator: (str) {
            if (!isMonotoneIncreasingList(str)) {
              return "Invalid zones (should be comma separated list of " +
                  "monotonically increasing integers)";
            }
            return null;
          },
        ),
      ]);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Preferences')),
      body: PreferencePage(appPreferences),
    );
  }
}
