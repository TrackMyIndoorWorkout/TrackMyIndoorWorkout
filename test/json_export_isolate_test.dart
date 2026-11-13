import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/csv/csv_export.dart';
import 'package:track_my_indoor_exercise/export/export_target.dart';
import 'package:track_my_indoor_exercise/export/json/json_export.dart';
import 'package:track_my_indoor_exercise/export/tcx/tcx_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/preferences/activity_upload_title.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'database/in_memory_database.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.put<Isar>(InMemoryDatabase("json_export_test_db"), permanent: true);
  });

  Activity seedSampleActivity(InMemoryDatabase isar) {
    isar.records.clearSync();
    isar.activities.clearSync();

    final startTime = DateTime(2026, 11, 13, 13, 0, 0);
    final activity = Activity(
      id: 202,
      deviceName: "Schwinn IC4",
      deviceId: "AA:BB:CC:DD:EE:FF",
      hrmId: "test_hrm",
      start: startTime,
      end: startTime.add(const Duration(minutes: 2)),
      distance: 1000.0,
      elapsed: 120,
      movingTime: 120000,
      calories: 50,
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
      for (int i = 0; i < 30; i++)
        Record(
          id: i + 1,
          activityId: activity.id,
          timeStamp: startTime.add(Duration(seconds: i)),
          elapsed: i,
          distance: i * 8.5,
          speed: 30.6,
          cadence: 88,
          power: 210,
          heartRate: 145,
          calories: (i * 0.4).toInt(),
        ),
    ];
    isar.records.putAllSync(records);
    return activity;
  }

  test('JsonExport getExport executes in background isolate without Get.find failure and preserves custom upload title', () async {
    final isar = Get.find<Isar>() as InMemoryDatabase;
    final activity = seedSampleActivity(isar);

    await initPrefServiceForTest();
    await Get.find<BasePrefService>().set<String>(
      activityUploadTitleTag,
      'Custom "Indoor" {sport} on {bt_name}',
    );
    Get.put<PackageInfo>(
      PackageInfo(
        appName: "Track My Indoor Workout",
        packageName: "dev.csaba.track_my_indoor_exercise",
        buildNumber: "1",
        version: "1.0.0",
      ),
    );

    final exporter = JsonExport();

    // 1. Uncompressed JSON export in background isolate
    final uncompressedBytes = await exporter.getExport(
      activity,
      false,
      true,
      false,
      ExportTarget.regular,
    );

    final jsonString = utf8.decode(uncompressedBytes);
    final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
    expect(parsed["name"], equals('Custom "Indoor" Ride on Schwinn IC4'));
    expect(parsed["start_locale_timezone"], equals("America/Los_Angeles"));
    expect(parsed["time_series"], isA<Map<String, dynamic>>());

    // 2. Compressed (GZIP) JSON export (exact path used by MapMyFitness / UnderArmourService)
    final compressedBytes = await exporter.getExport(
      activity,
      false,
      true,
      true,
      ExportTarget.regular,
    );
    expect(compressedBytes[0], equals(0x1F));
    expect(compressedBytes[1], equals(0x8B));
    expect(GZipCodec().decode(compressedBytes), equals(uncompressedBytes));
  });

  test('TCXExport and CsvExport getExport also succeed in background isolate', () async {
    final isar = Get.find<Isar>() as InMemoryDatabase;
    final activity = seedSampleActivity(isar);

    await initPrefServiceForTest();
    Get.put<PackageInfo>(
      PackageInfo(
        appName: "Track My Indoor Workout",
        packageName: "dev.csaba.track_my_indoor_exercise",
        buildNumber: "1",
        version: "1.0.0",
      ),
    );

    final tcxBytes = await TCXExport().getExport(
      activity,
      false,
      true,
      false,
      ExportTarget.regular,
    );
    expect(utf8.decode(tcxBytes), contains("<TrainingCenterDatabase"));

    final csvBytes = await CsvExport().getExport(
      activity,
      false,
      true,
      false,
      ExportTarget.regular,
    );
    expect(utf8.decode(csvBytes), contains("Schwinn IC4"));
  });
}
