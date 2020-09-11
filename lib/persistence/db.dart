import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static const SCHEMA_VERSION = 1;
  static const ACTIVITIES = 'activities';
  static const DEVICE_NAME = 'device_name';
  static const START = 'start';
  static const END = 'end';
  static const RECORDS = 'records';
  static const ACTIVITY_ID = 'activity_id';
  static const TIME_STAMP = 'time_stamp';
  static const DISTANCE = 'distance';
  static const ELAPSED = 'elapsed';
  static const CALORIES = 'calories';
  static const POWER = 'power';
  static const SPEED = 'speed';
  static const CADENCE = 'cadence';
  static const HEART_RATE = 'heart_rate';
  static const LON = 'longitude';
  static const LAT = 'latitude';
  static const AVG = 'avg_';
  static const AVG_POWER = 'avg_$POWER';
  static const AVG_SPEED = 'avg_$SPEED';
  static const AVG_CADENCE = 'avg_$CADENCE';
  static const AVG_HEART_RATE = 'avg_$HEART_RATE';

  Database _db;
  int _activityId;

  open() async {
    if (_db != null) return;

    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'activities.db');
    _db = await openDatabase(path, version: SCHEMA_VERSION,
        onCreate: (db, version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS " +
          "$ACTIVITIES(_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "$DEVICE_NAME TEXT, " +
          "$START INTEGER, " +
          "$END INTEGER, " +
          "$DISTANCE INTEGER, " +
          "$ELAPSED INTEGER, " +
          "$CALORIES INTEGER, " +
          "$AVG_POWER FLOAT, " +
          "$AVG_SPEED FLOAT, " +
          "$AVG_CADENCE FLOAT, " +
          "$AVG_HEART_RATE FLOAT)");

      await db.execute("CREATE TABLE IF NOT EXISTS " +
          "$RECORDS(_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "$ACTIVITY_ID INTEGER, " +
          "$TIME_STAMP INTEGER, " +
          "$DISTANCE FLOAT, " +
          "$ELAPSED INTEGER, " +
          "$CALORIES INTEGER, " +
          "$POWER INTEGER, " +
          "$SPEED FLOAT, " +
          "$CADENCE INTEGER, " +
          "$HEART_RATE INTEGER, " +
          "$LON FLOAT, " +
          "$LAT FLOAT, " +
          "FOREIGN KEY($ACTIVITY_ID) REFERENCES activities(_id))");
    });
  }

  close() async {
    if (_db != null) {
      await _db.close();
    }
  }

  startActivity(String deviceName) async {
    _activityId = await _db.insert(
      ACTIVITIES,
      {
        DEVICE_NAME: deviceName,
        START: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  addRecord(double distance, int elapsed, int calories, int power, double speed,
      int cadence, int heartRate, double lon, double lat) async {
    await _db.insert(
      RECORDS,
      {
        ACTIVITY_ID: _activityId,
        DISTANCE: distance,
        TIME_STAMP: DateTime.now().millisecondsSinceEpoch,
        ELAPSED: elapsed,
        CALORIES: calories,
        POWER: power,
        SPEED: speed,
        CADENCE: cadence,
        HEART_RATE: heartRate,
        LON: lon,
        LAT: lat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  endActivity(double distance, int elapsed, int calories, double avgPower,
      double avgSpeed, double avgCadence, double avgHeartRate) async {
    await _db.update(
      ACTIVITIES,
      {
        END: DateTime.now().millisecondsSinceEpoch,
        DISTANCE: distance,
        ELAPSED: elapsed,
        CALORIES: calories,
        AVG_POWER: avgPower,
        AVG_SPEED: avgSpeed,
        AVG_CADENCE: avgCadence,
        AVG_HEART_RATE: avgHeartRate,
      },
      where: "id = ?",
      whereArgs: [_activityId],
    );
  }
}
