import 'dart:math';

import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import '../../ui/models/display_record.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import 'activity.dart';

const String RECORDS_TABLE_NAME = 'records';

@Entity(tableName: RECORDS_TABLE_NAME, foreignKeys: [
  ForeignKey(
    childColumns: ['activity_id'],
    parentColumns: ['id'],
    entity: Activity,
  )
], indices: [
  Index(value: ['time_stamp'])
])
class Record {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(name: 'activity_id')
  int activityId;
  @ColumnInfo(name: 'time_stamp')
  int timeStamp; // ms since epoch
  double distance; // m
  int elapsed; // s
  int calories; // kCal
  int power; // W
  double speed; // km/h
  int cadence;
  @ColumnInfo(name: 'heart_rate')
  int heartRate;

  @ignore
  DateTime dt;
  @ignore
  int elapsedMillis;
  @ignore
  double pace;
  @ignore
  double strokeCount;
  @ignore
  String sport;
  @ignore
  double caloriesPerHour;
  @ignore
  double caloriesPerMinute;

  Record({
    this.id,
    this.activityId,
    this.timeStamp,
    this.distance,
    this.elapsed,
    this.calories,
    this.power,
    this.speed,
    this.cadence,
    this.heartRate,
    this.elapsedMillis,
    this.pace,
    this.strokeCount,
    this.sport,
    this.caloriesPerHour,
    this.caloriesPerMinute,
  }) {
    if (dt == null) {
      if (timeStamp != null && timeStamp > 0) {
        _dtFromTimeStamp();
      } else {
        dt = DateTime.now();
      }
    }

    if ((timeStamp == null || timeStamp == 0) && dt != null) {
      timeStamp = dt.millisecondsSinceEpoch;
    }

    paceToSpeed();
  }

  void paceToSpeed() {
    if (sport != null && speed == null && pace != null) {
      if (pace.abs() < DISPLAY_EPS) {
        speed = 0.0;
      } else {
        if (sport == ActivityType.Run) {
          // minutes / km pace
          speed = 60.0 / pace;
        } else if (sport == ActivityType.Kayaking ||
            sport == ActivityType.Canoeing ||
            sport == ActivityType.Rowing) {
          // seconds / 500m pace
          speed = 30.0 / (pace / 60.0);
        } else if (sport == ActivityType.Swim) {
          // seconds / 100m pace
          speed = 6.0 / (pace / 60.0);
        } else {
          // minutes / km pace
          speed = 60.0 / pace;
        }
      }
    }
  }

  void _dtFromTimeStamp() {
    dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
  }

  Record hydrate(String sport) {
    _dtFromTimeStamp();
    if (sport != null) {
      this.sport = sport;
    }
    return this;
  }

  double speedByUnit(bool si, String sport) {
    return speedOrPace(speed, si, sport);
  }

  String speedStringByUnit(bool si, String sport) {
    return speedOrPaceString(speed, si, sport);
  }

  String distanceStringByUnit(bool si) {
    return distanceString(distance, si);
  }

  DisplayRecord display() {
    return DisplayRecord(this);
  }
}

class RecordWithSport extends Record {
  RecordWithSport({
    id,
    activityId,
    timeStamp,
    distance,
    elapsed,
    calories,
    power,
    speed,
    cadence,
    heartRate,
    elapsedMillis,
    pace,
    strokeCount,
    @required sport,
    caloriesPerHour,
    caloriesPerMinute,
  })  : assert(sport != null),
        super(
          id: id,
          activityId: activityId,
          timeStamp: timeStamp,
          distance: distance,
          elapsed: elapsed,
          calories: calories,
          power: power,
          speed: speed,
          cadence: cadence,
          heartRate: heartRate,
          elapsedMillis: elapsedMillis,
          pace: pace,
          strokeCount: strokeCount,
          sport: sport,
          caloriesPerHour: caloriesPerHour,
          caloriesPerMinute: caloriesPerMinute,
        );

  static getBlank(String sport, bool uxDebug, Random random) {
    return RecordWithSport(
      timeStamp: 0,
      distance: 0.0,
      elapsed: 0,
      calories: 0,
      power: 0,
      speed: 0.0,
      cadence: 0,
      heartRate: 0,
      elapsedMillis: 0,
      sport: sport,
    );
  }

  static getRandom(String sport, Random random) {
    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      calories: random.nextInt(1500),
      power: 50 + random.nextInt(500),
      speed: 30.0 + random.nextDouble() * 10.0,
      cadence: 30 + random.nextInt(100),
      heartRate: 60 + random.nextInt(120),
      sport: sport,
    );
  }
}
