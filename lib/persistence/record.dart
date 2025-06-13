import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../preferences/log_level.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/logging.dart';

part 'record.g.dart';

@Collection(inheritance: false)
class Record {
  static const String tag = "RECORD";

  Id id;
  int activityId;
  @Index()
  late DateTime? timeStamp;
  double? distance; // m
  int? elapsed; // s
  int? calories; // kCal
  int? power; // W
  double? speed; // km/h
  int? cadence;
  int? heartRate;

  @ignore
  int? elapsedMillis;
  @ignore
  double? pace;
  @ignore
  String? sport;
  @ignore
  double? caloriesPerHour;
  @ignore
  double? caloriesPerMinute;
  @ignore
  int movingTime = 0; // ms
  @ignore
  int? resistance;
  @ignore
  double? preciseCadence;
  @ignore
  double? strokeCount; // strides / steps / revolutions

  Record({
    this.id = Isar.autoIncrement,
    this.activityId = Isar.minId,
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
    this.sport,
    this.caloriesPerHour,
    this.caloriesPerMinute,
    this.resistance,
    this.preciseCadence,
    this.strokeCount,
  }) {
    timeStamp ??= DateTime.now();
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

  double speedByUnit(bool si) {
    return speedByUnitCore(speed ?? 0.0, si);
  }

  String speedOrPaceStringByUnit(bool si, String sport) {
    return speedOrPaceString(speed ?? 0.0, si, sport, limitSlowSpeed: true);
  }

  String distanceStringByUnit(bool si, bool highRes) {
    return distanceString(distance ?? 0.0, si, highRes);
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

  void cumulativeDistanceEnforcement(
    Record lastRecord,
    int logLevel,
    bool enableAsserts,
    bool force,
  ) {
    if (lastRecord.distance != null) {
      if (distance != null) {
        if (!testing && kDebugMode && enableAsserts) {
          assert(distance! >= lastRecord.distance!);
        }

        if (distance! < lastRecord.distance!) {
          if (logLevel >= logLevelError) {
            Logging().log(
              logLevel,
              logLevelError,
              tag,
              "cumulativeDistanceEnforcement",
              "violation $distance < ${lastRecord.distance}",
            );
          }

          distance = lastRecord.distance;
        }
      } else if (force) {
        distance = lastRecord.distance;
      }
    }
  }

  void cumulativeElapsedTimeEnforcement(
    Record lastRecord,
    int logLevel,
    bool enableAsserts,
    bool force,
  ) {
    if (lastRecord.elapsed != null) {
      if (elapsed != null) {
        if (!testing && kDebugMode && enableAsserts) {
          assert(elapsed! >= lastRecord.elapsed!);
        }

        if (elapsed! < lastRecord.elapsed!) {
          if (logLevel >= logLevelError) {
            Logging().log(
              logLevel,
              logLevelError,
              tag,
              "cumulativeElapsedTimeEnforcement",
              "violation $elapsed < ${lastRecord.elapsed}",
            );
          }

          elapsed = lastRecord.elapsed;
        }
      } else if (force) {
        elapsed = lastRecord.elapsed;
      }
    }
  }

  void cumulativeMovingTimeEnforcement(Record lastRecord, int logLevel, bool enableAsserts) {
    if (!testing && kDebugMode && enableAsserts) {
      assert(movingTime >= lastRecord.movingTime);
    }

    if (movingTime < lastRecord.movingTime) {
      if (logLevel >= logLevelError) {
        Logging().log(
          logLevel,
          logLevelError,
          tag,
          "cumulativeMovingTimeEnforcement",
          "violation $movingTime < ${lastRecord.movingTime}",
        );
      }

      movingTime = lastRecord.movingTime;
    }
  }

  void cumulativeCaloriesEnforcement(
    Record lastRecord,
    int logLevel,
    bool enableAsserts,
    bool force,
  ) {
    if (lastRecord.calories != null) {
      if (calories != null) {
        if (!testing && kDebugMode && enableAsserts) {
          assert(calories! >= lastRecord.calories!);
        }

        if (calories! < lastRecord.calories!) {
          if (logLevel >= logLevelError) {
            Logging().log(
              logLevel,
              logLevelError,
              tag,
              "cumulativeCaloriesEnforcement",
              "violation $calories < ${lastRecord.calories}",
            );
          }

          calories = lastRecord.calories;
        }
      } else if (force) {
        calories = lastRecord.calories;
      }
    }
  }

  void cumulativeStrokeCountEnforcement(
    Record lastRecord,
    int logLevel,
    bool enableAsserts,
    bool force,
  ) {
    if (lastRecord.strokeCount != null) {
      if (strokeCount != null) {
        if (!testing && kDebugMode && enableAsserts) {
          assert(strokeCount! >= lastRecord.strokeCount!);
        }

        if (strokeCount! < lastRecord.strokeCount!) {
          if (logLevel >= logLevelError) {
            Logging().log(
              logLevel,
              logLevelError,
              tag,
              "cumulativeStrokeCountEnforcement",
              "violation $strokeCount < ${lastRecord.strokeCount}",
            );
          }

          strokeCount = lastRecord.strokeCount;
        }
      } else if (force) {
        strokeCount = lastRecord.strokeCount;
      }
    }
  }

  void nonNegativeEnforcement(int logLevel, bool enableAsserts) {
    if (distance != null) {
      if (kDebugMode && enableAsserts) {
        assert(distance! >= 0.0);
      }

      if (distance! < 0.0) {
        if (logLevel >= logLevelError) {
          Logging().log(
            logLevel,
            logLevelError,
            tag,
            "nonNegativeEnforcement",
            "negative distance $distance",
          );
        }

        distance = 0.0;
      }
    }

    if (elapsed != null) {
      if (kDebugMode && enableAsserts) {
        assert(elapsed! >= 0);
      }

      if (elapsed! < 0) {
        if (logLevel >= logLevelError) {
          Logging().log(
            logLevel,
            logLevelError,
            tag,
            "nonNegativeEnforcement",
            "negative elapsed $elapsed",
          );
        }

        elapsed = 0;
      }
    }

    if (kDebugMode && enableAsserts) {
      assert(movingTime >= 0);
    }

    if (movingTime < 0) {
      if (logLevel >= logLevelError) {
        Logging().log(
          logLevel,
          logLevelError,
          tag,
          "nonNegativeEnforcement",
          "negative movingTime $movingTime",
        );
      }

      movingTime = 0;
    }

    if (calories != null) {
      if (kDebugMode && enableAsserts) {
        assert(calories! >= 0);
      }

      if (calories! < 0) {
        if (logLevel >= logLevelError) {
          Logging().log(
            logLevel,
            logLevelError,
            tag,
            "nonNegativeEnforcement",
            "negative calories $calories",
          );
        }

        calories = 0;
      }
    }
  }

  void cumulativeMetricsEnforcements(
    Record lastRecord,
    int logLevel,
    bool enableAsserts, {
    bool forDistance = false,
    bool forCalories = false,
    bool forStrokeCount = false,
    bool force = false,
  }) {
    // Ensure that cumulative fields cannot decrease over time
    if (forDistance) {
      cumulativeDistanceEnforcement(lastRecord, logLevel, enableAsserts, force);
    }

    cumulativeElapsedTimeEnforcement(lastRecord, logLevel, enableAsserts, force);
    cumulativeMovingTimeEnforcement(lastRecord, logLevel, enableAsserts);

    if (forCalories) {
      cumulativeCaloriesEnforcement(lastRecord, logLevel, enableAsserts, force);
    }

    if (forStrokeCount) {
      cumulativeStrokeCountEnforcement(lastRecord, logLevel, enableAsserts, force);
    }

    nonNegativeEnforcement(logLevel, enableAsserts);
  }

  void adjustTime(int newElapsed, int newElapsedMillis) {
    if (elapsedMillis != null && timeStamp != null) {
      final dMillis = newElapsedMillis - elapsedMillis!;
      timeStamp = timeStamp!.add(Duration(milliseconds: dMillis));
    }

    elapsed = newElapsed;
    elapsedMillis = newElapsedMillis;
  }

  void adjustByFactors(double powerFactor, double calorieFactor, bool extendTuning) {
    if ((powerFactor - 1.0).abs() > eps) {
      if (power != null) {
        power = (power! * powerFactor).round();
      }

      if (extendTuning) {
        if (speed != null) {
          speed = speed! * powerFactor;
        }

        if (distance != null) {
          distance = distance! * powerFactor;
        }

        if (pace != null) {
          pace = pace! / powerFactor;
        }
      }
    }

    if ((calorieFactor - 1.0).abs() > eps) {
      if (calories != null) {
        calories = (calories! * calorieFactor).round();
      }

      if (caloriesPerHour != null) {
        caloriesPerHour = caloriesPerHour! * calorieFactor;
      }

      if (caloriesPerMinute != null) {
        caloriesPerMinute = caloriesPerMinute! * calorieFactor;
      }
    }
  }

  factory Record.clone(Record record) {
    return Record(
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
      sport: record.sport,
      caloriesPerHour: record.caloriesPerHour,
      caloriesPerMinute: record.caloriesPerMinute,
      resistance: record.resistance,
      preciseCadence: record.preciseCadence,
      strokeCount: record.strokeCount,
    );
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
        "caloriesPerHour $caloriesPerHour | "
        "caloriesPerMinute $caloriesPerMinute | "
        "resistance $resistance | "
        "preciseCadence $preciseCadence | "
        "strokeCount $strokeCount";
  }
}

class RecordWithSport extends Record {
  RecordWithSport({
    Id? id,
    int? activityId,
    super.timeStamp,
    super.distance,
    super.elapsed,
    super.calories,
    super.power,
    super.speed,
    super.cadence,
    super.heartRate,
    super.elapsedMillis,
    super.pace,
    required super.sport,
    super.caloriesPerHour,
    super.caloriesPerMinute,
    super.resistance,
    super.preciseCadence,
    super.strokeCount,
  }) : assert(sport != null),
       super(id: id ?? Isar.autoIncrement, activityId: activityId ?? Isar.minId);

  static RecordWithSport getZero(String sport) {
    return RecordWithSport(
      distance: 0.0,
      elapsed: 0,
      calories: 0,
      power: 0,
      speed: 0.0,
      pace: sport == ActivityType.ride ? null : 0.0,
      cadence: 0,
      heartRate: 0,
      elapsedMillis: 0,
      caloriesPerHour: 0.0,
      caloriesPerMinute: 0.0,
      resistance: 0,
      preciseCadence: 0.0,
      strokeCount: 0.0,
      sport: sport,
    );
  }

  static RecordWithSport getRandom(String sport, Random random) {
    final spd = sport == ActivityType.run
        ? 4.0 + random.nextDouble() * 12.0
        : (sport == ActivityType.ride
              ? 30.0 + random.nextDouble() * 20.0
              : 2.0 + random.nextDouble() * 10.0);
    final cadence = 30.0 + random.nextDouble() * 100.0;
    return RecordWithSport(
      timeStamp: DateTime.now(),
      calories: 1 + random.nextInt(1500),
      power: 50 + random.nextInt(500),
      speed: spd,
      cadence: cadence.toInt(),
      heartRate: 60 + random.nextInt(120),
      resistance: 1 + random.nextInt(100),
      preciseCadence: cadence,
      sport: sport,
    );
  }

  RecordWithSport merge(RecordWithSport record) {
    distance ??= record.distance;
    elapsed ??= record.elapsed;
    calories ??= record.calories;
    power ??= record.power;
    speed ??= record.speed;
    pace ??= record.pace;
    cadence ??= record.cadence;
    heartRate ??= record.heartRate;
    caloriesPerHour ??= record.caloriesPerHour;
    caloriesPerMinute ??= record.caloriesPerMinute;
    resistance ??= record.resistance;
    preciseCadence ??= record.preciseCadence;
    strokeCount ??= record.strokeCount;
    return this;
  }

  RecordWithSport mergeBest(RecordWithSport record) {
    final nonNullDistance = (distance ?? 0);
    if (distance != null && nonNullDistance > 0 && (record.distance ?? 0) > nonNullDistance) {
      distance = record.distance;
    } else {
      distance ??= record.distance;
    }

    final nonNullElapsed = (elapsed ?? 0);
    if (elapsed != null && nonNullElapsed > 0 && (record.elapsed ?? 0) > nonNullElapsed) {
      elapsed = record.elapsed;
    } else {
      elapsed ??= record.elapsed;
    }

    final nonNullCalories = (calories ?? 0);
    if (calories != null && nonNullCalories > 0 && (record.calories ?? 0) > nonNullCalories) {
      calories = record.calories;
    } else {
      calories ??= record.calories;
    }

    final nonNullPower = (power ?? 0);
    if (power != null && nonNullPower > 0 && (record.power ?? 0) > nonNullPower) {
      power = record.power;
    } else {
      power ??= record.power;
    }

    final nonNullSpeed = (speed ?? 0);
    if (speed != null && nonNullSpeed > 0 && (record.speed ?? 0) > nonNullSpeed) {
      speed = record.speed;
    } else {
      speed ??= record.speed;
    }

    final nonNullPace = (pace ?? 0);
    final nonNullRecordPace = (record.pace ?? 0);
    if (pace != null &&
        nonNullPace > 0 &&
        nonNullRecordPace > 0 &&
        nonNullRecordPace < nonNullPace) {
      pace = record.pace;
    } else {
      pace ??= record.pace;
    }

    final nonNullCadence = (cadence ?? 0);
    if (cadence != null && nonNullCadence > 0 && (record.cadence ?? 0) > nonNullCadence) {
      cadence = record.cadence;
    } else {
      cadence ??= record.cadence;
    }

    final nonNullHeartRate = (heartRate ?? 0);
    if (heartRate != null && nonNullHeartRate > 0 && (record.heartRate ?? 0) > nonNullHeartRate) {
      heartRate = record.heartRate;
    } else {
      heartRate ??= record.heartRate;
    }

    final nonNullCaloriesPerHour = (caloriesPerHour ?? 0);
    if (caloriesPerHour != null &&
        nonNullCaloriesPerHour > 0 &&
        (record.caloriesPerHour ?? 0) > nonNullCaloriesPerHour) {
      caloriesPerHour = record.caloriesPerHour;
    } else {
      caloriesPerHour ??= record.caloriesPerHour;
    }

    final nonNullCaloriesPerMinute = (caloriesPerMinute ?? 0);
    if (caloriesPerMinute != null &&
        nonNullCaloriesPerMinute > 0 &&
        (record.caloriesPerMinute ?? 0) > nonNullCaloriesPerMinute) {
      caloriesPerMinute = record.caloriesPerMinute;
    } else {
      caloriesPerMinute ??= record.caloriesPerMinute;
    }

    final nonNullResistance = (resistance ?? 0);
    if (resistance != null &&
        nonNullResistance > 0 &&
        (record.resistance ?? 0) > nonNullResistance) {
      resistance = record.resistance;
    } else {
      resistance ??= record.resistance;
    }

    final nonNullPreciseCadence = (preciseCadence ?? 0);
    if (preciseCadence != null &&
        nonNullPreciseCadence > 0 &&
        (record.preciseCadence ?? 0) > nonNullPreciseCadence) {
      preciseCadence = record.preciseCadence;
    } else {
      preciseCadence ??= record.preciseCadence;
    }

    final nonNullStrokeCount = (strokeCount ?? 0);
    if (strokeCount != null &&
        nonNullStrokeCount > 0 &&
        (record.strokeCount ?? 0) > nonNullStrokeCount) {
      strokeCount = record.strokeCount;
    } else {
      strokeCount ??= record.strokeCount;
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
      sport: record.sport,
      caloriesPerHour: record.caloriesPerHour,
      caloriesPerMinute: record.caloriesPerMinute,
      resistance: record.resistance,
      preciseCadence: record.preciseCadence,
      strokeCount: record.strokeCount,
    );
  }

  factory RecordWithSport.offsetBack(Record record, Record continuationRecord) {
    final clone = RecordWithSport.clone(record);

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
      clone.elapsedMillis =
          clone.elapsedMillis! +
          (continuationRecord.elapsedMillis != null
              ? continuationRecord.elapsedMillis!
              : continuationRecord.elapsed! * 1000);
    }

    if (clone.calories != null && continuationRecord.calories != null) {
      clone.calories = clone.calories! + continuationRecord.calories!;
    }

    return clone;
  }

  List<int> binarySerialize() {
    switch (sport) {
      case ActivityType.ride:
        // Flag:
        // C1 Instantaneous speed
        // C3 Instantaneous Cadence
        // C5 Total Distance
        // C7 Instantaneous Power
        // C9 Total Energy, Energy Per Hour, Energy Per Minute
        // C10 Heart rate
        // C12 Elapsed Time
        //
        // 84 0101 0100
        // 11 0000 1011
        const flagMsb = 11;
        const flagLsb = 84;
        final speed100 = ((speed ?? 0.0) * 100).round();
        final cadence2 = (cadence ?? 0) * 2;
        final distance0 = (distance ?? 0.0).round();
        final power0 = power ?? 0;
        final calories0 = calories ?? 0;
        final elapsed0 = elapsed ?? 0;
        // Following FTMS Indoor Bike layout
        return [
          flagLsb,
          flagMsb,
          speed100 % 256,
          speed100 ~/ 256,
          cadence2 % 256,
          cadence2 ~/ 256,
          distance0 % 256,
          (distance0 ~/ 256) % 256,
          (distance0 ~/ 65536) % 256,
          power0 % 256,
          power0 ~/ 256,
          calories0 % 256,
          calories0 ~/ 256,
          0,
          0,
          0,
          heartRate ?? 0,
          elapsed0 % 256,
          elapsed0 ~/ 256,
        ];

      case ActivityType.kayaking:
      case ActivityType.canoeing:
      case ActivityType.rowing:
      case ActivityType.swim:
      case ActivityType.standUpPaddling:
        // Flag:
        // C1 Stroke Rate, Stroke Count
        // C3 Total Distance
        // C4 Instantaneous Pace
        // C6 Instantaneous Power
        // C9 Total Energy, Energy Per Hour, Energy Per Minute
        // C10 Heart rate
        // C12 Elapsed Time
        //
        // 44 0010 1100
        // 11 0000 1011
        const flagMsb = 11;
        const flagLsb = 44;
        final cadence2 = min((cadence ?? 0) * 2, maxByte);
        final strokeCount0 = (strokeCount ?? 0.0).toInt();
        final pace0 = (pace ?? 0.0).round();
        final distance0 = (distance ?? 0.0).round();
        final power0 = power ?? 0;
        final calories0 = calories ?? 0;
        final elapsed0 = elapsed ?? 0;
        // Following FTMS Indoor Bike layout
        return [
          flagLsb,
          flagMsb,
          cadence2,
          strokeCount0 % 256,
          strokeCount0 ~/ 256,
          distance0 % 256,
          (distance0 ~/ 256) % 256,
          (distance0 ~/ 65536) % 256,
          pace0 % 256,
          pace0 ~/ 256,
          power0 % 256,
          power0 ~/ 256,
          calories0 % 256,
          calories0 ~/ 256,
          0,
          0,
          0,
          heartRate ?? 0,
          elapsed0 % 256,
          elapsed0 ~/ 256,
        ];

      default:
        return [];
    }
  }

  static int binarySerializedLength(String sport) {
    if (sport == ActivityType.ride) {
      return 19;
    } else if (sport == ActivityType.kayaking ||
        sport == ActivityType.canoeing ||
        sport == ActivityType.rowing ||
        sport == ActivityType.swim) {
      return 20;
    }

    return 0;
  }
}
