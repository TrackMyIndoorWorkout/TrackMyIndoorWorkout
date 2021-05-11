import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class UXPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "UX";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> uxPreferences = [
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
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(uxPreferences),
    );
  }
}
