import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import 'dao/activity_dao.dart';
import 'dao/calorie_tune_dao.dart';
import 'dao/device_usage_dao.dart';
import 'dao/power_tune_dao.dart';
import 'dao/record_dao.dart';
import 'models/activity.dart';
import 'models/calorie_tune.dart';
import 'models/device_usage.dart';
import 'models/power_tune.dart';
import 'models/record.dart';

part 'database.g.dart'; // the generated code is in that file

@Database(version: 6, entities: [Activity, Record, DeviceUsage, CalorieTune, PowerTune])
abstract class AppDatabase extends FloorDatabase {
  ActivityDao get activityDao;
  RecordDao get recordDao;
  DeviceUsageDao get deviceUsageDao;
  CalorieTuneDao get calorieTuneDao;
  PowerTuneDao get powerTuneDao;

  Future<int> rowCount(String tableName, String deviceId) async {
    final result =
        await database.rawQuery("SELECT COUNT(id) FROM $tableName WHERE mac = ?", [deviceId]);
    return result[0]['COUNT(id)'];
  }

  Future<bool> hasDeviceUsage(String deviceId) async {
    return await rowCount(DEVICE_USAGE_TABLE_NAME, deviceId) > 0;
  }

  Future<double> powerFactor(String deviceId) async {
    if (await rowCount(POWER_TUNE_TABLE_NAME, deviceId) <= 0) {
      return 1.0;
    }

    final powerTune = await powerTuneDao?.findPowerTuneByMac(deviceId)?.first;

    return powerTune?.powerFactor ?? 1.0;
  }

  Future<double> calorieFactor(String deviceId, DeviceDescriptor descriptor) async {
    if (await rowCount(CALORIE_TUNE_TABLE_NAME, deviceId) <= 0) {
      return descriptor.calorieFactorDefault;
    }

    final calorieTune = await calorieTuneDao?.findCalorieTuneByMac(deviceId)?.first;

    return calorieTune?.calorieFactor ?? descriptor.calorieFactorDefault;
  }
}

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute("ALTER TABLE $ACTIVITIES_TABLE_NAME ADD COLUMN four_cc TEXT");
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute("UPDATE $ACTIVITIES_TABLE_NAME SET four_cc='PSCP' WHERE 1=1");
});

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute("ALTER TABLE $ACTIVITIES_TABLE_NAME ADD COLUMN sport TEXT");
  await database.execute("UPDATE $ACTIVITIES_TABLE_NAME SET sport='Kayaking' WHERE four_cc='KPro'");
  await database.execute("UPDATE $ACTIVITIES_TABLE_NAME SET sport='Ride' WHERE sport IS NULL");
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

  await database.execute("ALTER TABLE $ACTIVITIES_TABLE_NAME ADD COLUMN power_factor FLOAT");
  await database.execute("ALTER TABLE $ACTIVITIES_TABLE_NAME ADD COLUMN calorie_factor FLOAT");

  await database.execute("UPDATE $ACTIVITIES_TABLE_NAME " +
      "SET device_id='$MPOWER_IMPORT_DEVICE_ID' WHERE device_id=''");
  await database.execute("UPDATE $ACTIVITIES_TABLE_NAME SET power_factor=1.0");
  await database
      .execute("UPDATE $ACTIVITIES_TABLE_NAME " + "SET calorie_factor=1.4 WHERE four_cc='SIC4'");
  await database
      .execute("UPDATE $ACTIVITIES_TABLE_NAME " + "SET calorie_factor=3.9 WHERE four_cc='SAP+'");
});
