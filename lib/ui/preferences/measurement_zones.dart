import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import 'preferences_base.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class MeasurementZonesPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Zones";
  static String title = "$shortTitle Preferences";

  bool isMonotoneIncreasingList(String zonesSpecStr) {
    if (!intListRule.hasMatch(zonesSpecStr)) return false;

    List<double> numberList =
        zonesSpecStr.split(',').map((zs) => double.tryParse(zs)).toList(growable: false);

    for (int i = 0; i < numberList.length - 1; i++) {
      if (numberList[i] == null || numberList[i + 1] == null) return false;

      if (numberList[i] >= numberList[i + 1]) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> zonePreferences = [];
    PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
      zonePreferences.add(PreferenceTitle(sport + ZONE_PREFERENCES));
      PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
        zonePreferences.addAll([
          TextFieldPreference(
            sport +
                PreferencesSpec.THRESHOLD_CAPITAL +
                (prefSpec.metric == "speed" ? prefSpec.kmhTitle : prefSpec.fullTitle),
            prefSpec.thresholdTag(sport),
            defaultVal: prefSpec.thresholdDefault(sport),
            validator: (str) {
              if (!isNumber(str, 0.1, -1)) {
                return "Invalid threshold (should be integer >= 0.1)";
              }
              return null;
            },
          ),
          TextFieldPreference(
            sport + " " + prefSpec.title + PreferencesSpec.ZONES_CAPITAL,
            prefSpec.zonesTag(sport),
            defaultVal: prefSpec.zonesDefault(sport),
            validator: (str) {
              if (!isMonotoneIncreasingList(str)) {
                return "Invalid zones (should be comma separated list of " +
                    "monotonically increasing numbers)";
              }
              return null;
            },
          ),
        ]);
      });
      if (sport != ActivityType.Ride) {
        zonePreferences.addAll([
          TextFieldPreference(
            sport + SLOW_SPEED_POSTFIX,
            PreferencesSpec.slowSpeedTag(sport),
            defaultVal: PreferencesSpec.slowSpeeds[sport].toString(),
            validator: (str) {
              if (!isNumber(str, 0.01, -1)) {
                return "Slow speed has to be positive";
              }
              return null;
            },
            onChange: (str) {
              PreferencesSpec.slowSpeeds[sport] = double.tryParse(str);
            },
          ),
        ]);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(zonePreferences),
    );
  }
}
