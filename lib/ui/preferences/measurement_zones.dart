import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

import '../../preferences/metric_spec.dart';
import '../../preferences/speed_spec.dart';
import '../../utils/constants.dart';
import 'preferences_screen_mixin.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class MeasurementZonesPreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Zones";
  static String title = "$shortTitle Preferences";
  final String sport;

  MeasurementZonesPreferencesScreen(this.sport, {super.key}) {
    shortTitle = "$sport Zone";
    title = "$shortTitle Preferences";
  }

  bool isMonotoneIncreasingList(String zonesSpecStr) {
    if (!intListRule.hasMatch(zonesSpecStr)) return false;

    List<double?> numberList = zonesSpecStr
        .split(',')
        .map((zs) => double.tryParse(zs))
        .toList(growable: false);

    for (int i = 0; i < numberList.length - 1; i++) {
      if (numberList[i] == null || numberList[i + 1] == null) return false;

      if (numberList[i]! >= numberList[i + 1]!) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> zonePreferences = [];

    for (var prefSpec in MetricSpec.preferencesSpecs) {
      zonePreferences.addAll([
        PrefText(
          label:
              sport +
              MetricSpec.thresholdCapital +
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
          label: "$sport ${prefSpec.title}${MetricSpec.zonesCapital}",
          pref: prefSpec.zonesTag(sport),
          validator: (str) {
            if (str == null || !isMonotoneIncreasingList(str)) {
              return "Invalid zones (should be comma separated list of monotonically increasing numbers)";
            }

            return null;
          },
        ),
      ]);
    }

    if (sport != ActivityType.ride) {
      zonePreferences.addAll([
        PrefText(
          label: sport + slowSpeedPostfix,
          pref: SpeedSpec.slowSpeedTag(sport),
          validator: (str) {
            if (str == null || !isNumber(str, 0.01, -1)) {
              return "Slow speed has to be positive";
            }

            if (sport != ActivityType.ride) {
              final slowSpeed = double.tryParse(str);
              if (slowSpeed != null && slowSpeed > (SpeedSpec.pacerSpeeds[sport] ?? 0.0)) {
                return "Slow speed must be slower than 'Pacer Speed' (see below)";
              }
            }

            return null;
          },
          onChange: (str) {
            final slowSpeed = double.tryParse(str);
            if (slowSpeed != null) {
              SpeedSpec.slowSpeeds[sport] = slowSpeed;
            }
          },
        ),
      ]);
    }

    zonePreferences.addAll([
      PrefText(
        label: sport + pacerSpeedPostfix,
        pref: SpeedSpec.pacerSpeedTag(sport),
        validator: (str) {
          if (str == null || !isNumber(str, 0.01, -1)) {
            return "Pacer speed has to be positive";
          }

          if (sport != ActivityType.ride) {
            final pacerSpeed = double.tryParse(str);
            if (pacerSpeed != null && pacerSpeed < (SpeedSpec.slowSpeeds[sport] ?? 0.0)) {
              return "Pacer speed must be faster than 'Slow Speed' (see above)";
            }
          }

          return null;
        },
        onChange: (str) {
          final pacerSpeed = double.tryParse(str);
          if (pacerSpeed != null) {
            SpeedSpec.pacerSpeeds[sport] = pacerSpeed;
          }
        },
      ),
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: zonePreferences),
    );
  }
}
