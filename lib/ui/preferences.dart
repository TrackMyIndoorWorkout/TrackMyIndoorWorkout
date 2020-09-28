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
    List<int> intList = zonesSpecStr.split(',').map((zs) => int.tryParse(zs)).toList(growable: false);
    for (int i = 0; i < intList.length - 1; i++) {
      if (intList[i] >= intList[i + 1]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> zonePreferences = [PreferenceTitle('Zones')];
    preferencesSpecs.forEach((prefSpec) {
      zonePreferences.addAll([
        TextFieldPreference(
          THRESHOLD_CAPITAL + prefSpec.title,
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
      appBar: AppBar(
        title: Text('Zone Preferences'),
      ),
      body: PreferencePage(zonePreferences
          /*
        PreferenceTitle('Theme'),
        RadioPreference(
          'Light Theme',
          'light',
          'ui_theme',
          isDefault: true,
          onSelect: () {
            DynamicTheme.of(context).setBrightness(Brightness.light);
          },
        ),
        RadioPreference(
          'Dark Theme',
          'dark',
          'ui_theme',
          onSelect: () {
            DynamicTheme.of(context).setBrightness(Brightness.dark);
          },
        ),
        */
          ),
    );
  }
}
