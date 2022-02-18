import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:tuple/tuple.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
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

@Database(version: 17, entities: [
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

  Future<int> rowCount(String tableName, String deviceId, {String extraPredicate = ""}) async {
    var queryString = "SELECT COUNT(`id`) AS cnt FROM `$tableName` WHERE `mac` = ?";
    if (extraPredicate.isNotEmpty) {
      queryString += " AND $extraPredicate";
    }

    final result = await database.rawQuery(queryString, [deviceId]);

    if (result.isEmpty) {
      return 0;
    }

    return result[0]['cnt'] as int? ?? 0;
  }

  Future<bool> hasDeviceUsage(String deviceId) async {
    return await rowCount(deviceUsageTableName, deviceId) > 0;
  }

  Future<bool> hasPowerTune(String deviceId) async {
    return await rowCount(powerTuneTableName, deviceId) > 0;
  }

  Future<double> powerFactor(String deviceId) async {
    if (!await hasPowerTune(deviceId)) {
      return 1.0;
    }

    final powerTune = await powerTuneDao.findPowerTuneByMac(deviceId).first;

    return powerTune?.powerFactor ?? 1.0;
  }

  Future<bool> hasCalorieTune(String deviceId, bool hrBased) async {
    final extraPredicate = "`hr_based` = ${hrBased ? 1 : 0}";
    return await rowCount(calorieTuneTableName, deviceId, extraPredicate: extraPredicate) > 0;
  }

  Future<CalorieTune?> findCalorieTuneByMac(String mac, bool hrBased) async {
    if (!await hasCalorieTune(mac, hrBased)) {
      return null;
    }

    if (hrBased) {
      return await calorieTuneDao.findHrCalorieTuneByMac(mac).first;
    } else {
      return await calorieTuneDao.findCalorieTuneByMac(mac).first;
    }
  }

  Future<double> calorieFactorValue(String deviceId, bool hrBased) async {
    return (await findCalorieTuneByMac(deviceId, hrBased))?.calorieFactor ?? 1.0;
  }

  Future<Tuple3<double, double, double>> getFactors(String deviceId) async {
    return Tuple3(
      await powerFactor(deviceId),
      await calorieFactorValue(deviceId, false),
      await calorieFactorValue(deviceId, true),
    );
  }

  Future<bool> hasLeaderboardData() async {
    final result =
        await database.rawQuery("SELECT COUNT(`id`) AS cnt FROM `$workoutSummariesTableName`");

    if (result.isEmpty) {
      return false;
    }

    return (result[0]['cnt'] as int? ?? 0) > 0;
  }

  Future<List<String>> findDistinctWorkoutSummarySports() async {
    final result =
        await database.rawQuery("SELECT DISTINCT `sport` FROM `$workoutSummariesTableName`");

    if (result.isEmpty) {
      return [];
    }

    return result.map((row) => row['sport'].toString()).toList(growable: false);
  }

  Future<List<Tuple2<String, String>>> findDistinctWorkoutSummaryDevices() async {
    final result = await database
        .rawQuery("SELECT DISTINCT `device_id`, `device_name` FROM `$workoutSummariesTableName`");

    if (result.isEmpty) {
      return [];
    }

    return result
        .map((row) =>
            Tuple2<String, String>(row['device_id'] as String, row['device_name'] as String))
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
          noCalorieDevices.assign(activity.deviceId, true);
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
