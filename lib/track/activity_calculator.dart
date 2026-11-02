import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/activity.dart';
import '../persistence/calorie_tune.dart';
import '../persistence/power_tune.dart';
import '../persistence/record.dart';
import '../utils/constants.dart';
import '../utils/power_speed_mixin.dart';

/// The outcome of computing where an activity split falls within a list of
/// records that are ordered by [Record.timeStamp].
///
/// This mirrors the exact semantics of the original in-line split logic in
/// `DbUtils.splitActivity`: [firstPartEnd] and [secondPartStart] are only
/// populated the first time a record crosses the split watermark (i.e. once
/// the split has actually happened), while [secondPartEnd] always reflects
/// the timestamp of the very last record, even when no record ends up on the
/// far side of the split.
class SplitPlan {
  final DateTime? firstPartEnd;
  final DateTime? secondPartStart;
  final DateTime secondPartEnd;
  final List<Record> secondPartRecords;

  SplitPlan({
    required this.firstPartEnd,
    required this.secondPartStart,
    required this.secondPartEnd,
    required this.secondPartRecords,
  });
}

/// Pure(ish) domain/business logic for activities and their records.
///
/// This class deliberately knows nothing about persistence: every method
/// here operates on already-loaded [Activity] / [Record] objects (mutating
/// them in place where that matches the previous behavior) and returns
/// computed results. Callers (currently `DbUtils`) are responsible for
/// loading data from and writing results back to storage.
///
/// The only side effect that isn't purely computational is
/// [PowerSpeedMixin.initPower2SpeedConstants], which reads shared
/// preferences (not the workout database) to refresh the power/speed
/// conversion constants; it is kept here because the conversion math
/// ([PowerSpeedMixin.velocityForPowerCardano]) that depends on it lives in
/// the same mixin.
class ActivityCalculator with PowerSpeedMixin {
  /// Forward-fills gaps in [records] by copying the previous record's value
  /// for cadence/power/speed/heart-rate whenever the current record is
  /// missing (or zero for cadence/power/heart-rate, or near-zero for speed)
  /// a value that the previous record had.
  ///
  /// Mutates the affected [Record]s in place and returns the sublist that
  /// was actually modified, so the caller can persist only those.
  List<Record> bridgeDataGaps(List<Record> records) {
    if (records.isEmpty) {
      return const [];
    }

    var previousRecord = records.first;
    final modifiedRecords = <Record>[];
    for (final record in records.skip(1)) {
      bool modified = false;
      if ((record.cadence ?? 0) <= 0 && (previousRecord.cadence ?? 0) > 0) {
        record.cadence = previousRecord.cadence;
        modified = true;
      }

      if ((record.power ?? 0) <= 0 && (previousRecord.power ?? 0) > 0) {
        record.power = previousRecord.power;
        modified = true;
      }

      if ((record.speed ?? 0.0) <= eps && (previousRecord.speed ?? 0.0) > eps) {
        record.speed = previousRecord.speed;
        modified = true;
      }

      if ((record.heartRate ?? 0) <= 0 && (previousRecord.heartRate ?? 0) > 0) {
        record.heartRate = previousRecord.heartRate;
        modified = true;
      }

      if (modified) {
        modifiedRecords.add(record);
      }

      previousRecord = record;
    }

    return modifiedRecords;
  }

  /// The power factor to apply for a device, falling back to 1.0 (no
  /// adjustment) when there's no tuning on record.
  double powerFactorFromTune(PowerTune? powerTune) => powerTune?.powerFactor ?? 1.0;

  /// The calorie factor to apply for a device, falling back to 1.0 (no
  /// adjustment) when there's no tuning on record.
  double calorieFactorFromTune(CalorieTune? calorieTune) => calorieTune?.calorieFactor ?? 1.0;

  /// Recalculates all derived per-record fields (speed/distance/calories/
  /// elapsed/cadence/heartRate/power gap-filling) for [records] belonging to
  /// [activity], and rolls the aggregate activity fields (distance,
  /// calories, strides, end, elapsed, movingTime) forward from the result.
  ///
  /// Mutates [activity] and the entries of [records] in place. Does not
  /// touch the database; the caller is responsible for persisting the
  /// mutated records/activity afterwards.
  Future<void> recalculateRecords(
    Activity activity,
    List<Record> records,
    bool recalculateMore,
  ) async {
    if (records.isEmpty) {
      return;
    }

    if (recalculateMore) {
      await initPower2SpeedConstants();
    }

    var previousRecord = records.first;
    double calories = 0.0;
    double strides = 0.0;
    double distance = 0.0;
    double movingTime = 0.0;
    for (final record in records.skip(1)) {
      final dTMillis = record.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
      final dTime = dTMillis / 1000.0;

      double speed = record.speed ?? 0.0;
      int power = record.power ?? 0;
      int cadence = record.cadence ?? 0;

      bool moving = (speed > 0.0 || power > 0 || cadence > 0);
      if (moving) {
        movingTime += dTMillis;
        if ((record.cadence ?? 0) <= 0 && (previousRecord.cadence ?? 0) > 0) {
          record.cadence = previousRecord.cadence;
        }

        if ((record.cadence ?? 0) > 0) {
          strides += (record.cadence ?? 0) * dTMillis / (60 * 1000);
        }

        if ((record.power ?? 0) <= 0 && (previousRecord.power ?? 0) > 0) {
          record.power = previousRecord.power;
        }

        if (record.power != null &&
            record.power! > 0.0 &&
            recalculateMore &&
            activity.sport == ActivityType.ride) {
          record.speed = velocityForPowerCardano(record.power!) * DeviceDescriptor.ms2kmh;
        }

        if ((record.speed ?? 0.0) <= eps && (previousRecord.speed ?? 0.0) > eps) {
          record.speed = previousRecord.speed;
        }
      }

      if ((record.heartRate ?? 0) <= 0 && (previousRecord.heartRate ?? 0) > 0) {
        record.heartRate = previousRecord.heartRate;
      }

      record.elapsed = movingTime ~/ 1000;

      // Recalculate distance
      double dDistance = speed * DeviceDescriptor.kmh2ms * dTime;
      distance += dDistance;
      record.distance = distance;

      // Recalculate calories
      double dCal =
          power *
          dTime *
          jToCal *
          activity.calorieFactor *
          DeviceDescriptor.powerCalorieFactorDefault;
      calories += dCal;
      record.calories = calories ~/ 1000;

      previousRecord = record;
    }

    activity.distance = previousRecord.distance!;
    activity.calories = previousRecord.calories!;
    if (strides.toInt() > activity.strides || activity.strides > movingTime / 1000 / 60 * 180) {
      activity.strides = strides.toInt();
    }

    if (activity.end == null || activity.end!.compareTo(previousRecord.timeStamp!) <= 0) {
      activity.end = previousRecord.timeStamp;
    }

    activity.elapsed = activity.end!.difference(activity.start).inSeconds;
    activity.movingTime = movingTime.toInt();
  }

