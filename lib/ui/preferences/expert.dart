import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/data_connection_addresses.dart';
import '../../preferences/device_filtering.dart';
import '../../preferences/enable_asserts.dart';
import '../../preferences/log_level.dart';
import '../../utils/logging.dart';
import '../../utils/preferences.dart';
import 'preferences_screen_mixin.dart';

class ExpertPreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";

  const ExpertPreferencesScreen({Key? key}) : super(key: key);

  @override
  ExpertPreferencesScreenState createState() => ExpertPreferencesScreenState();
}

class ExpertPreferencesScreenState extends State<ExpertPreferencesScreen> {
  Future<void> displayNoLogsDialog() async {
    await Get.defaultDialog(
      title: "Nothing to Export",
      middleText: "",
      confirm: TextButton(
        child: const Text("Dismiss"),
        onPressed: () => Get.close(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> expertPreferences = [
      const PrefLabel(title: Text(dataConnectionAddressesDescription, maxLines: 10)),
      PrefText(
        label: dataConnectionAddresses,
        pref: dataConnectionAddressesTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\d.:,]"))],
        validator: (str) {
          if (str == null) {
            return null;
          }

          final addressTuples = parseNetworkAddresses(str);
          if (addressTuples.isEmpty) {
            return null;
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration: count doesn't match";
            }

            for (final addressTuple in addressTuples) {
              if (isDummyAddress(addressTuple)) {
                return "There's some malformed address(es) in the configuration";
              }
            }
          }

          return null;
        },
      ),
      PrefButton(
        onTap: () async {
          if (await hasInternetConnection()) {
            await Get.defaultDialog(
              title: "Data connection detected",
              middleText: "",
              confirm: TextButton(
                child: const Text("Dismiss"),
                onPressed: () => Get.close(1),
              ),
            );
          } else {
            await Get.defaultDialog(
              title: "No data connection detected",
              middleText: "",
              confirm: TextButton(
                child: const Text("Dismiss"),
                onPressed: () => Get.close(1),
              ),
            );
          }
        },
        child: const Text("Apply Configuration and Test"),
      ),
      const PrefCheckbox(
        title: Text(deviceFiltering),
        subtitle: Text(deviceFilteringDescription),
        pref: deviceFilteringTag,
      ),
      const PrefCheckbox(
        title: Text(blockSignalStartStop),
        subtitle: Text(blockSignalStartStopDescription),
        pref: blockSignalStartStopTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefLabel(
        title: Text(logLevelTitle, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(logLevelDescription),
      ),
      const PrefRadio<int>(
        title: Text(logLevelNoneDescription),
        value: logLevelNone,
        pref: logLevelTag,
      ),
      const PrefRadio<int>(
        title: Text(logLevelErrorDescription),
        value: logLevelError,
        pref: logLevelTag,
      ),
      const PrefRadio<int>(
        title: Text(logLevelWarningDescription),
        value: logLevelWarning,
        pref: logLevelTag,
      ),
      const PrefRadio<int>(
        title: Text(logLevelInfoDescription),
        value: logLevelInfo,
        pref: logLevelTag,
      ),
      PrefButton(
        onTap: () async {
          if (!Logging().hasLogs()) {
            await displayNoLogsDialog();
            return;
          }

          final fileBytes = await Logging().exportLogs();
          final isoDateTime = DateTime.now().toUtc().toIso8601String();
          final title = "Debug Logs $isoDateTime";
          final fileName = "DebugLogs${isoDateTime.replaceAll(RegExp(r'[^\w\s]+'), '')}.csv.gz";
          ShareFilesAndScreenshotWidgets().shareFile(
            title,
            fileName,
            Uint8List.fromList(fileBytes),
            'application/x-gzip',
            text: title,
          );
        },
        child: const Text("Export Logs..."),
      ),
      PrefButton(
        onTap: () async {
          Logging().clearLogs();

          Get.defaultDialog(
            title: "Logs cleared",
            middleText: "",
            confirm: TextButton(
              child: const Text("Dismiss"),
              onPressed: () => Get.close(1),
            ),
          );
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
      expertPreferences.add(const PrefCheckbox(
        title: Text(enableAsserts),
        subtitle: Text(enableAssertsDescription),
        pref: enableAssertsTag,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(ExpertPreferencesScreen.title)),
      body: PrefPage(children: expertPreferences),
    );
  }
}
