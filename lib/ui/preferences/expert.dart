import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:share_plus/share_plus.dart';

import '../../persistence/isar/activity.dart';
import '../../persistence/isar/calorie_tune.dart';
import '../../persistence/isar/device_usage.dart';
import '../../persistence/isar/floor_migration.dart';
import '../../persistence/isar/floor_record_migration.dart';
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
import '../../utils/date_time_ex.dart';
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

          final Directory tempDir = await getTemporaryDirectory();
          final fileNameStub = "DebugLogs_${DateTimeEx.namePart}";
          final fileName = "$fileNameStub.csv";
          final logFilePath = "${tempDir.path}/$fileName";
          final logFile = await File(logFilePath).create();
          await Logging().exportLogs(logFile);

          final prefService = Get.find<BasePrefService>();
          final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
          const logTag = "LOG_EXPORT";
          final zipFilePath = "${tempDir.path}/$fileNameStub.zip";
          debugPrint("zip file: $zipFilePath");
          final zipFile = await File(zipFilePath).create();
          bool zipped = false;
          try {
            await ZipFile.createFromFiles(sourceDir: tempDir, files: [logFile], zipFile: zipFile);
            zipped = true;
          } on Exception catch (e, stack) {
            Logging().logException(
                logLevel, logTag, "ZipFile.createFromFiles", "error during creation", e, stack);
          }

          await logFile.delete();
          if (!zipped) {
            Get.snackbar("Log export failed", "Unsuccessful zipping");
            return;
          }

          final title = "Debug Logs ${DateTimeEx.isoDateTime}";
          final result = await Share.shareXFiles([XFile(zipFile.path)], text: title);
          Logging().log(logLevel, logLevelInfo, logTag, "Share.shareXFiles", "${result.status}");
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
          final Directory tempDir = await getTemporaryDirectory();
          final databaseFilePath = "${tempDir.path}/${Isar.defaultName}.isar";
          await database.copyToFile(databaseFilePath);
          final databaseFile = File(databaseFilePath);
          final List<File> files = [databaseFile];
          final prefService = Get.find<BasePrefService>();
          final settingsBytes = utf8.encode(jsonEncode(prefService.toMap()));
          final settingsFile = File("${tempDir.path}/preferences.json");
          files.add(await settingsFile.writeAsBytes(settingsBytes, flush: true));
          final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
          const logTag = "DATA_EXPORT";
          final zipFilePath = "${tempDir.path}/DataExport_${DateTimeEx.namePart}.zip";
          debugPrint("zip file: $zipFilePath");
          final zipFile = File(zipFilePath);
          bool zipped = false;
          try {
            await ZipFile.createFromFiles(sourceDir: tempDir, files: files, zipFile: zipFile);
            zipped = true;
          } on Exception catch (e, stack) {
            Logging().logException(
                logLevel, logTag, "ZipFile.createFromFiles", "error during creation", e, stack);
          }

          await settingsFile.delete();
          await databaseFile.delete();
          if (!zipped) {
            Get.snackbar("Export failed", "Unsuccessful zipping");
            return;
          }

          final result = await Share.shareXFiles([XFile(zipFilePath)], text: "Exported DB");
          Logging().log(logLevel, logLevelInfo, logTag, "Share.shareXFiles", "${result.status}");
        },
        child: const Text(dataExport),
      ),
      PrefButton(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            Get.snackbar("Import started", "In progress...");

            final zipFilePath = result.files.single.path;
            if (zipFilePath == null) {
              Get.snackbar("Import failed", "No file selected?");
              return;
            }

            if (zipFilePath.endsWith(".bin.gz")) {
              Get.snackbar("Old export format",
                  "Please upgrade the app on the source device and export again");
              return;
            }

            final database = Get.find<Isar>();
            final databasePath = database.path;
            final databaseDirectory = database.directory;
            if (databasePath == null || databaseDirectory == null) {
              Get.snackbar("Import failed", "Cannot locate target database file");
              return;
            }

            final prefService = Get.find<BasePrefService>();
            final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
            const logTag = "DATA_IMPORT";
            final zipFile = File(zipFilePath);
            final Directory tempDir = await getTemporaryDirectory();
            try {
              ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: tempDir);
            } on Exception catch (e, stack) {
              Logging().logException(logLevel, logTag, "ZipFile.extractToDirectory",
                  "error during extraction", e, stack);
            }

            final sourceDatabaseFilePath = "${tempDir.path}/${Isar.defaultName}.isar";
            database.close(deleteFromDisk: true);
            final sourceDatabaseFile = File(sourceDatabaseFilePath);
            File? newDatabaseFile;
            // https://stackoverflow.com/questions/54692763/flutter-how-to-move-file
            try {
              // prefer using rename as it is probably faster
              newDatabaseFile = await sourceDatabaseFile.rename(databasePath);
            } on FileSystemException catch (e) {
              // if rename fails, (probably because they are on different file systems)
              // copy the source file and then delete it
              debugPrint(e.toString());
              newDatabaseFile = await sourceDatabaseFile.copy(databasePath);
              await sourceDatabaseFile.delete();
            }

            debugPrint(newDatabaseFile.path);
            final databaseFileName = databasePath.split("/").last;
            await Get.delete<Isar>(force: true);
            final isar = await Isar.open([
              ActivitySchema,
              CalorieTuneSchema,
              DeviceUsageSchema,
              FloorMigrationSchema,
              FloorRecordMigrationSchema,
              LogEntrySchema,
              PowerTuneSchema,
              RecordSchema,
              WorkoutSummarySchema,
            ], directory: databaseDirectory, name: databaseFileName);
            Get.put<Isar>(isar, permanent: true);

            final settingsFile = File("${tempDir.path}/preferences.json");
            final settingsBytes = await settingsFile.readAsBytes();
            final settingsJson = jsonDecode(utf8.decode(settingsBytes));
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
