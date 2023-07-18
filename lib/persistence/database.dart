import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:tuple/tuple.dart';

import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_fourcc.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
import '../utils/address_names.dart';
import '../utils/constants.dart';
import '../utils/time_zone.dart';
import 'dao/activity_dao.dart';
import 'dao/calorie_tune_dao.dart';
import 'dao/device_usage_dao.dart';
import 'dao/power_tune_dao.dart';
import 'dao/record_dao.dart';
import 'dao/workout_summary_dao.dart';
import 'models/activity.dart';
import 'models/calorie_tune.dart';
import 'models/device_usage.dart';
import 'models/power_tune.dart';
import 'models/record.dart';
import 'models/workout_summary.dart';

part 'database.g.dart'; // the generated code is in that file

@Database(version: 18, entities: [
  Activity,
  Record,
  DeviceUsage,
  CalorieTune,
  PowerTune,
  WorkoutSummary,
])
abstract class AppDatabase extends FloorDatabase {
  static bool additional15to16Migration = false;
  static bool additional16to17Migration = false;

  ActivityDao get activityDao;
  RecordDao get recordDao;
  DeviceUsageDao get deviceUsageDao;
  CalorieTuneDao get calorieTuneDao;
  PowerTuneDao get powerTuneDao;
  WorkoutSummaryDao get workoutSummaryDao;

  Future<double> powerFactor(String deviceId) async {
    final powerTune = await powerTuneDao.findPowerTuneByMac(deviceId);
    return powerTune?.powerFactor ?? 1.0;
  }

  Future<CalorieTune?> findCalorieTuneByMac(String mac, bool hrBased) async {
    if (hrBased) {
      return await calorieTuneDao.findHrCalorieTuneByMac(mac);
    } else {
      return await calorieTuneDao.findCalorieTuneByMac(mac);
    }
  }

  Future<double> calorieFactorValue(String deviceId, bool hrBased) async {
    final calorieTune = await findCalorieTuneByMac(deviceId, hrBased);
    return calorieTune?.calorieFactor ?? 1.0;
  }

  Future<Tuple3<double, double, double>> getFactors(String deviceId) async {
    return Tuple3(
      await powerFactor(deviceId),
      await calorieFactorValue(deviceId, false),
      await calorieFactorValue(deviceId, true),
    );
  }

  Future<List<Tuple3<String, String, String>>> findDistinctWorkoutSummaryDevices() async {
    final result = await database.rawQuery(
        "SELECT DISTINCT `device_id`, `device_name`, `sport` FROM `$workoutSummariesTableName`");

    if (result.isEmpty) {
      return [];
    }

    return result
        .map((row) => Tuple3<String, String, String>(
              row['device_id'] as String,
              row['device_name'] as String,
              row['sport'] as String,
            ))
        .toList(growable: false);
  }

