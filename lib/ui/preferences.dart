import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../persistence/preferences.dart';
import '../tcx/activity_type.dart';
import '../utils/preferences.dart';

RegExp intListRule = RegExp(r'^\d+(,\d+)*$');

class PreferencesScreen extends StatelessWidget {
  bool isNumber(String str, double lowerLimit, double upperLimit) {
    double number = double.tryParse(str);
    return number != null &&
        (lowerLimit < 0.0 || number >= lowerLimit) &&
        (upperLimit < 0.0 || number <= upperLimit);
  }

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
    final descriptionStyle = TextStyle(color: Colors.black54);
    List<Widget> appPreferences = [
      PreferenceTitle(UX_PREFERENCES),
      SwitchPreference(
        UNIT_SYSTEM,
        UNIT_SYSTEM_TAG,
        defaultVal: UNIT_SYSTEM_DEFAULT,
        desc: UNIT_SYSTEM_DESCRIPTION,
      ),
      SwitchPreference(
        INSTANT_SCAN,
        INSTANT_SCAN_TAG,
        defaultVal: INSTANT_SCAN_DEFAULT,
        desc: INSTANT_SCAN_DESCRIPTION,
      ),
      SwitchPreference(
        AUTO_CONNECT,
        AUTO_CONNECT_TAG,
        defaultVal: AUTO_CONNECT_DEFAULT,
        desc: AUTO_CONNECT_DESCRIPTION,
      ),
      SwitchPreference(
        INSTANT_MEASUREMENT_START,
        INSTANT_MEASUREMENT_START_TAG,
        defaultVal: INSTANT_MEASUREMENT_START_DEFAULT,
        desc: INSTANT_MEASUREMENT_START_DESCRIPTION,
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
        MULTI_SPORT_DEVICE_SUPPORT,
        MULTI_SPORT_DEVICE_SUPPORT_TAG,
        defaultVal: MULTI_SPORT_DEVICE_SUPPORT_DEFAULT,
        desc: MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION,
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
      PreferenceTitle(THROTTLE_POWER_DESCRIPTION, style: descriptionStyle),
      TextFieldPreference(
        THROTTLE_POWER,
        THROTTLE_POWER_TAG,
        defaultVal: THROTTLE_POWER_DEFAULT,
        validator: (str) {
          if (!isNumber(str, 0.0, 100.0)) {
            return "Invalid throttle (should be 0.0 <= percent <= 100.0)";
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
      PreferenceTitle(STROKE_RATE_SMOOTHING_DESCRIPTION, style: descriptionStyle),
      TextFieldPreference(
        STROKE_RATE_SMOOTHING,
        STROKE_RATE_SMOOTHING_TAG,
        defaultVal: STROKE_RATE_SMOOTHING_DEFAULT,
        validator: (str) {
          if (!isNumber(str, 1.0, 50.0)) {
            return "Invalid window size (should be 1.0 <= size <= 50.0)";
          }
          return null;
        },
      ),
      PreferenceTitle(WORKAROUND_PREFERENCES),
      PreferenceTitle(EQUIPMENT_DISCONNECTION_WATCHDOG_DESCRIPTION, style: descriptionStyle),
      TextFieldPreference(
        EQUIPMENT_DISCONNECTION_WATCHDOG,
        EQUIPMENT_DISCONNECTION_WATCHDOG_TAG,
        defaultVal: EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT,
        validator: (str) {
          if (!isNumber(str, 0.0, 50.0)) {
            return "Invalid window size (should be 0.0 <= size <= 50.0)";
          }
          return null;
        },
      ),
      SwitchPreference(
        CALORIE_CARRYOVER_WORKAROUND,
        CALORIE_CARRYOVER_WORKAROUND_TAG,
        defaultVal: CALORIE_CARRYOVER_WORKAROUND_DEFAULT,
        desc: CALORIE_CARRYOVER_WORKAROUND_DESCRIPTION,
      ),
      SwitchPreference(
        CADENCE_GAP_PATCHING_WORKAROUND,
        CADENCE_GAP_PATCHING_WORKAROUND_TAG,
        defaultVal: CADENCE_GAP_PATCHING_WORKAROUND_DEFAULT,
        desc: CADENCE_GAP_PATCHING_WORKAROUND_DESCRIPTION,
      ),
    ];

    PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
      appPreferences.add(PreferenceTitle(sport + ZONE_PREFERENCES));
      PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
        appPreferences.addAll([
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
        appPreferences.addAll([
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

    appPreferences.addAll([
      PreferenceTitle(EXPERT_PREFERENCES),
      PreferenceTitle(DATA_CONNECTION_ADDRESSES_DESCRIPTION, style: descriptionStyle),
      TextFieldPreference(
        DATA_CONNECTION_ADDRESSES,
        DATA_CONNECTION_ADDRESSES_TAG,
        defaultVal: DATA_CONNECTION_ADDRESSES_DEFAULT,
        validator: (str) {
          final addressTuples = parseIpAddresses(str);
          if (addressTuples == null || addressTuples.isEmpty) {
            return "Invalid or empty addresses, default DNS servers will be used";
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration";
            }
          }
          return null;
        },
      ),
    ]);

    if (kDebugMode) {
      appPreferences.add(SwitchPreference(
        APP_DEBUG_MODE,
        APP_DEBUG_MODE_TAG,
        defaultVal: APP_DEBUG_MODE_DEFAULT,
        desc: APP_DEBUG_MODE_DESCRIPTION,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Preferences')),
      body: PreferencePage(appPreferences),
    );
  }
}
