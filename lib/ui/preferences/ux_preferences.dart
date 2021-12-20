import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../preferences/auto_connect.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/instant_measurement_start.dart';
import '../../preferences/instant_scan.dart';
import '../../preferences/instant_upload.dart';
import '../../preferences/scan_duration.dart';
import '../../preferences/simpler_ui.dart';
import '../../preferences/unit_system.dart';
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
        title: Text(unitSystem),
        subtitle: Text(unitSystemDescription),
        pref: unitSystemTag,
      ),
      const PrefCheckbox(
        title: Text(distanceResolution),
        subtitle: Text(distanceResolutionDescription),
        pref: distanceResolutionTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(scanDuration),
        subtitle: const Text(scanDurationDescription),
        pref: scanDurationTag,
        trailing: (num value) => Text("$value s"),
        min: scanDurationMin,
        max: scanDurationMax,
        direction: Axis.vertical,
      ),
      const PrefCheckbox(
        title: Text(instantScan),
        subtitle: Text(instantScanDescription),
        pref: instantScanTag,
      ),
      const PrefCheckbox(
        title: Text(autoConnect),
        subtitle: Text(autoConnectDescription),
        pref: autoConnectTag,
      ),
      const PrefCheckbox(
        title: Text(instantMeasurementStart),
        subtitle: Text(instantMeasurementStartDescription),
        pref: instantMeasurementStartTag,
      ),
      const PrefCheckbox(
        title: Text(instantUpload),
        subtitle: Text(instantUploadDescription),
        pref: instantUploadTag,
      ),
      const PrefCheckbox(
        title: Text(MULTI_SPORT_DEVICE_SUPPORT),
        subtitle: Text(MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION),
        pref: MULTI_SPORT_DEVICE_SUPPORT_TAG,
      ),
      const PrefCheckbox(
        title: Text(simplerUi),
        subtitle: Text(simplerUiDescription),
        pref: simplerUiTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: uxPreferences),
    );
  }
}
