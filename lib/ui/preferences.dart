import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';
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

  bool isInteger(String str, lowerLimit, upperLimit) {
    int integer = int.tryParse(str);
    return integer != null &&
        (lowerLimit < 0 || integer >= lowerLimit) &&
        (upperLimit < 0 || integer <= upperLimit);
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
        EXTEND_TUNING,
        EXTEND_TUNING_TAG,
        defaultVal: EXTEND_TUNING_DEFAULT,
        desc: EXTEND_TUNING_DESCRIPTION,
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
        CADENCE_GAP_WORKAROUND,
        CADENCE_GAP_WORKAROUND_TAG,
        defaultVal: CADENCE_GAP_WORKAROUND_DEFAULT,
        desc: CADENCE_GAP_WORKAROUND_DESCRIPTION,
      ),
      PreferenceDialogLink(
        HEART_RATE_GAP_WORKAROUND,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION,
              DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
            RadioPreference(
              DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION,
              DATA_GAP_WORKAROUND_NO_WORKAROUND,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
            RadioPreference(
              DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION,
              DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
          ],
          title: 'Select workaround type',
          cancelText: 'Close',
        ),
      ),
      PreferenceTitle(HEART_RATE_UPPER_LIMIT_DESCRIPTION, style: descriptionStyle),
      TextFieldPreference(
        HEART_RATE_UPPER_LIMIT,
        HEART_RATE_UPPER_LIMIT_TAG,
        defaultVal: HEART_RATE_UPPER_LIMIT_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 300)) {
            return "Invalid heart rate limit (should be 0 <= size <= 300)";
          }
          return null;
        },
      ),
      PreferenceDialogLink(
        HEART_RATE_LIMITING_METHOD,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION,
              HEART_RATE_LIMITING_WRITE_ZERO,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION,
              HEART_RATE_LIMITING_WRITE_NOTHING,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION,
              HEART_RATE_LIMITING_CAP_AT_LIMIT,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_NO_LIMIT_DESCRIPTION,
              HEART_RATE_LIMITING_NO_LIMIT,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
          ],
          title: 'Select HR Limiting Method',
          cancelText: 'Close',
        ),
      ),
      PreferenceTitle(TARGET_HEART_RATE_MODE_DESCRIPTION, style: descriptionStyle),
      PreferenceDialogLink(
        TARGET_HEART_RATE_MODE,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              TARGET_HEART_RATE_MODE_NONE_DESCRIPTION,
              TARGET_HEART_RATE_MODE_NONE,
              TARGET_HEART_RATE_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_MODE_BPM_DESCRIPTION,
              TARGET_HEART_RATE_MODE_BPM,
              TARGET_HEART_RATE_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_MODE_ZONES_DESCRIPTION,
              TARGET_HEART_RATE_MODE_ZONES,
              TARGET_HEART_RATE_MODE_TAG,
            ),
          ],
          title: 'Select Target HR Method',
          cancelText: 'Close',
        ),
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_LOWER_BPM,
        TARGET_HEART_RATE_LOWER_BPM_TAG,
        defaultVal: TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
        validator: (str) {
          final upperLimitString = PrefService.getString(TARGET_HEART_RATE_UPPER_BPM_TAG) ?? TARGET_HEART_RATE_UPPER_BPM_DEFAULT;
          final upperLimit = int.tryParse(upperLimitString);
          if (!isInteger(str, 0, upperLimit)) {
            return "Invalid lower target HR (should be 0 <= size <= $upperLimit)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_UPPER_BPM,
        TARGET_HEART_RATE_UPPER_BPM_TAG,
        defaultVal: TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
        validator: (str) {
          final lowerLimitString = PrefService.getString(TARGET_HEART_RATE_LOWER_BPM_TAG) ?? TARGET_HEART_RATE_LOWER_BPM_DEFAULT;
          final lowerLimit = int.tryParse(lowerLimitString);
          if (!isInteger(str, lowerLimit, 300)) {
            return "Invalid heart rate limit (should be $lowerLimit <= size <= 300)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_LOWER_ZONE,
        TARGET_HEART_RATE_LOWER_ZONE_TAG,
        defaultVal: TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
        validator: (str) {
          final upperLimitString = PrefService.getString(TARGET_HEART_RATE_UPPER_ZONE_TAG) ?? TARGET_HEART_RATE_UPPER_ZONE_DEFAULT;
          final upperLimit = int.tryParse(upperLimitString);
          if (!isInteger(str, 0, upperLimit)) {
            return "Invalid lower zone (should be 0 <= size <= $upperLimit)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_UPPER_ZONE,
        TARGET_HEART_RATE_UPPER_ZONE_TAG,
        defaultVal: TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
        validator: (str) {
          final lowerLimitString = PrefService.getString(TARGET_HEART_RATE_LOWER_ZONE_TAG) ?? TARGET_HEART_RATE_LOWER_ZONE_DEFAULT;
          final lowerLimit = int.tryParse(lowerLimitString);
          if (!isInteger(str, lowerLimit, 7)) {
            return "Invalid upper zone (should be $lowerLimit <= size <= 300)";
          }
          return null;
        },
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
