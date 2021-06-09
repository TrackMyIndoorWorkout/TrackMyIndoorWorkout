import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class UXPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "UX";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> uxPreferences = [
      PrefLabel(
        title: Text(THEME_SELECTION),
        subtitle: Text(THEME_SELECTION_DESCRIPTION),
      ),
      PrefRadio<String>(
        title: Text(THEME_SELECTION_SYSTEM_DESCRIPTION),
        value: THEME_SELECTION_SYSTEM,
        pref: THEME_SELECTION_TAG,
      ),
      PrefRadio<String>(
        title: Text(THEME_SELECTION_LIGHT_DESCRIPTION),
        value: THEME_SELECTION_LIGHT,
        pref: THEME_SELECTION_TAG,
      ),
      PrefRadio<String>(
        title: Text(THEME_SELECTION_DARK_DESCRIPTION),
        value: THEME_SELECTION_DARK,
        pref: THEME_SELECTION_TAG,
      ),
      PrefLabel(title: Divider(height: 1)),
      PrefCheckbox(
        title: Text(UNIT_SYSTEM),
        subtitle: Text(UNIT_SYSTEM_DESCRIPTION),
        pref: UNIT_SYSTEM_TAG,
      ),
      PrefCheckbox(
        title: Text(INSTANT_SCAN),
        subtitle: Text(INSTANT_SCAN_DESCRIPTION),
        pref: INSTANT_SCAN_TAG,
      ),
      PrefCheckbox(
        title: Text(AUTO_CONNECT),
        subtitle: Text(AUTO_CONNECT_DESCRIPTION),
        pref: AUTO_CONNECT_TAG,
      ),
      PrefCheckbox(
        title: Text(INSTANT_MEASUREMENT_START),
        subtitle: Text(INSTANT_MEASUREMENT_START_DESCRIPTION),
        pref: INSTANT_MEASUREMENT_START_TAG,
      ),
      PrefCheckbox(
        title: Text(INSTANT_UPLOAD),
        subtitle: Text(INSTANT_UPLOAD_DESCRIPTION),
        pref: INSTANT_UPLOAD_TAG,
      ),
      PrefCheckbox(
        title: Text(MULTI_SPORT_DEVICE_SUPPORT),
        subtitle: Text(MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION),
        pref: MULTI_SPORT_DEVICE_SUPPORT_TAG,
      ),
      PrefCheckbox(
        title: Text(SIMPLER_UI),
        subtitle: Text(SIMPLER_UI_DESCRIPTION),
        pref: SIMPLER_UI_TAG,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: uxPreferences),
    );
  }
}
