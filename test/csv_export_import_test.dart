// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/csv/csv_export.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/import/csv_importer.dart';
import 'package:track_my_indoor_exercise/persistence/database.dart';
import 'package:track_my_indoor_exercise/persistence/models/activity.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'database_utils.dart';
import 'utils.dart';

@GenerateMocks([PackageInfo])
void main() {
  group('Migration CSV imports identically', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((recordCount) {
      recordCount += 20;
      test('$recordCount', () async {
        final countChunk = recordCount ~/ 4;
        final movingCount = recordCount - 2 * countChunk;
        await initPrefServiceForTest();
        final packageInfo = PackageInfo(
          appName: "Track My Indoor Workout",
          packageName: "dev.csaba.track_my_indoor_exercise",
          buildNumber: "199",
          version: "1.0.199",
        );
        Get.put<PackageInfo>(packageInfo);
        final hasDB = Get.isRegistered<AppDatabase>();
        final database = hasDB ? Get.find<AppDatabase>() : InMemoryDatabase();
        if (hasDB) {
          final inMemoryDB = database as InMemoryDatabase;
          inMemoryDB.activityDaoImpl.activities = [];
          inMemoryDB.recordDaoImpl.records = [];
        } else {
          Get.put<AppDatabase>(database);
        }

        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final calories = rnd.nextInt(1000);
        final caloriesPerTick = calories / recordCount;
        final distance = rnd.nextDouble() * 10000;
        final distancePerTick = distance / recordCount;
        final activity = Activity(
          id: rnd.nextInt(100000),
          deviceName: descriptor.modelName,
          deviceId: mPowerImportDeviceId,
          hrmId: "CAFEBABE",
          start: oneSecondAgo.millisecondsSinceEpoch,
          end: oneSecondAgo.millisecondsSinceEpoch + recordCount * 1000,
          distance: distance,
          elapsed: recordCount,
          movingTime: movingCount * 1000,
          calories: calories,
          uploaded: rnd.nextBool(),
          suuntoUploaded: rnd.nextBool(),
          suuntoBlobUrl: "suuntoBlobUrl test string",
          underArmourUploaded: rnd.nextBool(),
          trainingPeaksUploaded: rnd.nextBool(),
          stravaId: rnd.nextInt(1000000),
          uaWorkoutId: rnd.nextInt(1000000),
          suuntoUploadId: rnd.nextInt(1000000),
          suuntoUploadIdentifier: "suuntoUploadIdentifier test string",
          suuntoWorkoutUrl: "suuntoWorkoutUrl test string",
          trainingPeaksAthleteId: rnd.nextInt(1000000),
          trainingPeaksWorkoutId: rnd.nextInt(1000000),
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
          powerFactor: rnd.nextDouble(),
          calorieFactor: rnd.nextDouble(),
          hrCalorieFactor: rnd.nextDouble(),
          hrmCalorieFactor: rnd.nextDouble(),
          hrBasedCalories: rnd.nextBool(),
          timeZone: "America/Los_Angeles",
        );

        final recordIdOffset = rnd.nextInt(1000);
        final preRecords = List<ExportRecord>.generate(
          countChunk,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index,
              activityId: activity.id,
              timeStamp: activity.start + index * 1000,
              distance: 0.0,
              elapsed: index,
              calories: 0,
              power: 0,
              speed: 0.0,
              cadence: 0,
              heartRate: rnd.nextInt(180),
              elapsedMillis: index * 1000,
              sport: descriptor.defaultSport,
            ),
          ),
        );
        final movingRecords = List<ExportRecord>.generate(
          movingCount,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index + countChunk,
              activityId: activity.id,
              timeStamp: activity.start + (index + countChunk) * 1000,
              distance: distancePerTick * (index + countChunk),
              elapsed: index + countChunk,
              calories: (caloriesPerTick * (index + countChunk)).round(),
              power: rnd.nextInt(500),
              speed: rnd.nextDouble() * 40.0,
              cadence: rnd.nextInt(120),
              heartRate: rnd.nextInt(180),
              elapsedMillis: index * 1000,
              sport: descriptor.defaultSport,
            ),
          ),
        );
        final postRecords = List<ExportRecord>.generate(
          countChunk,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index + countChunk + movingCount,
              activityId: activity.id,
              timeStamp: activity.start + (index + countChunk + movingCount) * 1000,
              distance: movingRecords.last.record.distance,
              elapsed: index + countChunk + movingCount,
              calories: movingRecords.last.record.calories,
              power: 0,
              speed: 0.0,
              cadence: 0,
              heartRate: rnd.nextInt(180),
              elapsedMillis: (index + countChunk + movingCount) * 1000,
              sport: descriptor.defaultSport,
            ),
          ),
        );
        final records = preRecords + movingRecords + postRecords;
        final exportModel = ExportModel(
          activity: activity,
          rawData: true,
          calculateGps: false,
          descriptor: descriptor,
          author: "Csaba Consulting",
          name: appName,
          swVersionMajor: "1",
          swVersionMinor: "0",
          buildVersionMajor: "1",
          buildVersionMinor: "0",
          langID: "en-US",
          partNumber: "0",
          altitude: rnd.nextDouble(),
          records: records,
        );

        final exporter = CsvExport();
        final csvInts = await exporter.getFileCore(exportModel);
        final csvString = utf8.decode(csvInts);

        final importer = CSVImporter(null);
        var importedActivity = await importer.import(csvString, (_) => {});

        expect(importedActivity, isNotNull);
        expect(importedActivity!.deviceId, activity.deviceId);
        expect(importedActivity.deviceName, activity.deviceName);
        expect(importedActivity.hrmId, activity.hrmId);
        expect(importedActivity.start, activity.start);
        expect(importedActivity.startDateTime?.millisecondsSinceEpoch,
            closeTo(activity.startDateTime?.millisecondsSinceEpoch ?? 0, 1000));
        expect(importedActivity.fourCC, activity.fourCC);
        expect(importedActivity.sport, activity.sport);
        expect(importedActivity.powerFactor, activity.powerFactor);
        expect(importedActivity.calorieFactor, activity.calorieFactor);
        expect(importedActivity.hrCalorieFactor, activity.hrCalorieFactor);
        expect(importedActivity.hrmCalorieFactor, activity.hrmCalorieFactor);
        expect(importedActivity.hrBasedCalories, activity.hrBasedCalories);
        expect(importedActivity.timeZone, activity.timeZone);
        expect(importedActivity.end, activity.end);
        expect(importedActivity.distance, activity.distance);
        expect(importedActivity.elapsed, activity.elapsed);
        expect(importedActivity.calories, activity.calories);
        expect(importedActivity.uploaded, activity.uploaded);
        expect(importedActivity.suuntoUploaded, activity.suuntoUploaded);
        expect(importedActivity.suuntoBlobUrl, activity.suuntoBlobUrl);
        expect(importedActivity.underArmourUploaded, activity.underArmourUploaded);
        expect(importedActivity.trainingPeaksUploaded, activity.trainingPeaksUploaded);
        expect(importedActivity.stravaId, activity.stravaId);
        expect(importedActivity.uaWorkoutId, activity.uaWorkoutId);
        expect(importedActivity.suuntoUploadId, 0); // Not used any more
        expect(importedActivity.suuntoUploadIdentifier, activity.suuntoUploadIdentifier);
        expect(importedActivity.suuntoWorkoutUrl, activity.suuntoWorkoutUrl);
        expect(importedActivity.trainingPeaksAthleteId, activity.trainingPeaksAthleteId);
        expect(importedActivity.trainingPeaksWorkoutId, activity.trainingPeaksWorkoutId);
        expect(importedActivity.movingTime, activity.movingTime);

        final importedRecords =
            await database.recordDao.findAllActivityRecords(importedActivity.id!);
        expect(importedRecords.length, records.length);
        for (final pairs in IterableZip<Record>([importedRecords, records.map((e) => e.record)])) {
          expect(pairs[0].activityId, importedActivity.id);
          expect(pairs[0].timeStamp, pairs[1].timeStamp);
          expect(pairs[0].distance, closeTo(pairs[1].distance!, 1e-2));
          expect(pairs[0].elapsed, pairs[1].elapsed);
          expect(pairs[0].calories, pairs[1].calories);
          expect(pairs[0].power, pairs[1].power);
          expect(pairs[0].speed, closeTo(pairs[1].speed!, 1e-2));
          expect(pairs[0].cadence, pairs[1].cadence);
          expect(pairs[0].heartRate, pairs[1].heartRate);
          expect(pairs[0].sport, pairs[1].sport);
        }
      });
    });
  });
}
