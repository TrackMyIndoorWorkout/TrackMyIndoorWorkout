import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import 'preferences_base.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class MeasurementZonesPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Zones";
  static String title = "$shortTitle Preferences";
  final String sport;

  MeasurementZonesPreferencesScreen(this.sport) {
    shortTitle = "$sport Zone";
    title = "$shortTitle Preferences";
  }

  bool isMonotoneIncreasingList(String zonesSpecStr) {
    if (!intListRule.hasMatch(zonesSpecStr)) return false;

    List<double?> numberList =
        zonesSpecStr.split(',').map((zs) => double.tryParse(zs)).toList(growable: false);

    for (int i = 0; i < numberList.length - 1; i++) {
      if (numberList[i] == null || numberList[i + 1] == null) return false;

      if (numberList[i]! >= numberList[i + 1]!) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> zonePreferences = [];

    PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
      zonePreferences.addAll([
        PrefText(
          label: sport +
              PreferencesSpec.THRESHOLD_CAPITAL +
              (prefSpec.metric == "speed" ? prefSpec.kmhTitle : prefSpec.fullTitle),
          pref: prefSpec.thresholdTag(sport),
          validator: (str) {
            if (str == null || !isNumber(str, 0.1, -1)) {
              return "Invalid threshold (should be number >= 0.1)";
            }

            return null;
          },
        ),
        PrefText(
          label: "$sport ${prefSpec.title}${PreferencesSpec.ZONES_CAPITAL}",
          pref: prefSpec.zonesTag(sport),
          validator: (str) {
            if (str == null || !isMonotoneIncreasingList(str)) {
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
        PrefText(
          label: sport + SLOW_SPEED_POSTFIX,
          pref: PreferencesSpec.slowSpeedTag(sport),
          validator: (str) {
            if (str == null || !isNumber(str, 0.01, -1)) {
              return "Slow speed has to be positive";
            }

            return null;
          },
          onChange: (str) {
            final slowSpeed = double.tryParse(str);
            if (slowSpeed != null) {
              PreferencesSpec.slowSpeeds[sport] = slowSpeed;
            }
          },
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: zonePreferences),
    );
  }
}
