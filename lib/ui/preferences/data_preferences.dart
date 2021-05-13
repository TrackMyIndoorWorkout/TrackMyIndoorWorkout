import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class DataPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Data";
  static String title = "$shortTitle Prefs";

  @override
  Widget build(BuildContext context) {
    List<Widget> dataPreferences = [
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
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(dataPreferences),
    );
  }
}
