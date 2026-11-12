import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/export_target.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'database/in_memory_database.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.put<Isar>(InMemoryDatabase("fit_export_test_db"), permanent: true);
  });

  test(
    'FitExport getExport executes in background isolate and generates valid FIT bytes',
    () async {
      final isar = Get.find<Isar>() as InMemoryDatabase;
      isar.records.clearSync();
      isar.activities.clearSync();

      await initPrefServiceForTest();
      final packageInfo = PackageInfo(
        appName: "Track My Indoor Workout",
        packageName: "dev.csaba.track_my_indoor_exercise",
        buildNumber: "1",
        version: "1.0.0",
      );
      Get.put<PackageInfo>(packageInfo);

      final startTime = DateTime(2026, 11, 11, 10, 0, 0);
      final activity = Activity(
        id: 101,
        deviceName: "Schwinn IC4",
        deviceId: "test_device",
        hrmId: "test_hrm",
        start: startTime,
        end: startTime.add(const Duration(minutes: 5)),
        distance: 2500.0,
        elapsed: 300,
        movingTime: 300000,
        calories: 120,
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

      // Create a series of records
      final records = <Record>[];
      for (int i = 0; i < 300; i++) {
        final r = Record(
          id: i + 1,
          activityId: activity.id,
          timeStamp: startTime.add(Duration(seconds: i)),
          elapsed: i,
          distance: i * 8.33,
          speed: 30.0, // km/h
          cadence: 85,
          power: 200,
          heartRate: 140,
          calories: (i * 0.4).toInt(),
        );
        records.add(r);
      }
      isar.records.putAllSync(records);

      final exporter = FitExport();

      // 1. Uncompressed FIT export
      final uncompressedBytes = await exporter.getExport(
        activity,
        false, // rawData
        true, // calculateGps
        false, // compress
        ExportTarget.regular,
      );

      expect(uncompressedBytes.isNotEmpty, isTrue);
      expect(uncompressedBytes.length, greaterThan(14));
      // Check FIT header
      expect(uncompressedBytes[0], equals(14)); // Header size
      expect(uncompressedBytes[1], equals(32)); // Protocol version 0x20
      final tag = utf8.decode(uncompressedBytes.sublist(8, 12));
      expect(tag, equals(".FIT"));

      // 2. Compressed (GZIP) FIT export
      final compressedBytes = await exporter.getExport(
        activity,
        false,
        true,
        true, // compress
        ExportTarget.regular,
      );

      expect(compressedBytes.isNotEmpty, isTrue);
      // GZIP magic numbers: 0x1F, 0x8B
      expect(compressedBytes[0], equals(0x1F));
      expect(compressedBytes[1], equals(0x8B));

      // Decompress and verify against uncompressed
      final decompressed = GZipCodec().decode(compressedBytes);
      expect(decompressed, equals(uncompressedBytes));
    },
  );
}
