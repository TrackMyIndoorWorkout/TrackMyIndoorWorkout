import 'dart:math';

import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import '../../ui/models/display_record.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import 'activity.dart';

const recordsTableName = 'records';

@Entity(tableName: recordsTableName, foreignKeys: [
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
  int? id;
  @ColumnInfo(name: 'activity_id')
  int? activityId;
  @ColumnInfo(name: 'time_stamp')
  int? timeStamp; // ms since epoch
  double? distance; // m
  int? elapsed; // s
  int? calories; // kCal
  int? power; // W
  double? speed; // km/h
  int? cadence;
  @ColumnInfo(name: 'heart_rate')
  int? heartRate;

  @ignore
  DateTime? dt;
  @ignore
  int? elapsedMillis;
  @ignore
  double? pace;
  @ignore
  double? strokeCount;
  @ignore
  String? sport;
  @ignore
  double? caloriesPerHour;
  @ignore
  double? caloriesPerMinute;
  @ignore
  int movingTime = 0; // ms

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
      if (timeStamp != null && timeStamp! > 0) {
        _dtFromTimeStamp();
      } else {
        dt = DateTime.now();
      }
    }

    if ((timeStamp == null || timeStamp == 0) && dt != null) {
      timeStamp = dt!.millisecondsSinceEpoch;
    }

    paceToSpeed();
  }

  void paceToSpeed() {
    if (sport != null && speed == null && pace != null) {
      if (pace!.abs() < displayEps) {
        speed = 0.0;
      } else {
        if (sport == ActivityType.run || sport == ActivityType.elliptical) {
          // minutes / km pace
          speed = 60.0 / pace!;
        } else if (sport == ActivityType.kayaking ||
            sport == ActivityType.canoeing ||
            sport == ActivityType.rowing) {
          // seconds / 500m pace
          speed = 30.0 / (pace! / 60.0);
        } else if (sport == ActivityType.swim) {
          // seconds / 100m pace
          speed = 6.0 / (pace! / 60.0);
        } else {
          // minutes / km pace
          speed = 60.0 / pace!;
        }
      }
    }
  }

  void _dtFromTimeStamp() {
    if (timeStamp == null) return;

    dt = DateTime.fromMillisecondsSinceEpoch(timeStamp!);
  }

  Record hydrate(String sport) {
    _dtFromTimeStamp();
    this.sport = sport;
    return this;
  }

  double speedByUnit(bool si) {
    return speedByUnitCore(speed ?? 0.0, si);
  }

  String speedOrPaceStringByUnit(bool si, String sport) {
    return speedOrPaceString(speed ?? 0.0, si, sport, limitSlowSpeed: true);
  }

  String distanceStringByUnit(bool si, bool highRes) {
    return distanceString(distance ?? 0.0, si, highRes);
  }

  DisplayRecord display() {
    return DisplayRecord(this);
  }

  bool isNotMoving() {
    return (power ?? 0) == 0 &&
        (speed ?? 0.0) < eps &&
        (pace ?? 0.0) == 0.0 &&
        (caloriesPerHour ?? 0.0) < eps &&
        (caloriesPerMinute ?? 0.0) < eps &&
        (cadence ?? 0) == 0;
  }

  bool hasCumulative() {
    return (distance ?? 0.0) > eps || (elapsed ?? 0) > 0 || (calories ?? 0) > 0;
  }

  void cumulativeDistanceEnforcement(Record lastRecord) {
    if (distance != null && lastRecord.distance != null) {
      if (!testing && kDebugMode) {
        assert(distance! >= lastRecord.distance!);
      }

      if (distance! < lastRecord.distance!) {
        distance = lastRecord.distance;
      }
    }
  }

  void cumulativeElapsedTimeEnforcement(Record lastRecord) {
    if (elapsed != null && lastRecord.elapsed != null) {
      if (!testing && kDebugMode) {
        assert(elapsed! >= lastRecord.elapsed!);
      }

      if (elapsed! < lastRecord.elapsed!) {
        elapsed = lastRecord.elapsed;
      }
    }
  }

  void cumulativeMovingTimeEnforcement(Record lastRecord) {
    if (!testing && kDebugMode) {
      assert(movingTime >= lastRecord.movingTime);
    }

    if (movingTime < lastRecord.movingTime) {
      movingTime = lastRecord.movingTime;
    }
  }

  void cumulativeCaloriesEnforcement(Record lastRecord) {
    if (calories != null && lastRecord.calories != null) {
      if (!testing && kDebugMode) {
        assert(calories! >= lastRecord.calories!);
      }

      if (calories! < lastRecord.calories!) {
        calories = lastRecord.calories;
      }
    }
  }

  void cumulativeMetricsEnforcements(
    Record lastRecord, {
    bool forDistance = false,
    bool forTime = false,
    bool forCalories = false,
  }) {
    // Ensure that cumulative fields cannot decrease over time
    if (forDistance) {
      cumulativeDistanceEnforcement(lastRecord);
    }

    if (forTime) {
      cumulativeElapsedTimeEnforcement(lastRecord);
      cumulativeMovingTimeEnforcement(lastRecord);
    }

    if (forCalories) {
      cumulativeCaloriesEnforcement(lastRecord);
    }
  }

  @override
  String toString() {
    return "id $id | "
        "activityId $activityId | "
        "timeStamp $timeStamp | "
        "distance $distance | "
        "elapsed $elapsed | "
        "calories $calories | "
        "power $power | "
        "speed $speed | "
        "cadence $cadence | "
        "heartRate $heartRate | "
        "elapsedMillis $elapsedMillis | "
        "pace $pace | "
        "strokeCount $strokeCount | "
        "caloriesPerHour $caloriesPerHour | "
        "caloriesPerMinute $caloriesPerMinute";
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
    required sport,
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

  static RecordWithSport getZero(String sport) {
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

  static RecordWithSport getRandom(String sport, Random random) {
    final spd = sport == ActivityType.run
        ? 8.0 + random.nextDouble() * 12.0
        : 30.0 + random.nextDouble() * 10.0;
    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      calories: random.nextInt(1500),
      power: 50 + random.nextInt(500),
      speed: spd,
      cadence: 30 + random.nextInt(100),
      heartRate: 60 + random.nextInt(120),
      sport: sport,
    );
  }

  RecordWithSport merge(RecordWithSport record, bool mergeCadence, bool mergeHr) {
    distance ??= record.distance;
    elapsed ??= record.elapsed;
    calories ??= record.calories;
    power ??= record.power;
    speed ??= record.speed;
    if (mergeCadence) {
      cadence ??= record.cadence;
    }

    if (mergeHr) {
      heartRate ??= record.heartRate;
    }

    return this;
  }

  factory RecordWithSport.clone(Record record) {
    return RecordWithSport(
      activityId: record.activityId,
      timeStamp: record.timeStamp,
      distance: record.distance,
      elapsed: record.elapsed,
      calories: record.calories,
      power: record.power,
      speed: record.speed,
      cadence: record.cadence,
      heartRate: record.heartRate,
      elapsedMillis: record.elapsedMillis,
      pace: record.pace,
      strokeCount: record.strokeCount,
      sport: record.sport,
      caloriesPerHour: record.caloriesPerHour,
      caloriesPerMinute: record.caloriesPerMinute,
    );
  }

  factory RecordWithSport.offsetBack(Record record, Record continuationRecord) {
    final clone = RecordWithSport.clone(record);

    if (clone.timeStamp != null && continuationRecord.timeStamp != null) {
      clone.timeStamp = clone.timeStamp! - continuationRecord.timeStamp!;
    }

    if (clone.distance != null && continuationRecord.distance != null) {
      clone.distance = clone.distance! - continuationRecord.distance!;
    }

    if (clone.elapsed != null && continuationRecord.elapsed != null) {
      clone.elapsed = clone.elapsed! - continuationRecord.elapsed!;
    }

    if (clone.calories != null && continuationRecord.calories != null) {
      clone.calories = clone.calories! - continuationRecord.calories!;
    }

    return clone;
  }

  factory RecordWithSport.offsetForward(Record record, Record continuationRecord) {
    final clone = RecordWithSport.clone(record);

    if (clone.distance != null && continuationRecord.distance != null) {
      clone.distance = clone.distance! + continuationRecord.distance!;
    }

    if (clone.elapsed != null && continuationRecord.elapsed != null) {
      clone.elapsed = clone.elapsed! + continuationRecord.elapsed!;
    }

    if (clone.elapsedMillis != null &&
        (continuationRecord.elapsedMillis != null || continuationRecord.elapsed != null)) {
      clone.elapsedMillis = clone.elapsedMillis! +
          (continuationRecord.elapsedMillis != null
              ? continuationRecord.elapsedMillis!
              : continuationRecord.elapsed! * 1000);
    }

    if (clone.calories != null && continuationRecord.calories != null) {
      clone.calories = clone.calories! + continuationRecord.calories!;
    }

    return clone;
  }

  void adjustTime(int newElapsed, int newElapsedMillis) {
    if (elapsedMillis != null && dt != null) {
      final dMillis = newElapsedMillis - elapsedMillis!;
      dt = dt!.add(Duration(milliseconds: dMillis));
    }

    elapsed = newElapsed;
    elapsedMillis = newElapsedMillis;
  }
}
