// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/data_connection_addresses.dart';
import '../../preferences/device_filtering.dart';
import '../../preferences/enforced_time_zone.dart';
import '../../preferences/log_level.dart';
import '../../utils/logging.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class ExpertPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";
  final List<String> timeZoneChoices;

  const ExpertPreferencesScreen({Key? key, required this.timeZoneChoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> expertPreferences = [
      const PrefLabel(title: Text(dataConnectionAddressesDescription, maxLines: 10)),
      PrefText(
        label: dataConnectionAddresses,
        pref: dataConnectionAddressesTag,
        validator: (str) {
          if (str == null) {
            return null;
          }

          final addressTuples = parseIpAddresses(str);
          if (addressTuples.isEmpty) {
            return null;
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration";
            }
          }

          return null;
        },
      ),
      PrefButton(
        onTap: () async {
          if (await hasInternetConnection()) {
            Get.snackbar("Info", "Data connection detected");
          } else {
            Get.snackbar("Warning", "No data connection detected");
          }
        },
        child: const Text("Apply Configuration and Test"),
      ),
      const PrefCheckbox(
        title: Text(deviceFiltering),
        subtitle: Text(deviceFilteringDescription),
        pref: deviceFilteringTag,
      ),
      PrefDropdown<String>(
        title: const Text(enforcedTimeZone),
        subtitle: const Text(enforcedTimeZoneDescription),
        pref: enforcedTimeZoneTag,
        items: timeZoneChoices
            .map((timeZone) => DropdownMenuItem(value: timeZone, child: Text(timeZone)))
            .toList(growable: false),
      ),
      const PrefLabel(title: Divider(height: 1)),
      const PrefLabel(
        title: Text(logLevel),
        subtitle: Text(logLevelDescription),
      ),
      PrefRadio<int>(
        title: const Text(logLevelNoneDescription),
        value: logLevelNone,
        pref: logLevelTag,
        onSelect: () async => await Logging.init(logLevelNone),
      ),
      PrefRadio<int>(
        title: const Text(logLevelErrorDescription),
        value: logLevelError,
        pref: logLevelTag,
        onSelect: () async => await Logging.init(logLevelError),
      ),
      PrefRadio<int>(
        title: const Text(logLevelWarningDescription),
        value: logLevelWarning,
        pref: logLevelTag,
        onSelect: () async => await Logging.init(logLevelWarning),
      ),
      PrefRadio<int>(
        title: const Text(logLevelInfoDescription),
        value: logLevelInfo,
        pref: logLevelTag,
        onSelect: () async => await Logging.init(logLevelInfo),
      ),
      PrefButton(
        onTap: () async {
          if (Logging.initialized) {
            FlutterLogs.exportLogs(exportType: ExportType.ALL);
            final String zipName = await Logging.completer.future;
            Directory externalDirectory;
            if (Platform.isIOS) {
              externalDirectory = await getApplicationDocumentsDirectory();
            } else {
              final nullableDirectory = await getExternalStorageDirectory();
              if (nullableDirectory == null) {
                Get.snackbar("Export", "Could not locate an external target directory");
                return;
              }

              externalDirectory = nullableDirectory;
            }

            File file = File("${externalDirectory.path}/$zipName");
            final title = "Debug Logs ${DateTime.now().toUtc().toIso8601String()}";
            final fileName = zipName.split("/").last;
            if (file.existsSync()) {
              ShareFilesAndScreenshotWidgets().shareFile(
                title,
                fileName,
                await file.readAsBytes(),
                "application/zip",
                text: title,
              );
            } else {
              Get.snackbar("Export", "File not found");
            }
          } else {
            Get.snackbar("Warning", "Logging is not initialized");
          }
        },
        child: const Text("Exporting Logs..."),
      ),
      PrefButton(
        onTap: () {
          if (Logging.initialized) {
            FlutterLogs.clearLogs();
          } else {
            Get.snackbar("Warning", "Logging is not initialized");
          }
        },
        child: const Text("Clear All Logs"),
      ),
    ];

    if (kDebugMode) {
      expertPreferences.add(const PrefCheckbox(
        title: Text(appDebugMode),
        subtitle: Text(appDebugModeDescription),
        pref: appDebugModeTag,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: expertPreferences),
    );
  }
}
