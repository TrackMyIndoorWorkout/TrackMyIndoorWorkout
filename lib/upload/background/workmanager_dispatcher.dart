import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../persistence/activity.dart';
import '../../persistence/calorie_tune.dart';
import '../../persistence/device_usage.dart';
import '../../persistence/log_entry.dart';
import '../../persistence/power_tune.dart';
import '../../persistence/record.dart';
import '../../persistence/workout_summary.dart';
import '../../preferences/database_location.dart';
import '../../upload/upload_service.dart';
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

  // Initialize Isar in background isolate if not already opened
  var isar = Isar.getInstance();
  if (isar == null) {
    String? dbLocation;
    try {
      final prefs = await SharedPreferences.getInstance();
      dbLocation = prefs.getString(databaseLocationTag);
    } catch (_) {}

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
