import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
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
import '../../providers/theme_mode.dart';
import '../parts/pick_directory.dart';
import 'preferences_screen_mixin.dart';
import 'row_configuration_dialog.dart';

class UXPreferencesScreen extends ConsumerStatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "UX";
  static String title = "$shortTitle Preferences";

  const UXPreferencesScreen({Key? key}) : super(key: key);

  @override
  UXPreferencesScreenState createState() => UXPreferencesScreenState();
}

class UXPreferencesScreenState extends ConsumerState<UXPreferencesScreen> {
  int _locationEdit = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> uxPreferences = [
      PrefLabel(
        title: Text(themeSelection, style: Get.textTheme.headline5!, maxLines: 3),
        subtitle: const Text(themeSelectionDescription),
      ),
      PrefRadio<String>(
        title: const Text(themeSelectionSystemDescription),
        value: themeSelectionSystem,
        pref: themeSelectionTag,
        onSelect: () {
          final isDark = Get.isPlatformDarkMode;
          final theme = isDark ? ThemeData.dark() : ThemeData.light();
          setState(() {
            Get.changeThemeMode(ThemeMode.system);
            Get.changeTheme(theme);
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.system);
            Get.changeTheme(theme);
          });
          ref.read(themeModeProvider.state).state = ThemeMode.system;
          setState(() {
            Get.changeThemeMode(ThemeMode.system);
            Get.changeTheme(theme);
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.system);
            Get.changeTheme(theme);
          });
        }
      ),
      PrefRadio<String>(
        title: const Text(themeSelectionLightDescription),
        value: themeSelectionLight,
        pref: themeSelectionTag,
        onSelect: () {
          setState(() {
            Get.changeThemeMode(ThemeMode.light);
            Get.changeTheme(ThemeData.light());
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.light);
            Get.changeTheme(ThemeData.light());
          });
          ref.read(themeModeProvider.state).state = ThemeMode.light;
          setState(() {
            Get.changeThemeMode(ThemeMode.light);
            Get.changeTheme(ThemeData.light());
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.light);
            Get.changeTheme(ThemeData.light());
          });
        }
      ),
      PrefRadio<String>(
        title: const Text(themeSelectionDarkDescription),
        value: themeSelectionDark,
        pref: themeSelectionTag,
        onSelect: () {
          setState(() {
            Get.changeThemeMode(ThemeMode.dark);
            Get.changeTheme(ThemeData.dark());
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.dark);
            Get.changeTheme(ThemeData.dark());
          });
          ref.read(themeModeProvider.state).state = ThemeMode.dark;
          setState(() {
            Get.changeThemeMode(ThemeMode.dark);
            Get.changeTheme(ThemeData.dark());
          });
          setState(() {
            Get.changeThemeMode(ThemeMode.dark);
            Get.changeTheme(ThemeData.dark());
          });
        }
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
        title: Text(instantExport),
        subtitle: Text(instantExportDescription),
        pref: instantExportTag,
      ),
      // PrefLabel(
      //   title: Text(instantExportLocation, style: Get.textTheme.headline5!, maxLines: 3),
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
          final path = await pickDirectory(context, existingPath);
          if (path.isNotEmpty) {
            setState(() {
              _locationEdit++;
              PrefService.of(context).set(instantExportLocationTag, path);
            });
          }
        },
        child: const Text(instantExportLocationPickCommand),
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
      appBar: AppBar(title: Text(UXPreferencesScreen.title)),
      body: PrefPage(children: uxPreferences),
    );
  }
}
