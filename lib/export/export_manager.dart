import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';

import '../persistence/activity.dart';
import '../persistence/record.dart';
import '../preferences/instant_export.dart';
import '../preferences/log_level.dart';
import '../utils/date_time_ex.dart';
import '../utils/logging.dart';
import 'activity_export.dart';
import 'export_target.dart';
import 'fit/fit_export.dart';

enum ExportStatus { idle, exporting, success, failed }

/// Background service managing direct file exports, asynchronous file I/O,
/// and instant export workflows decoupled from UI widget lifecycles.
class ExportManager extends GetxService {
  static ExportManager get instance => Get.isRegistered<ExportManager>()
      ? Get.find<ExportManager>()
      : Get.put<ExportManager>(ExportManager(), permanent: true);

  /// Key is activity ID -> ExportStatus
  final RxMap<int, ExportStatus> _activityStatus = <int, ExportStatus>{}.obs;

  ExportStatus getStatus(int activityId) => _activityStatus[activityId] ?? ExportStatus.idle;

  bool isExporting(int activityId) => getStatus(activityId) == ExportStatus.exporting;

  /// Observable access to the status map for reactive UI widgets.
  RxMap<int, ExportStatus> get statusMap => _activityStatus;

  /// Helper to safely write bytes to disk in a background isolate to prevent
  /// UI hitches on slow SD cards, SAF mounts, or cloud-synced folders.
  static Future<File> writeBytesToFile(String filePath, List<int> bytes) async {
    final savedPath = await Isolate.run(() {
      final file = File(filePath);
      final parent = file.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }
      file.writeAsBytesSync(bytes, flush: true);
      return file.path;
    });
    return File(savedPath);
  }

  /// Exports [activity] to a file at [destinationDirectory] or [destinationPath].
  ///
  /// Serializes records and writes the file off the UI isolate.
  /// If [destinationPath] is provided, it is used directly.
  /// If [destinationDirectory] is provided, the file name is constructed via
  /// [activity.getFileNameStub()] and [exporter.fileExtension(compress)].
  Future<File?> exportActivityToFile(
    Activity activity, {
    ActivityExport? exporter,
    List<Record>? preloadedRecords,
    String? destinationPath,
    String? destinationDirectory,
    bool calculateGps = false,
    bool rawData = false,
    bool compress = false,
    int exportTarget = ExportTarget.regular,
    bool showNotification = true,
  }) async {
    final activityId = activity.id;
    if (_activityStatus[activityId] == ExportStatus.exporting) {
      debugPrint("Export already in progress for activity #$activityId");
      return null;
    }

    _activityStatus[activityId] = ExportStatus.exporting;

    try {
      final actualExporter = exporter ?? FitExport();
      final String targetPath;
      if (destinationPath != null && destinationPath.isNotEmpty) {
        targetPath = destinationPath;
      } else if (destinationDirectory != null && destinationDirectory.isNotEmpty) {
        final fileName = activity.getFileNameStub() + actualExporter.fileExtension(compress);
        targetPath = p.join(destinationDirectory, fileName);
      } else {
        throw ArgumentError("Either destinationPath or destinationDirectory must be provided");
      }

      // Generate export payload in background isolate
      final fileBytes = await actualExporter.getExport(
        activity,
        rawData,
        calculateGps,
        compress,
        exportTarget,
        preloadedRecords,
      );

      // Write bytes to disk in background isolate
      final file = await writeBytesToFile(targetPath, fileBytes);

      _activityStatus[activityId] = ExportStatus.success;

      if (showNotification) {
        final fileName = p.basename(targetPath);
        Get.snackbar("Export Finished", "Saved $fileName");
      }

      return file;
    } catch (e, stack) {
      _activityStatus[activityId] = ExportStatus.failed;

      try {
        Logging().logException(
          logLevelError,
          "ExportManager",
          "exportActivityToFile",
          "Failed exporting activity #${activity.id}",
          e is Exception ? e : Exception(e.toString()),
          stack,
        );
      } catch (_) {}

      if (showNotification) {
        Get.snackbar("Export Failed", "Error exporting activity: $e");
      }
      return null;
    }
  }

  /// Exports [activity] to a temporary directory file suitable for sharing via SharePlus.
  Future<File?> exportActivityToTempFile(
    Activity activity,
    ActivityExport exporter, {
    List<Record>? preloadedRecords,
    bool calculateGps = false,
    bool rawData = false,
    bool compress = false,
    int exportTarget = ExportTarget.regular,
  }) async {
    final Directory tempDir = await getTemporaryDirectory();
    return await exportActivityToFile(
      activity,
      exporter: exporter,
      preloadedRecords: preloadedRecords,
      destinationDirectory: tempDir.path,
      calculateGps: calculateGps,
      rawData: rawData,
      compress: compress,
      exportTarget: exportTarget,
      showNotification: false,
    );
  }

  /// Executes instant export for [activity] asynchronously, decoupled from widget lifecycles.
  ///
  /// If [destinationDirectory] is not provided, it is retrieved from the stored
  /// preference [instantExportLocationTag].
  Future<File?> runInstantExport(
    Activity activity, {
    List<Record>? preloadedRecords,
    String? destinationDirectory,
    bool calculateGps = false,
    bool showNotification = true,
  }) async {
    String? targetDir = destinationDirectory;
    if (targetDir == null || targetDir.isEmpty) {
      if (Get.isRegistered<BasePrefService>()) {
        final prefService = Get.find<BasePrefService>();
        targetDir = prefService.get<String>(instantExportLocationTag);
      }
    }

    if (targetDir == null || targetDir.isEmpty) {
      debugPrint("Instant export skipped: destination directory is not configured");
      return null;
    }

    return await exportActivityToFile(
      activity,
      exporter: FitExport(),
      preloadedRecords: preloadedRecords,
      destinationDirectory: targetDir,
      calculateGps: calculateGps,
      rawData: false,
      compress: false,
      exportTarget: ExportTarget.regular,
      showNotification: showNotification,
    );
  }

  /// Bundles debug logs into a zipped archive in temporary directory for sharing or export.
  Future<File?> createLogExportArchive() async {
    if (!Logging().hasLogs()) {
      return null;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final fileNameStub = "DebugLogs_${DateTimeEx.namePart}";
    final fileName = "$fileNameStub.csv";
    final logFilePath = p.join(tempDir.path, fileName);
    final logFile = await File(logFilePath).create();
    await Logging().exportLogs(logFile);

    final prefService = Get.isRegistered<BasePrefService>() ? Get.find<BasePrefService>() : null;
    final logLevel = prefService?.get<int>(logLevelTag) ?? logLevelDefault;
    const logTag = "LOG_EXPORT";
    final zipFilePath = p.join(tempDir.path, "$fileNameStub.zip");
    final zipFile = await File(zipFilePath).create();
    bool zipped = false;
    try {
      await ZipFile.createFromFiles(sourceDir: tempDir, files: [logFile], zipFile: zipFile);
      zipped = true;
    } on Exception catch (e, stack) {
      Logging().logException(
        logLevel,
        logTag,
        "ZipFile.createFromFiles",
        "error during creation",
        e,
        stack,
      );
    } finally {
      if (await logFile.exists()) {
        await logFile.delete();
      }
    }

    if (!zipped) {
      Get.snackbar("Log export failed", "Unsuccessful zipping");
      return null;
    }

    return zipFile;
  }

  /// Bundles current Isar database and app preferences into a zipped archive in temporary directory.
  Future<File?> createDatabaseBackupArchive() async {
    final isar = Get.isRegistered<Isar>() ? Get.find<Isar>() : Isar.getInstance();
    if (isar == null) {
      Get.snackbar("Export failed", "Database instance not available");
      return null;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final databaseFilePath = p.join(tempDir.path, "${Isar.defaultName}.isar");
    await isar.copyToFile(databaseFilePath);
    final databaseFile = File(databaseFilePath);

    final List<File> files = [databaseFile];
    File? settingsFile;

    if (Get.isRegistered<BasePrefService>()) {
      final prefService = Get.find<BasePrefService>();
      final settingsBytes = utf8.encode(jsonEncode(prefService.toMap()));
      final settingsFilePath = p.join(tempDir.path, "preferences.json");
      settingsFile = await writeBytesToFile(settingsFilePath, settingsBytes);
      files.add(settingsFile);
    }

    final prefService = Get.isRegistered<BasePrefService>() ? Get.find<BasePrefService>() : null;
    final logLevel = prefService?.get<int>(logLevelTag) ?? logLevelDefault;
    const logTag = "DATA_EXPORT";
    final zipFilePath = p.join(tempDir.path, "DataExport_${DateTimeEx.namePart}.zip");
    final zipFile = await File(zipFilePath).create();
    bool zipped = false;
    try {
      await ZipFile.createFromFiles(sourceDir: tempDir, files: files, zipFile: zipFile);
      zipped = true;
    } on Exception catch (e, stack) {
      Logging().logException(
        logLevel,
        logTag,
        "ZipFile.createFromFiles",
        "error during creation",
        e,
        stack,
      );
    } finally {
      if (settingsFile != null && await settingsFile.exists()) {
        await settingsFile.delete();
      }
      if (await databaseFile.exists()) {
        await databaseFile.delete();
      }
    }

    if (!zipped) {
      Get.snackbar("Export failed", "Unsuccessful zipping");
      return null;
    }

    return zipFile;
  }
}