  /// Fills in missing aggregate fields on [activity] from its [lastRecord],
  /// mirroring the historical behavior of `DbUtils.finalizeActivity`.
  ///
  /// Mutates [activity] in place. Returns true if anything was updated.
  bool applyFinalization(Activity activity, Record lastRecord) {
    int updated = 0;
    if (lastRecord.calories != null && lastRecord.calories! > 0 && activity.calories == 0) {
      activity.calories = lastRecord.calories!;
      updated++;
    }

    if (lastRecord.distance != null && lastRecord.distance! > 0 && activity.distance == 0) {
      activity.distance = lastRecord.distance!;
      updated++;
    }

    if (lastRecord.timeStamp != null && activity.end != null) {
      activity.end = lastRecord.timeStamp!;
      updated++;
    }

    if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
      activity.elapsed = lastRecord.elapsed!;
      updated++;
    }

    if (activity.elapsed == 0 && activity.end != null) {
      final elapsedMillis = activity.end!.difference(activity.start).inMilliseconds;
      if (elapsedMillis >= 1000) {
        activity.elapsed = elapsedMillis ~/ 1000;
        updated++;
      }
    }

    return updated > 0;
  }

  /// Computes moving time and strides from [records] and, if either is
  /// non-trivial, applies them to [activity].
  ///
  /// Mutates [activity] in place. Returns true if anything was updated.
  bool applyMovingTimeAndStrides(Activity activity, List<Record> records) {
    if (records.isEmpty) {
      return false;
    }

    double movingMillis = 0;
    double strides = 0;
    var previousRecord = records.first;
    for (final record in records.skip(1)) {
      final dTMillis = record.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
      if (!record.isNotMoving()) {
        movingMillis += dTMillis;
      }

      double strokeCount = record.strokeCount ?? 0.0;
      if (strokeCount > eps) {
        strides += strokeCount * dTMillis / (1000 * 60);
      }

      previousRecord = record;
    }

    if (movingMillis <= eps && strides <= eps) {
      return false;
    }

    if (movingMillis > eps) {
      activity.movingTime = movingMillis.toInt();
    }

    if (strides > eps) {
      activity.strides = strides.toInt();
    }

    return true;
  }

  /// Shifts [activity]'s start/end by [minutes]. Mutates in place.
  void applyTimeOffset(Activity activity, int minutes) {
    final offset = Duration(minutes: minutes);
    activity.start = activity.start.add(offset);
    if (activity.end != null) {
      activity.end = activity.end!.add(offset);
    }
  }

  /// Shifts every record's timestamp in [records] by [minutes]. Records
  /// without a timestamp are left untouched. Mutates in place.
  void applyRecordTimeOffset(List<Record> records, int minutes) {
    final offset = Duration(minutes: minutes);
    for (final record in records) {
      if (record.timeStamp != null) {
        record.timeStamp = record.timeStamp!.add(offset);
      }
    }
  }

  /// Computes where a split at [minutesSplitPoint] minutes (measured from
  /// the first record's timestamp) falls within [records].
  ///
  /// [records] must be non-empty and sorted by timestamp. Does not mutate
  /// [records]; the caller decides how to reassign the returned
  /// [SplitPlan.secondPartRecords] to a target activity and persist them.
  SplitPlan computeSplitPlan(List<Record> records, int minutesSplitPoint) {
    final splitPoint = Duration(minutes: minutesSplitPoint);
    final watermark = records.first.timeStamp!.add(splitPoint);

    DateTime? firstPartEnd;
    DateTime? secondPartStart;
    var inFirstPart = true;
    var lastRecord = records.first;
    final secondPartRecords = <Record>[];
    for (final record in records) {
      if (record.timeStamp != null && record.timeStamp!.compareTo(watermark) > 0) {
        if (inFirstPart) {
          firstPartEnd = lastRecord.timeStamp;
          secondPartStart = record.timeStamp;
        }
        inFirstPart = false;
        secondPartRecords.add(record);
      }
      lastRecord = record;
    }

    return SplitPlan(
      firstPartEnd: firstPartEnd,
      secondPartStart: secondPartStart,
      secondPartEnd: lastRecord.timeStamp!,
      secondPartRecords: secondPartRecords,
    );
  }
}
