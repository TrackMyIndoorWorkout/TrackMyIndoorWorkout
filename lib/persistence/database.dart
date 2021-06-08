import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:tuple/tuple.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
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

@Database(version: 7, entities: [
  Activity,
  Record,
  DeviceUsage,
  CalorieTune,
  PowerTune,
  WorkoutSummary,
])
abstract class AppDatabase extends FloorDatabase {
  ActivityDao get activityDao;
  RecordDao get recordDao;
  DeviceUsageDao get deviceUsageDao;
  CalorieTuneDao get calorieTuneDao;
  PowerTuneDao get powerTuneDao;
  WorkoutSummaryDao get workoutSummaryDao;

  Future<int> rowCount(String tableName, String deviceId) async {
    final result = await database
        .rawQuery("SELECT COUNT(`id`) AS cnt FROM `$tableName` WHERE `mac` = ?", [deviceId]);

    if (result.length < 1) {
      return 0;
    }

    return result[0]['cnt'] as int? ?? 0;
  }

  Future<bool> hasDeviceUsage(String deviceId) async {
    return await rowCount(DEVICE_USAGE_TABLE_NAME, deviceId) > 0;
  }

  Future<bool> hasPowerTune(String deviceId) async {
    return await rowCount(POWER_TUNE_TABLE_NAME, deviceId) > 0;
  }

  Future<double> powerFactor(String deviceId) async {
    if (!await hasPowerTune(deviceId)) {
      return 1.0;
    }

    final powerTune = await powerTuneDao.findPowerTuneByMac(deviceId).first;

    return powerTune?.powerFactor ?? 1.0;
  }

  Future<bool> hasCalorieTune(String deviceId) async {
    return await rowCount(CALORIE_TUNE_TABLE_NAME, deviceId) > 0;
  }

  Future<double> calorieFactor(String deviceId, DeviceDescriptor descriptor) async {
    if (!await hasCalorieTune(deviceId)) {
      return descriptor.calorieFactorDefault;
    }

    final calorieTune = await calorieTuneDao.findCalorieTuneByMac(deviceId).first;

    return calorieTune?.calorieFactor ?? descriptor.calorieFactorDefault;
  }

  Future<bool> hasLeaderboardData() async {
    final result =
        await database.rawQuery("SELECT COUNT(`id`) AS cnt FROM `$WORKOUT_SUMMARIES_TABLE_NAME`");

    if (result.length < 1) {
      return false;
    }

    return (result[0]['cnt'] as int? ?? 0) > 0;
  }

  Future<List<String>> findDistinctWorkoutSummarySports() async {
    final result =
        await database.rawQuery("SELECT DISTINCT `sport` FROM `$WORKOUT_SUMMARIES_TABLE_NAME`");

    if (result.length < 1) {
      return [];
    }

    return result.map((row) => row['sport'].toString()).toList(growable: false);
  }

  Future<List<Tuple2<String, String>>> findDistinctWorkoutSummaryDevices() async {
    final result = await database.rawQuery(
        "SELECT DISTINCT `device_id`, `device_name` FROM `$WORKOUT_SUMMARIES_TABLE_NAME`");

    if (result.length < 1) {
      return [];
    }

    return result
        .map((row) =>
            Tuple2<String, String>(row['device_id'] as String, row['device_name'] as String))
        .toList(growable: false);
  }
}

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute("ALTER TABLE `$ACTIVITIES_TABLE_NAME` ADD COLUMN `four_cc` TEXT");
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
      "UPDATE `$ACTIVITIES_TABLE_NAME` SET four_cc='$PRECOR_SPINNER_CHRONO_POWER_FOURCC' WHERE 1=1");
});

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute("ALTER TABLE `$ACTIVITIES_TABLE_NAME` ADD COLUMN `sport` TEXT");
  await database.execute(
      "UPDATE `$ACTIVITIES_TABLE_NAME` SET `sport`='Kayaking' WHERE `four_cc`='$KAYAK_PRO_GENESIS_PORT_FOURCC'");
  await database
      .execute("UPDATE `$ACTIVITIES_TABLE_NAME` SET `sport`='Ride' WHERE `sport` IS NULL");
});

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute("CREATE TABLE IF NOT EXISTS `$DEVICE_USAGE_TABLE_NAME` " +
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `sport` TEXT, `mac` TEXT, `name` TEXT, " +
      "`manufacturer` TEXT, `manufacturer_name` TEXT, `time` INTEGER)");
});

final migration5to6 = Migration(5, 6, (database) async {
  await database.execute("CREATE TABLE IF NOT EXISTS `$CALORIE_TUNE_TABLE_NAME` " +
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT, `calorie_factor` REAL, " +
      "`time` INTEGER)");
  await database.execute("CREATE TABLE IF NOT EXISTS `$POWER_TUNE_TABLE_NAME` " +
      "(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT, `power_factor` REAL, " +
      "`time` INTEGER)");

  await database.execute("ALTER TABLE `$ACTIVITIES_TABLE_NAME` ADD COLUMN `power_factor` FLOAT");
  await database.execute("ALTER TABLE `$ACTIVITIES_TABLE_NAME` ADD COLUMN `calorie_factor` FLOAT");

  await database.execute("UPDATE `$ACTIVITIES_TABLE_NAME` " +
      "SET device_id='$MPOWER_IMPORT_DEVICE_ID' WHERE `device_id`=''");
  await database.execute("UPDATE `$ACTIVITIES_TABLE_NAME` SET `power_factor`=1.0");
  await database.execute("UPDATE `$ACTIVITIES_TABLE_NAME` SET `calorie_factor`=1.0");
  await database.execute(
      "UPDATE `$ACTIVITIES_TABLE_NAME` SET `calorie_factor`=1.4 WHERE `four_cc`='$SCHWINN_IC_BIKE_FOURCC'");
  await database.execute(
      "UPDATE `$ACTIVITIES_TABLE_NAME` SET `calorie_factor`=3.9 WHERE `four_cc`='$SCHWINN_AC_PERF_PLUS_FOURCC'");
});

final migration6to7 = Migration(6, 7, (database) async {
  await database.execute('CREATE TABLE IF NOT EXISTS `$WORKOUT_SUMMARIES_TABLE_NAME` ' +
      '(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT, `device_id` TEXT, ' +
      '`manufacturer` TEXT, `start` INTEGER, `distance` REAL, `elapsed` INTEGER, ' +
      '`speed` REAL, `sport` TEXT, `power_factor` REAL, `calorie_factor` REAL)');
});
