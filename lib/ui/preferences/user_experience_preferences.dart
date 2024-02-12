import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/activity_ui.dart';
import '../../preferences/auto_connect.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/instant_export.dart';
import '../../preferences/instant_measurement_start.dart';
import '../../preferences/instant_scan.dart';
import '../../preferences/instant_upload.dart';
import '../../preferences/measurement_font_size_adjust.dart';
import '../../preferences/multi_sport_device_support.dart';
import '../../preferences/scan_duration.dart';
import '../../preferences/simpler_ui.dart';
import '../../preferences/theme_selection.dart';
import '../../preferences/two_column_layout.dart';
import '../../preferences/unit_system.dart';
import '../parts/pick_directory.dart';
import 'pref_integer.dart';
import 'preferences_screen_mixin.dart';
import 'row_configuration_dialog.dart';

class UserExperiencePreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "User Experience";
  static String title = "$shortTitle Preferences";

  const UserExperiencePreferencesScreen({super.key});

  @override
  UserExperiencePreferencesScreenState createState() => UserExperiencePreferencesScreenState();
}

class UserExperiencePreferencesScreenState extends State<UserExperiencePreferencesScreen> {
  int _locationEdit = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> userExperiencePreferences = [
      PrefLabel(
        title: Text(themeSelection, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(themeSelectionDescription),
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
        divisions: scanDurationDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: scanDurationTag,
        min: scanDurationMin,
        max: scanDurationMax,
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
      // PrefLabel(
      //   title: Text(instantExportLocation, style: Get.textTheme.headlineSmall!, maxLines: 3),
      //   subtitle: const Text(instantExportLocationDescription),
      // ),
      PrefText(
        key: Key("instantExportLocation$_locationEdit"),
        label: instantExportLocationPasteCommand,
        pref: instantExportLocationTag,
      ),
      PrefButton(
        onTap: () async {
          final existingPath = PrefService.of(context).get(instantExportLocationTag);
          final path = await pickDirectory(context, instantExportLocationPickerTitle, existingPath);
          if (path.isNotEmpty) {
            setState(() {
              _locationEdit++;
              PrefService.of(context).set(instantExportLocationTag, path);
            });
          }
        },
        child: const Text(instantExportLocationPickCommand),
      ),
      PrefLabel(
        title: Text(activityListAndDetails, style: Get.textTheme.headlineSmall!, maxLines: 3),
      ),
      const PrefCheckbox(
        title: Text(activityListMachineNameInHeader),
        subtitle: Text(activityListMachineNameInHeaderDescription),
        pref: activityListMachineNameInHeaderTag,
      ),
      const PrefCheckbox(
        title: Text(activityListBluetoothAddressInHeader),
        subtitle: Text(activityListBluetoothAddressInHeaderDescription),
        pref: activityListBluetoothAddressInHeaderTag,
      ),
      const PrefCheckbox(
        title: Text(activityDetailsMedianDisplay),
        subtitle: Text(activityDetailsMedianDisplayDescription),
        pref: activityDetailsMedianDisplayTag,
      ),
      const PrefCheckbox(
        title: Text(instantExport),
        subtitle: Text(instantExportDescription),
        pref: instantExportTag,
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
        divisions: measurementFontSizeAdjustDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: measurementFontSizeAdjustTag,
        min: measurementFontSizeAdjustMin,
        max: measurementFontSizeAdjustMax,
      ),
      const PrefCheckbox(
        title: Text(twoColumnLayout),
        subtitle: Text(twoColumnLayoutDescription),
        pref: twoColumnLayoutTag,
      ),
      PrefButton(
        onTap: () async {
          Get.defaultDialog(
            title: "Row Setup",
            textConfirm: "Close",
            onConfirm: () => Get.close(1),
            content: const RowConfigurationDialog(),
          );
        },
        child: const Text("Measurement Row Setup"),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(UserExperiencePreferencesScreen.title)),
      body: PrefPage(children: userExperiencePreferences),
    );
  }
}
