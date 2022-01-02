import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/auto_connect.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/instant_measurement_start.dart';
import '../../preferences/instant_scan.dart';
import '../../preferences/instant_upload.dart';
import '../../preferences/measurement_font_size_adjust.dart';
import '../../preferences/multi_sport_device_support.dart';
import '../../preferences/scan_duration.dart';
import '../../preferences/simpler_ui.dart';
import '../../preferences/theme_selection.dart';
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
        title: Text(themeSelection),
        subtitle: Text(themeSelectionDescription),
      ),
      const PrefRadio<String>(
        title: Text(themeSelectionSystemDescription),
        value: themeSelectionSystem,
        pref: themeSelectionTag,
      ),
      const PrefRadio<String>(
        title: Text(themeSelectionLightDescription),
        value: themeSelectionLight,
        pref: themeSelectionTag,
      ),
      const PrefRadio<String>(
        title: Text(themeSelectionDarkDescription),
        value: themeSelectionDark,
        pref: themeSelectionTag,
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
        title: Text(multiSportDeviceSupport),
        subtitle: Text(multiSportDeviceSupportDescription),
        pref: multiSportDeviceSupportTag,
      ),
      const PrefCheckbox(
        title: Text(simplerUi),
        subtitle: Text(simplerUiDescription),
        pref: simplerUiTag,
      ),
      PrefSlider<int>(
        title: const Text(measurementFontSizeAdjust),
        subtitle: const Text(measurementFontSizeAdjustDescription),
        pref: measurementFontSizeAdjustTag,
        trailing: (num value) => Text("$value %"),
        min: measurementFontSizeAdjustMin,
        max: measurementFontSizeAdjustMax,
        direction: Axis.vertical,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: uxPreferences),
    );
  }
}
