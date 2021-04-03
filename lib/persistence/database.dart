import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/activity_dao.dart';
import 'dao/device_usage_dao.dart';
import 'dao/record_dao.dart';
import 'models/activity.dart';
import 'models/device_usage.dart';
import 'models/record.dart';

part 'database.g.dart'; // the generated code is in that file

@Database(version: 5, entities: [Activity, Record, DeviceUsage])
abstract class AppDatabase extends FloorDatabase {
  ActivityDao get activityDao;
  RecordDao get recordDao;
  DeviceUsageDao get deviceUsageDao;
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
