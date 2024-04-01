import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:pref/pref.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

import '../../persistence/isar/activity.dart';
import '../../persistence/isar/calorie_tune.dart';
import '../../persistence/isar/device_usage.dart';
import '../../persistence/isar/log_entry.dart';
import '../../persistence/isar/power_tune.dart';
import '../../persistence/isar/record.dart';
import '../../persistence/isar/workout_summary.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/data_connection_addresses.dart';
import '../../preferences/database_location.dart';
import '../../preferences/device_filtering.dart';
import '../../preferences/enable_asserts.dart';
import '../../preferences/log_level.dart';
import '../../preferences/recalculate_more.dart';
import '../../preferences/show_performance_overlay.dart';
import '../../utils/export.dart';
import '../../utils/logging.dart';
import '../../utils/preferences.dart';
import '../parts/pick_directory.dart';
import 'preferences_screen_mixin.dart';

class ExpertPreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";

  const ExpertPreferencesScreen({super.key});

  @override
  ExpertPreferencesScreenState createState() => ExpertPreferencesScreenState();
}

class ExpertPreferencesScreenState extends State<ExpertPreferencesScreen> {
  int _locationEdit = 0;

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
          final fileName = "DebugLogs${isoDateTime.replaceAll(RegExp(r'[^\w\s]+'), '')}.txt.gz";
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
      PrefLabel(
        title: Text(databaseLocation, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(databaseLocationDescription),
      ),
      PrefText(
        key: Key("databaseLocation$_locationEdit"),
        label: databaseLocationPasteCommand,
        pref: databaseLocationTag,
      ),
      PrefButton(
        onTap: () async {
          final existingPath = PrefService.of(context).get(databaseLocationTag);
          final path = await pickDirectory(context, databaseLocationPickerTitle, existingPath);
          if (path.isNotEmpty) {
            setState(() {
              _locationEdit++;
              PrefService.of(context).set(databaseLocationTag, path);
            });
          }
        },
        child: const Text(databaseLocationPickCommand),
      ),
      PrefLabel(
        title: Text(dataExportImport, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(dataExportImportDescription),
      ),
      PrefButton(
        onTap: () async {
          Get.snackbar("Export started", "In progress...");

          final database = Get.find<Isar>();
          final allBytes = BytesBuilder(copy: false);

          await database.txn(() async {
            await database.records.where().exportJsonRaw((recordBytes) {
              allBytes.add(lengthToBytes(recordBytes.length));
              allBytes.add(recordBytes);
            });
          });

          await database.txn(() async {
            await database.activitys.where().exportJsonRaw((activityBytes) {
              allBytes.add(lengthToBytes(activityBytes.length));
              allBytes.add(activityBytes);
            });
          });

          await database.txn(() async {
            await database.logEntrys.where().exportJsonRaw((logBytes) {
              allBytes.add(lengthToBytes(logBytes.length));
              allBytes.add(logBytes);
            });
          });

          await database.txn(() async {
            await database.workoutSummarys.where().exportJsonRaw((workoutBytes) {
              allBytes.add(lengthToBytes(workoutBytes.length));
              allBytes.add(workoutBytes);
            });
          });

          await database.txn(() async {
            await database.powerTunes.where().exportJsonRaw((powerBytes) {
              allBytes.add(lengthToBytes(powerBytes.length));
              allBytes.add(powerBytes);
            });
          });

          await database.txn(() async {
            await database.deviceUsages.where().exportJsonRaw((deviceBytes) {
              allBytes.add(lengthToBytes(deviceBytes.length));
              allBytes.add(deviceBytes);
            });
          });

          await database.txn(() async {
            await database.calorieTunes.where().exportJsonRaw((calorieBytes) {
              allBytes.add(lengthToBytes(calorieBytes.length));
              allBytes.add(calorieBytes);
            });
          });

          final prefService = Get.find<BasePrefService>();
          final settingsBytes = utf8.encode(jsonEncode(prefService.toMap()));
          allBytes.add(lengthToBytes(settingsBytes.length));
          allBytes.add(settingsBytes);

          final compressedBytes = GZipCodec(gzip: true).encode(allBytes.toBytes());
          final isoDateTime = DateTime.now().toUtc().toIso8601String();
          final title = "Data Export $isoDateTime";
          final fileName = "DataExport${isoDateTime.replaceAll(RegExp(r'[^\w\s]+'), '')}.bin.gz";
          ShareFilesAndScreenshotWidgets().shareFile(
            title,
            fileName,
            Uint8List.fromList(compressedBytes),
            'application/x-gzip',
            text: title,
          );
        },
        child: const Text(dataExport),
      ),
      PrefButton(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            Get.snackbar("Import started", "In progress...");

            final file = File(result.files.single.path!);
            final compressedContents = await file.readAsBytes();
            final contents = GZipCodec(gzip: true).decode(compressedContents);
            final database = Get.find<Isar>();

            var skip = 0;
            final recordLength = lengthBytesToInt(contents.take(4).toList(growable: false));
            skip += 4;
            if (recordLength > 2) {
              final recordBytes = Uint8List.fromList(
                  contents.skip(skip).take(recordLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.records.importJsonRaw(recordBytes);
              });
            }

            skip += recordLength;
            final activityLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (activityLength > 2) {
              final activityBytes = Uint8List.fromList(
                  contents.skip(skip).take(activityLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.activitys.importJsonRaw(activityBytes);
              });
            }

            skip += activityLength;
            final logLength = lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (logLength > 2) {
              final logBytes =
                  Uint8List.fromList(contents.skip(skip).take(logLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.logEntrys.importJsonRaw(logBytes);
              });
            }

            skip += logLength;
            final workoutLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (workoutLength > 2) {
              final workoutBytes = Uint8List.fromList(
                  contents.skip(skip).take(workoutLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.workoutSummarys.importJsonRaw(workoutBytes);
              });
            }

            skip += workoutLength;
            final powerLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (powerLength > 2) {
              final powerBytes =
                  Uint8List.fromList(contents.skip(skip).take(powerLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.powerTunes.importJsonRaw(powerBytes);
              });
            }

            skip += powerLength;
            final deviceLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (deviceLength > 2) {
              final deviceBytes = Uint8List.fromList(
                  contents.skip(skip).take(deviceLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.deviceUsages.importJsonRaw(deviceBytes);
              });
            }

            skip += deviceLength;
            final calorieLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            if (calorieLength > 2) {
              final calorieBytes = Uint8List.fromList(
                  contents.skip(skip).take(calorieLength).toList(growable: false));
              await database.writeTxn(() async {
                await database.calorieTunes.importJsonRaw(calorieBytes);
              });
            }

            skip += calorieLength;
            final settingsLength =
                lengthBytesToInt(contents.skip(skip).take(4).toList(growable: false));
            skip += 4;
            final settingsBytes = Uint8List.fromList(
                contents.skip(skip).take(settingsLength).toList(growable: false));
            final settingsJson = jsonDecode(utf8.decode(settingsBytes));
            final prefService = Get.find<BasePrefService>();
            prefService.fromMap(settingsJson);

            Get.snackbar("Import finished", "Success!!");
          }
        },
        child: const Text(dataImport),
      ),
    ];

    expertPreferences.add(const PrefCheckbox(
      title: Text(showPerformanceOverlay),
      subtitle: Text(showPerformanceOverlayDescription),
      pref: showPerformanceOverlayTag,
    ));

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
      expertPreferences.add(const PrefCheckbox(
        title: Text(recalculateMore),
        subtitle: Text(recalculateMoreDescription),
        pref: recalculateMoreTag,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(ExpertPreferencesScreen.title)),
      body: PrefPage(children: expertPreferences),
    );
  }
}
