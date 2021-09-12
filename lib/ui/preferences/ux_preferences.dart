import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class UXPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "UX";
  static String title = "$shortTitle Preferences";

  const UXPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> uxPreferences = [
      const PrefLabel(
        title: Text(THEME_SELECTION),
        subtitle: Text(THEME_SELECTION_DESCRIPTION),
      ),
      const PrefRadio<String>(
        title: Text(THEME_SELECTION_SYSTEM_DESCRIPTION),
        value: THEME_SELECTION_SYSTEM,
        pref: THEME_SELECTION_TAG,
      ),
      const PrefRadio<String>(
        title: Text(THEME_SELECTION_LIGHT_DESCRIPTION),
        value: THEME_SELECTION_LIGHT,
        pref: THEME_SELECTION_TAG,
      ),
      const PrefRadio<String>(
        title: Text(THEME_SELECTION_DARK_DESCRIPTION),
        value: THEME_SELECTION_DARK,
        pref: THEME_SELECTION_TAG,
      ),
      const PrefLabel(title: Divider(height: 1)),
      const PrefCheckbox(
        title: Text(UNIT_SYSTEM),
        subtitle: Text(UNIT_SYSTEM_DESCRIPTION),
        pref: UNIT_SYSTEM_TAG,
      ),
      const PrefCheckbox(
        title: Text(DISTANCE_RESOLUTION),
        subtitle: Text(DISTANCE_RESOLUTION_DESCRIPTION),
        pref: DISTANCE_RESOLUTION_TAG,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(SCAN_DURATION),
        subtitle: const Text(SCAN_DURATION_DESCRIPTION),
        pref: SCAN_DURATION_TAG,
        trailing: (num value) => Text("$value s"),
        min: SCAN_DURATION_MIN,
        max: SCAN_DURATION_MAX,
        direction: Axis.vertical,
      ),
      const PrefCheckbox(
        title: Text(INSTANT_SCAN),
        subtitle: Text(INSTANT_SCAN_DESCRIPTION),
        pref: INSTANT_SCAN_TAG,
      ),
      const PrefCheckbox(
        title: Text(AUTO_CONNECT),
        subtitle: Text(AUTO_CONNECT_DESCRIPTION),
        pref: AUTO_CONNECT_TAG,
      ),
      const PrefCheckbox(
        title: Text(INSTANT_MEASUREMENT_START),
        subtitle: Text(INSTANT_MEASUREMENT_START_DESCRIPTION),
        pref: INSTANT_MEASUREMENT_START_TAG,
      ),
      const PrefCheckbox(
        title: Text(INSTANT_UPLOAD),
        subtitle: Text(INSTANT_UPLOAD_DESCRIPTION),
        pref: INSTANT_UPLOAD_TAG,
      ),
      const PrefCheckbox(
        title: Text(MULTI_SPORT_DEVICE_SUPPORT),
        subtitle: Text(MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION),
        pref: MULTI_SPORT_DEVICE_SUPPORT_TAG,
      ),
      const PrefCheckbox(
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
