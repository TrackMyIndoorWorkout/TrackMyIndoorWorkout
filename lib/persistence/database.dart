import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/activity_dao.dart';
import 'dao/record_dao.dart';
import 'models/activity.dart';
import 'models/record.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Activity, Record])
abstract class AppDatabase extends FloorDatabase {
  ActivityDao get activityDao;
  RecordDao get recordDao;
}

// final migration1to2 = Migration(1, 2, (database) async {
//   await database.execute(
//       'ALTER TABLE $ACTIVITIES_TABLE_NAME ADD COLUMN strava_id INTEGER');
// });