  /// Correct those activity calorieFactors where the device doesn't supply
  /// calorie data and it has to be calculated from watts. From now on the
  /// in those cases a 4.0 (earlier 3.6) will be implicit.
  Future<void> correctCalorieFactors() async {
    AppDatabase.additional15to16Migration = false;
    try {
      Map<String, bool> noCalorieDevices = {};
      for (var activity in await activityDao.findAllActivities()) {
        final deviceDescriptor = activity.deviceDescriptor();
        if (!deviceDescriptor.canMeasureCalories) {
          noCalorieDevices[activity.deviceId] = true;
          if (activity.calorieFactor > 1.0) {
            activity.calorieFactor /= DeviceDescriptor.oldPowerCalorieFactorDefault;
            await activityDao.updateActivity(activity);
          }
        }
      }

      for (var calorieTune in await calorieTuneDao.findAllCalorieTunes()) {
        if (noCalorieDevices.containsKey(calorieTune.mac) ||
            calorieTune.calorieFactor > DeviceDescriptor.oldPowerCalorieFactorDefault - 1.0) {
          calorieTune.calorieFactor /= DeviceDescriptor.oldPowerCalorieFactorDefault;
          await calorieTuneDao.updateCalorieTune(calorieTune);
        }
      }
    } on Exception catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  /// Initialize moving time by the elapsed time for existing Activities.
  /// We could infer the elapsed time by analyzing the Record time stamps
  /// and moving statuses, but let's not put in computation for now
  Future<void> initializeExistingActivityMovingTimes() async {
    AppDatabase.additional16to17Migration = false;
    try {
      for (var activity in await activityDao.findAllActivities()) {
        if (activity.elapsed > 0) {
          activity.movingTime = activity.elapsed * 1000;
          await activityDao.updateActivity(activity);
        }
      }
    } on Exception catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    try {
      for (var workoutSummary in await workoutSummaryDao.findAllWorkoutSummaries()) {
        if (workoutSummary.elapsed > 0) {
          workoutSummary.movingTime = workoutSummary.elapsed * 1000;
          await workoutSummaryDao.updateWorkoutSummary(workoutSummary);
        }
      }
    } on Exception catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  Future<bool> finalizeActivity(Activity activity) async {
    final lastRecord = await recordDao.findLastRecordOfActivity(activity.id!);
    if (lastRecord == null) {
      return false;
    }

    int updated = 0;
    if (lastRecord.calories != null && lastRecord.calories! > 0 && activity.calories == 0) {
      activity.calories = lastRecord.calories!;
      updated++;
    }

    if (lastRecord.distance != null && lastRecord.distance! > 0 && activity.distance == 0) {
      activity.distance = lastRecord.distance!;
      updated++;
    }

    if (lastRecord.timeStamp != null && lastRecord.timeStamp! > 0 && activity.end == 0) {
      activity.end = lastRecord.timeStamp!;
      updated++;
    }

    if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
      activity.elapsed = lastRecord.elapsed!;
      updated++;
    }

    if (activity.elapsed == 0 && activity.end != 0) {
      final elapsedMillis = activity.end - activity.start;
      if (elapsedMillis >= 1000) {
        activity.elapsed = elapsedMillis ~/ 1000;
        updated++;
      }
    }

    if (activity.movingTime == 0) {
      final records = await recordDao.findAllActivityRecords(activity.id ?? 0);
      if (records.length <= 1) {
        return false;
      }

      double movingMillis = 0;
      var previousRecord = records.first;
      for (final record in records.skip(1)) {
        if (!record.isNotMoving()) {
          final dTMillis = record.timeStamp! - previousRecord.timeStamp!;
          movingMillis += dTMillis;
        }

        previousRecord = record;
      }

      if (movingMillis > 0) {
        activity.movingTime = movingMillis.toInt();
        updated++;
      }
    }

    if (updated > 0) {
      await activityDao.updateActivity(activity);
    }

    return updated > 0;
  }

  Future<bool> recalculateDistance(Activity activity, [force = false]) async {
    final records = await recordDao.findAllActivityRecords(activity.id ?? 0);
    if (records.length <= 1) {
      return false;
    }

    var previousRecord = records.first;
    for (final record in records.skip(1)) {
      final dTMillis = record.timeStamp! - previousRecord.timeStamp!;
      final dT = dTMillis / 1000.0;
      if ((record.distance ?? 0.0) < eps || force) {
        record.distance = (previousRecord.distance ?? 0.0);
        if ((record.speed ?? 0.0) > 0 && dT > eps) {
          // Speed already should have powerFactor effect
          double dD = (record.speed ?? 0.0) * DeviceDescriptor.kmh2ms * dT;
          record.distance = record.distance! + dD;
          await recordDao.updateRecord(record);
        }
      }

      previousRecord = record;
    }

    if ((previousRecord.distance ?? 0.0) > eps && (activity.distance < eps || force)) {
      activity.distance = previousRecord.distance!;
      await activityDao.updateActivity(activity);
    }

    return true;
  }

  Future<void> getAddressNameDictionary(AddressNames addressNames) async {
    for (var activity in await activityDao.findAllActivities()) {
      if (activity.deviceId.isNotEmpty &&
          activity.deviceName.isNotEmpty &&
          activity.deviceName != unnamedDevice) {
        addressNames.addAddressName(activity.deviceId, activity.deviceName);
      }
    }
  }
}

final migration1to2 = Migration(1, 2, (database) async {
  // Cannot add a non null column
  await database.execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `four_cc` TEXT");
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
      "UPDATE `$activitiesTableName` SET four_cc='$precorSpinnerChronoPowerFourCC' WHERE 1=1");
});

final migration3to4 = Migration(3, 4, (database) async {
  // Cannot add a non null column
  await database.execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `sport` TEXT");
  await database.execute(
      "UPDATE `$activitiesTableName` SET `sport`='Kayaking' WHERE `four_cc`='$kayakProGenesisPortFourCC'");
  await database.execute("UPDATE `$activitiesTableName` SET `sport`='Ride' WHERE `sport` IS NULL");
});

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute("CREATE TABLE IF NOT EXISTS `$deviceUsageTableName` "
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `sport` TEXT NOT NULL, `mac` TEXT NOT NULL, "
      "`name` TEXT NOT NULL, `manufacturer` TEXT NOT NULL, `manufacturer_name` TEXT, "
      "`time` INTEGER NOT NULL)");
});

