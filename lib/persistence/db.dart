import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'activity.dart';
import 'record.dart';

class Db {
  static const SCHEMA_VERSION = 1;
  Database _db;
  int _activityId;

  open() async {
    if (_db != null) return;

    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'activities.db');
    _db = await openDatabase(path, version: SCHEMA_VERSION,
        onCreate: (db, version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS " +
          "${Activity.TABLE_NAME}(id INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "${Activity.DEVICE_NAME} TEXT, " +
          "${Activity.DEVICE_ID} TEXT, " +
          "${Activity.START} INTEGER, " +
          "${Activity.END} INTEGER, " +
          "${Activity.DISTANCE} INTEGER, " +
          "${Activity.ELAPSED} INTEGER, " +
          "${Activity.CALORIES} INTEGER, " +
          "${Activity.AVG_POWER} FLOAT, " +
          "${Activity.AVG_SPEED} FLOAT, " +
          "${Activity.AVG_CADENCE} FLOAT, " +
          "${Activity.AVG_HEART_RATE} FLOAT, " +
          "${Activity.MAX_SPEED} FLOAT)");

      await db.execute("CREATE TABLE IF NOT EXISTS " +
          "${Record.TABLE_NAME}(${Record.ID} INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "${Record.ACTIVITY_ID} INTEGER, " +
          "${Record.TIME_STAMP} INTEGER, " +
          "${Record.DISTANCE} FLOAT, " +
          "${Record.ELAPSED} INTEGER, " +
          "${Record.CALORIES} INTEGER, " +
          "${Record.POWER} INTEGER, " +
          "${Record.SPEED} FLOAT, " +
          "${Record.CADENCE} INTEGER, " +
          "${Record.HEART_RATE} INTEGER, " +
          "${Record.LON} FLOAT, " +
          "${Record.LAT} FLOAT, " +
          "FOREIGN KEY(${Record.ACTIVITY_ID}) REFERENCES activities(id))");
    });
  }

  close() async {
    if (_db != null) {
      await _db.close();
    }
  }

  addActivity(Activity activity) async {
    _activityId = await _db.insert(
      Activity.TABLE_NAME,
      activity.toMap(forCreation: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  addRecord(Record record) async {
    await _db.insert(
      Record.TABLE_NAME,
      record.toMap(withId: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  updateActivity(Activity activity) async {
    await _db.update(
      Activity.TABLE_NAME,
      activity.toMap(forCreation: false),
      where: "id = ?",
      whereArgs: [_activityId],
    );
  }
}
