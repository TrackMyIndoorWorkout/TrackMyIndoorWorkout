import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../persistence/preferences.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class PreferencesScreen extends StatelessWidget {
  bool isPositiveInteger(String str) {
    int integer = int.tryParse(str);
    return integer != null && integer > 0;
  }

  bool isMonotoneIncreasingList(String zonesSpecStr) {
    if (!intListRule.hasMatch(zonesSpecStr)) return false;
    List<int> intList = zonesSpecStr
        .split(',')
        .map((zs) => int.tryParse(zs))
        .toList(growable: false);
    for (int i = 0; i < intList.length - 1; i++) {
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
      PreferenceTitle(ZONE_PREFERENCES),
    ];

    preferencesSpecs.forEach((prefSpec) {
      appPreferences.addAll([
        TextFieldPreference(
          THRESHOLD_CAPITAL + prefSpec.fullTitle,
          prefSpec.thresholdTag,
          defaultVal: prefSpec.thresholdDefault,
          validator: (str) {
            if (!isPositiveInteger(str)) {
              return "Invalid threshold";
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
              return "Invalid zones";
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