final migration5to6 = Migration(5, 6, (database) async {
  await database.execute("CREATE TABLE IF NOT EXISTS `$calorieTuneTableName` "
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT NOT NULL, "
      "`calorie_factor` REAL NOT NULL, `time` INTEGER NOT NULL)");
  await database.execute("CREATE TABLE IF NOT EXISTS `$powerTuneTableName` "
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT NOT NULL, "
      "`power_factor` REAL NOT NULL, `time` INTEGER NOT NULL)");

  // Cannot add a non null column
  await database.execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `power_factor` FLOAT");
  await database.execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `calorie_factor` FLOAT");

  await database.execute("UPDATE `$activitiesTableName` "
      "SET device_id='$mPowerImportDeviceId' WHERE `device_id`=''");
  await database.execute("UPDATE `$activitiesTableName` SET `power_factor`=1.0");
  await database.execute("UPDATE `$activitiesTableName` SET `calorie_factor`=1.0");
  await database.execute(
      "UPDATE `$activitiesTableName` SET `calorie_factor`=1.4 WHERE `four_cc`='$schwinnICBikeFourCC'");
  await database.execute(
      "UPDATE `$activitiesTableName` SET `calorie_factor`=3.9 WHERE `four_cc`='$schwinnACPerfPlusFourCC'");
});

final migration6to7 = Migration(6, 7, (database) async {
  await database.execute("CREATE TABLE IF NOT EXISTS `$workoutSummariesTableName` "
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT NOT NULL, "
      "`device_id` TEXT NOT NULL, `manufacturer` TEXT NOT NULL, `start` INTEGER NOT NULL, "
      "`distance` REAL NOT NULL, `elapsed` INTEGER NOT NULL, `speed` REAL NOT NULL, "
      "`sport` TEXT NOT NULL, `power_factor` REAL NOT NULL, `calorie_factor` REAL NOT NULL)");
});

final migration7to8 = Migration(7, 8, (database) async {
  await database
      .execute("UPDATE `$activitiesTableName` SET `strava_id`=0 WHERE `strava_id` IS NULL");
});

final migration8to9 = Migration(8, 9, (database) async {
  await database.execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `time_zone` TEXT");

  final timeZone = await getTimeZone();
  await database.execute(
      "UPDATE `$activitiesTableName` SET `time_zone`='$timeZone' WHERE `time_zone` IS NULL");
});

final migration9to10 = Migration(9, 10, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `suunto_uploaded` INTEGER NOT NULL DEFAULT 0");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `suunto_blob_url` TEXT NOT NULL DEFAULT ''");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `under_armour_uploaded` INTEGER NOT NULL DEFAULT 0");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `training_peaks_uploaded` INTEGER NOT NULL DEFAULT 0");
});

final migration10to11 = Migration(10, 11, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `ua_workout_id` INTEGER NOT NULL DEFAULT 0");
});

final migration11to12 = Migration(11, 12, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `suunto_upload_id` INTEGER NOT NULL DEFAULT 0");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `suunto_workout_url` TEXT NOT NULL DEFAULT ''");
});

final migration12to13 = Migration(12, 13, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `suunto_upload_identifier` TEXT NOT NULL DEFAULT ''");
});

final migration13to14 = Migration(13, 14, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `training_peaks_athlete_id` INTEGER NOT NULL DEFAULT 0");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `training_peaks_workout_id` INTEGER NOT NULL DEFAULT 0");
});

final migration14to15 = Migration(14, 15, (database) async {
  final prefService = Get.find<BasePrefService>();
  final useHrBasedCalorieCounting = prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
      useHeartRateBasedCalorieCountingDefault;
  final hrBaseCalories = useHrBasedCalorieCounting ? 1 : 0;
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `hr_calorie_factor` REAL NOT NULL DEFAULT 1.0");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `hr_based_calories` INTEGER NOT NULL DEFAULT $hrBaseCalories");
  await database.execute(
      "ALTER TABLE `$calorieTuneTableName` ADD COLUMN `hr_based` INTEGER NOT NULL DEFAULT 0");
});

final migration15to16 = Migration(15, 16, (database) async {
  await database
      .execute("ALTER TABLE `$activitiesTableName` ADD COLUMN `hrm_id` TEXT NOT NULL DEFAULT ''");
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `hrm_calorie_factor` REAL NOT NULL DEFAULT 1.0");

  AppDatabase.additional15to16Migration = true;
});

final migration16to17 = Migration(16, 17, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `moving_time` INTEGER NOT NULL DEFAULT 0");
  await database.execute(
      "ALTER TABLE `$workoutSummariesTableName` ADD COLUMN `moving_time` INTEGER NOT NULL DEFAULT 0");

  AppDatabase.additional16to17Migration = true;
});

final migration17to18 = Migration(17, 18, (database) async {
  await database.execute(
      "ALTER TABLE `$activitiesTableName` ADD COLUMN `training_peaks_file_tracking_uuid` TEXT NOT NULL DEFAULT ''");
});
