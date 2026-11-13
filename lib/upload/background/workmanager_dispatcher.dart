import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../persistence/activity.dart';
import '../../persistence/calorie_tune.dart';
import '../../persistence/device_usage.dart';
import '../../persistence/log_entry.dart';
import '../../persistence/power_tune.dart';
import '../../persistence/record.dart';
import '../../persistence/workout_summary.dart';
import '../../preferences/database_location.dart';
import '../../upload/secure_token_storage.dart';
import '../../upload/upload_service.dart';
import '../../utils/constants.dart';
import '../../utils/init_preferences.dart';
import 'upload_queue.dart';

const String backgroundUploadTaskKey = "com.trackmyindoorworkout.background_upload";
const int maxBackgroundUploadAttempts = 5;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Workmanager background execution started for task: $task");
    return await executeBackgroundUploadTask(inputData: inputData);
  });
}

Future<void> ensureBackgroundServicesInitialized() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database for TrackManager / export GPS track selection
  try {
    final byteData = await rootBundle.load('assets/timezones_10y.tzf');
    tz.initializeDatabase(byteData.buffer.asUint8List());
  } catch (e) {
    debugPrint("Background timezone init error: $e");
  }

  // Initialize preferences (needed for exporters, title/description templates, and portal flags)
  if (!Get.isRegistered<BasePrefService>()) {
    try {
      await initPreferences();
    } catch (e) {
      debugPrint("Background preferences init error: $e");
    }
  }

  // Initialize PackageInfo (needed for FIT/TCX/JSON ActivityExport headers)
  if (!Get.isRegistered<PackageInfo>()) {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      Get.put<PackageInfo>(packageInfo, permanent: true);
    } catch (_) {
      Get.put<PackageInfo>(
        PackageInfo(
          appName: appName,
          packageName: "dev.csaba.track_my_indoor_exercise",
          version: "1.0.0",
          buildNumber: "1",
        ),
        permanent: true,
      );
    }
  }

  if (!Get.isRegistered<SecureTokenStorage>()) {
    Get.put<SecureTokenStorage>(SecureTokenStorage(), permanent: true);
  }

  // Initialize Isar in background isolate if not already opened
  var isar = Get.isRegistered<Isar>() ? Get.find<Isar>() : Isar.getInstance();
  if (isar == null) {
    String? dbLocation;
    if (Get.isRegistered<BasePrefService>()) {
      dbLocation =
          Get.find<BasePrefService>().get<String>(databaseLocationTag) ?? databaseLocationDefault;
    }

    if (dbLocation == null || dbLocation.isEmpty) {
      try {
        final dbDirectory = await getApplicationDocumentsDirectory();
        dbLocation = dbDirectory.path;
      } catch (_) {
        dbLocation = "";
      }
    }

    if (dbLocation.isNotEmpty) {
      try {
        isar = await Isar.open([
          ActivitySchema,
          CalorieTuneSchema,
          DeviceUsageSchema,
          LogEntrySchema,
          PowerTuneSchema,
          RecordSchema,
          WorkoutSummarySchema,
        ], directory: dbLocation);
      } catch (e) {
        debugPrint("Background Isar open error: $e");
      }
    }
  }

  if (isar != null && !Get.isRegistered<Isar>()) {
    Get.put<Isar>(isar, permanent: true);
  }
}

Future<bool> executeBackgroundUploadTask({
  Map<String, dynamic>? inputData,
  BackgroundUploadQueue? queueOverride,
}) async {
  try {
    await ensureBackgroundServicesInitialized();

    final queue = queueOverride ?? BackgroundUploadQueue();
    final items = await queue.getItems();
    if (items.isEmpty) {
      debugPrint("No items in background upload queue.");
      return true;
    }

    bool allSucceeded = true;
    final isar = Get.isRegistered<Isar>() ? Get.find<Isar>() : Isar.getInstance();

    for (final item in items) {
      if (item.attempts >= maxBackgroundUploadAttempts) {
        debugPrint(
          "Item for activity ${item.activityId} (${item.portalName}) exceeded max attempts ($maxBackgroundUploadAttempts). Dropping.",
        );
        await queue.dequeue(item.activityId, item.portalName);
        continue;
      }

      if (isar == null) {
        debugPrint("Isar database not available in background task.");
        return false;
      }

      final activity = await isar.activitys.get(item.activityId);
      if (activity == null) {
        debugPrint("Activity ${item.activityId} not found in database. Dequeuing.");
        await queue.dequeue(item.activityId, item.portalName);
        continue;
      }

      if (activity.isUploaded(item.portalName)) {
        debugPrint(
          "Activity ${item.activityId} is already uploaded to ${item.portalName}. Dequeuing.",
        );
        await queue.dequeue(item.activityId, item.portalName);
        continue;
      }

      final hasToken = await UploadService.isIntegrationEnabled(item.portalName);
      if (!hasToken) {
        debugPrint("Portal ${item.portalName} does not have valid credentials. Dequeuing.");
        await queue.dequeue(item.activityId, item.portalName);
        continue;
      }

      try {
        final uploadService = UploadService.getInstance(item.portalName);
        final statusCode = await uploadService.upload(activity, item.calculateGps);

        final isSuccess = statusCode == 200 || statusCode == 201 || statusCode == 202;
        if (isSuccess) {
          debugPrint(
            "Background upload succeeded for activity ${item.activityId} to ${item.portalName}",
          );
          await queue.dequeue(item.activityId, item.portalName);
        } else if (statusCode >= 400 && statusCode < 500 && statusCode != 408) {
          // Permanent client error (e.g. invalid file, bad request) - don't retry forever
          debugPrint(
            "Permanent client failure (HTTP $statusCode) for ${item.portalName}. Dequeuing.",
          );
          await queue.recordAttempt(item.activityId, item.portalName, "HTTP $statusCode");
          await queue.dequeue(item.activityId, item.portalName);
        } else {
          // Server error or timeout - retry
          debugPrint(
            "Temporary failure (HTTP $statusCode) for ${item.portalName}. Retrying later.",
          );
          await queue.recordAttempt(item.activityId, item.portalName, "HTTP $statusCode");
          allSucceeded = false;
        }
      } catch (e) {
        debugPrint("Exception during background upload: $e");
        await queue.recordAttempt(item.activityId, item.portalName, e.toString());
        allSucceeded = false;
      }
    }

    return allSucceeded;
  } catch (e) {
    debugPrint("executeBackgroundUploadTask error: $e");
    return false;
  }
}

class WorkmanagerService {
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      debugPrint("Workmanager successfully initialized.");
    } catch (e) {
      debugPrint("Workmanager initialization failed: $e");
    }
  }

  static Future<void> scheduleBackgroundUpload({
    Duration initialDelay = const Duration(seconds: 15),
  }) async {
    try {
      await Workmanager().registerOneOffTask(
        "background_upload_${DateTime.now().millisecondsSinceEpoch}",
        backgroundUploadTaskKey,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      debugPrint("Scheduled background upload task with Workmanager.");
    } catch (e) {
      debugPrint("Failed to schedule Workmanager task: $e");
    }
  }
}
