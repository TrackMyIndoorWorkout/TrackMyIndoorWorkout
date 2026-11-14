import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/export_manager.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/preferences/instant_export.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'database/in_memory_database.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
    Get.reset();
    Get.put<Isar>(InMemoryDatabase("export_manager_test_db"), permanent: true);
    await initPrefServiceForTest();
    final packageInfo = PackageInfo(
      appName: "Track My Indoor Workout",
      packageName: "dev.csaba.track_my_indoor_exercise",
      buildNumber: "1",
      version: "1.0.0",
    );
    Get.put<PackageInfo>(packageInfo, permanent: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('export_manager_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );

    final isar = Get.find<Isar>() as InMemoryDatabase;
    isar.records.clearSync();
    isar.activities.clearSync();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ExportManager singleton and status queries', () {
    final manager = ExportManager.instance;
    expect(manager, isNotNull);
    expect(manager.getStatus(999), equals(ExportStatus.idle));
    expect(manager.isExporting(999), isFalse);
  });

  test('writeBytesToFile writes file and creates parent directory in isolate', () async {
    final subFilePath = '${tempDir.path}/nested/dir/test_output.bin';
    final sampleBytes = [1, 2, 3, 4, 5, 42];

    final file = await ExportManager.writeBytesToFile(subFilePath, sampleBytes);
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), equals(sampleBytes));
  });

  test('exportActivityToFile exports activity bytes and writes file off UI thread', () async {
    final isar = Get.find<Isar>() as InMemoryDatabase;
    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 201,
      deviceName: "Schwinn IC4",
      deviceId: "dev_1",
      hrmId: "hrm_1",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );
    isar.activities.putSync(activity);

    final records = <Record>[
      for (int i = 0; i < 5; i++)
        Record(
          id: i + 1,
          activityId: activity.id,
          timeStamp: startTime.add(Duration(seconds: i)),
          elapsed: i,
          distance: i * 10.0,
          speed: 15.0,
          cadence: 70,
          power: 150,
          heartRate: 120,
          calories: i,
        ),
    ];
    isar.records.putAllSync(records);

    final manager = ExportManager.instance;
    final exportedFile = await manager.exportActivityToFile(
      activity,
      destinationDirectory: tempDir.path,
      showNotification: false,
    );

    expect(exportedFile, isNotNull);
    expect(await exportedFile!.exists(), isTrue);
    expect(exportedFile.lengthSync(), greaterThan(0));
    expect(manager.getStatus(activity.id), equals(ExportStatus.success));
  });

  test('exportActivityToFile works with preloadedRecords', () async {
    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 202,
      deviceName: "Schwinn IC4",
      deviceId: "dev_2",
      hrmId: "hrm_2",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );

    final preloadedRecords = <Record>[
      Record(
        id: 1,
        activityId: activity.id,
        timeStamp: startTime,
        elapsed: 0,
        distance: 0,
        speed: 10.0,
        cadence: 60,
        power: 100,
        heartRate: 110,
        calories: 0,
      ),
    ];

    final manager = ExportManager.instance;
    final exportedFile = await manager.exportActivityToFile(
      activity,
      preloadedRecords: preloadedRecords,
      destinationDirectory: tempDir.path,
      showNotification: false,
    );

    expect(exportedFile, isNotNull);
    expect(await exportedFile!.exists(), isTrue);
    expect(exportedFile.lengthSync(), greaterThan(0));
    expect(manager.getStatus(activity.id), equals(ExportStatus.success));
  });

  test('runInstantExport uses preference directory when destinationDirectory not passed', () async {
    final isar = Get.find<Isar>() as InMemoryDatabase;
    final prefService = Get.find<BasePrefService>();
    prefService.set<String>(instantExportLocationTag, tempDir.path);

    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 203,
      deviceName: "Schwinn IC4",
      deviceId: "dev_3",
      hrmId: "hrm_3",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );
    isar.activities.putSync(activity);

    final manager = ExportManager.instance;
    final exportedFile = await manager.runInstantExport(
      activity,
      showNotification: false,
    );

    expect(exportedFile, isNotNull);
    expect(await exportedFile!.exists(), isTrue);
    expect(exportedFile.path.startsWith(tempDir.path), isTrue);
  });

  test('exportActivityToFile returns null when destination is not provided', () async {
    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 204,
      deviceName: "Schwinn IC4",
      deviceId: "dev_4",
      hrmId: "hrm_4",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );

    final manager = ExportManager.instance;
    final result = await manager.exportActivityToFile(
      activity,
      showNotification: false,
    );
    expect(result, isNull);
    expect(manager.getStatus(activity.id), equals(ExportStatus.failed));
  });

  test('exportActivityToTempFile writes to temporary directory', () async {
    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 205,
      deviceName: "Schwinn IC4",
      deviceId: "dev_5",
      hrmId: "hrm_5",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );

    final preloadedRecords = <Record>[
      Record(
        id: 1,
        activityId: activity.id,
        timeStamp: startTime,
        elapsed: 0,
        distance: 0,
        speed: 10.0,
        cadence: 60,
        power: 100,
        heartRate: 110,
        calories: 0,
      ),
    ];

    final manager = ExportManager.instance;
    final tempFile = await manager.exportActivityToTempFile(
      activity,
      FitExport(),
      preloadedRecords: preloadedRecords,
    );

    expect(tempFile, isNotNull);
    expect(await tempFile!.exists(), isTrue);
    expect(tempFile.lengthSync(), greaterThan(0));
    await tempFile.delete();
  });
}
