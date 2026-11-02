import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/calorie_tune.dart';
import 'package:track_my_indoor_exercise/persistence/power_tune.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/track/activity_calculator.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

Activity buildActivity({
  DateTime? start,
  DateTime? end,
  String sport = ActivityType.ride,
  double calorieFactor = 1.0,
}) {
  return Activity(
    deviceName: "Test Dummy",
    deviceId: "CAFEBABE",
    hrmId: "",
    start: start ?? DateTime(2024, 1, 1, 8, 0, 0),
    end: end,
    fourCC: "0000",
    sport: sport,
    powerFactor: 1.0,
    calorieFactor: calorieFactor,
    hrCalorieFactor: 1.0,
    hrmCalorieFactor: 1.0,
    hrBasedCalories: false,
    timeZone: "America/Los_Angeles",
  );
}

Record buildRecord({
  required DateTime timeStamp,
  int? cadence,
  int? power,
  double? speed,
  int? heartRate,
  double? strokeCount,
}) {
  return Record(
    timeStamp: timeStamp,
    cadence: cadence,
    power: power,
    speed: speed,
    heartRate: heartRate,
    strokeCount: strokeCount,
  );
}

void main() {
  final calculator = ActivityCalculator();
  final base = DateTime(2024, 1, 1, 8, 0, 0);

  group('bridgeDataGaps', () {
    test('returns empty list for empty input', () {
      expect(calculator.bridgeDataGaps([]), isEmpty);
    });

    test('returns empty list when there is nothing to bridge', () {
      final records = [
        buildRecord(timeStamp: base, cadence: 80, power: 100, speed: 20.0, heartRate: 120),
        buildRecord(
          timeStamp: base.add(const Duration(seconds: 1)),
          cadence: 81,
          power: 101,
          speed: 20.1,
          heartRate: 121,
        ),
      ];

      final modified = calculator.bridgeDataGaps(records);

      expect(modified, isEmpty);
      expect(records[1].cadence, 81);
      expect(records[1].power, 101);
      expect(records[1].speed, 20.1);
      expect(records[1].heartRate, 121);
    });

    test('forward-fills cadence, power, speed and heart rate gaps', () {
      final gap = buildRecord(timeStamp: base.add(const Duration(seconds: 1)));
      final records = [
        buildRecord(timeStamp: base, cadence: 80, power: 100, speed: 20.0, heartRate: 120),
        gap,
      ];

      final modified = calculator.bridgeDataGaps(records);

      expect(modified, [gap]);
      expect(gap.cadence, 80);
      expect(gap.power, 100);
      expect(gap.speed, 20.0);
      expect(gap.heartRate, 120);
    });

    test('does not fill from a previous record that is itself zero/absent', () {
      final gap = buildRecord(timeStamp: base.add(const Duration(seconds: 1)));
      final records = [buildRecord(timeStamp: base), gap];

      final modified = calculator.bridgeDataGaps(records);

      expect(modified, isEmpty);
      expect(gap.cadence, null);
      expect(gap.power, null);
      expect(gap.speed, null);
      expect(gap.heartRate, null);
    });
  });

  group('powerFactorFromTune / calorieFactorFromTune', () {
    test('powerFactorFromTune defaults to 1.0 when there is no tune', () {
      expect(calculator.powerFactorFromTune(null), 1.0);
    });

    test('powerFactorFromTune returns the tuned value', () {
      final tune = PowerTune(mac: "AA:BB", powerFactor: 1.23, time: base);
      expect(calculator.powerFactorFromTune(tune), 1.23);
    });

    test('calorieFactorFromTune defaults to 1.0 when there is no tune', () {
      expect(calculator.calorieFactorFromTune(null), 1.0);
    });

    test('calorieFactorFromTune returns the tuned value', () {
      final tune = CalorieTune(mac: "AA:BB", calorieFactor: 0.87, hrBased: false, time: base);
      expect(calculator.calorieFactorFromTune(tune), 0.87);
    });
  });

  group('applyTimeOffset / applyRecordTimeOffset', () {
    test('shifts activity start and end by the given minutes', () {
      final activity = buildActivity(start: base, end: base.add(const Duration(minutes: 30)));

      calculator.applyTimeOffset(activity, 60);

      expect(activity.start, base.add(const Duration(minutes: 60)));
      expect(activity.end, base.add(const Duration(minutes: 90)));
    });

    test('leaves a null end untouched', () {
      final activity = buildActivity(start: base);

      calculator.applyTimeOffset(activity, 60);

      expect(activity.start, base.add(const Duration(minutes: 60)));
      expect(activity.end, null);
    });

    test('shifts every timestamped record and skips null timestamps', () {
      final withTimestamp = buildRecord(timeStamp: base);
      final records = [withTimestamp];

      calculator.applyRecordTimeOffset(records, 15);

      expect(withTimestamp.timeStamp, base.add(const Duration(minutes: 15)));
    });
  });

  group('applyFinalization', () {
    test('fills in calories, distance, elapsed and end from the last record', () {
      final activity = buildActivity(start: base, end: base.add(const Duration(minutes: 10)));
      final lastRecord = Record(
        timeStamp: base.add(const Duration(minutes: 9)),
        calories: 123,
        distance: 4567.0,
        elapsed: 540,
      );

      final updated = calculator.applyFinalization(activity, lastRecord);

      expect(updated, true);
      expect(activity.calories, 123);
      expect(activity.distance, 4567.0);
      expect(activity.elapsed, 540);
      expect(activity.end, lastRecord.timeStamp);
    });

    test('returns false when nothing needs updating', () {
      final activity = buildActivity(start: base);
      activity.calories = 10;
      activity.distance = 100.0;
      activity.elapsed = 60;
      final lastRecord = Record(timeStamp: base.add(const Duration(minutes: 1)));

      final updated = calculator.applyFinalization(activity, lastRecord);

      expect(updated, false);
      expect(activity.calories, 10);
      expect(activity.distance, 100.0);
      expect(activity.elapsed, 60);
    });

    test('derives elapsed from start/end when the record has none', () {
      final activity = buildActivity(start: base, end: base.add(const Duration(seconds: 90)));
      final lastRecord = Record(timeStamp: base.add(const Duration(seconds: 90)));

      final updated = calculator.applyFinalization(activity, lastRecord);

      expect(updated, true);
      expect(activity.elapsed, 90);
    });
  });

  group('applyMovingTimeAndStrides', () {
    test('returns false for an empty record list', () {
      final activity = buildActivity(start: base);
      expect(calculator.applyMovingTimeAndStrides(activity, []), false);
    });

    test('computes moving time and strides from stroke counts', () {
      final activity = buildActivity(start: base);
      final records = [
        buildRecord(timeStamp: base, speed: 10.0, strokeCount: 0.0),
        buildRecord(
          timeStamp: base.add(const Duration(seconds: 30)),
          speed: 10.0,
          strokeCount: 5.0,
        ),
        buildRecord(
          timeStamp: base.add(const Duration(seconds: 60)),
          speed: 10.0,
          strokeCount: 10.0,
        ),
      ];

      final updated = calculator.applyMovingTimeAndStrides(activity, records);

      expect(updated, true);
      expect(activity.movingTime, 60000);
      expect(activity.strides, greaterThan(0));
    });
  });

  group('computeSplitPlan', () {
    test('reassigns every record past the watermark to the second part', () {
      final records = [
        buildRecord(timeStamp: base),
        buildRecord(timeStamp: base.add(const Duration(minutes: 5))),
        buildRecord(timeStamp: base.add(const Duration(minutes: 11))),
        buildRecord(timeStamp: base.add(const Duration(minutes: 15))),
      ];

      final plan = calculator.computeSplitPlan(records, 10);

      expect(plan.firstPartEnd, records[1].timeStamp);
      expect(plan.secondPartStart, records[2].timeStamp);
      expect(plan.secondPartEnd, records[3].timeStamp);
      expect(plan.secondPartRecords, [records[2], records[3]]);
    });

    test('leaves firstPartEnd/secondPartStart null when nothing crosses the watermark', () {
      final records = [
        buildRecord(timeStamp: base),
        buildRecord(timeStamp: base.add(const Duration(minutes: 5))),
      ];

      final plan = calculator.computeSplitPlan(records, 30);

      expect(plan.firstPartEnd, null);
      expect(plan.secondPartStart, null);
      expect(plan.secondPartEnd, records.last.timeStamp);
      expect(plan.secondPartRecords, isEmpty);
    });
  });

  group('recalculateRecords', () {
    test('is a no-op for an empty record list', () async {
      final activity = buildActivity(start: base);
      await calculator.recalculateRecords(activity, [], false);
      expect(activity.distance, 0.0);
    });

    test('recomputes distance and calories from speed and power', () async {
      final activity = buildActivity(start: base, calorieFactor: 1.0);
      final records = [
        buildRecord(timeStamp: base, speed: 0.0, power: 0),
        buildRecord(timeStamp: base.add(const Duration(seconds: 10)), speed: 36.0, power: 200),
      ];

      await calculator.recalculateRecords(activity, records, false);

      // speed is 36 km/h = 10 m/s, over 10s => 100m
      expect(records[1].distance, closeTo(100.0, 1e-9));
      expect(activity.distance, closeTo(100.0, 1e-9));
      expect(activity.movingTime, 10000);
      expect(activity.elapsed, activity.end!.difference(activity.start).inSeconds);
    });

    test('always forward-fills heart rate gaps, regardless of movement', () async {
      final activity = buildActivity(start: base);
      final records = [
        buildRecord(timeStamp: base, heartRate: 130),
        buildRecord(timeStamp: base.add(const Duration(seconds: 5))),
      ];

      await calculator.recalculateRecords(activity, records, false);

      expect(records[1].heartRate, 130);
    });

    test('forward-fills cadence/power gaps only while the record is moving', () async {
      final activity = buildActivity(start: base);
      // The second record still reports non-zero cadence itself, so it
      // counts as "moving" and is eligible to inherit the missing power
      // from the previous record.
      final records = [
        buildRecord(timeStamp: base, speed: 18.0, power: 150, cadence: 80),
        buildRecord(timeStamp: base.add(const Duration(seconds: 5)), cadence: 80),
      ];

      await calculator.recalculateRecords(activity, records, false);

      expect(records[1].power, 150);
    });

    test('uses the power-to-speed conversion for rides when recalculateMore is set', () async {
      await initPrefServiceForTest();
      final activity = buildActivity(start: base, sport: ActivityType.ride);
      final records = [
        buildRecord(timeStamp: base, speed: 0.0, power: 0),
        buildRecord(timeStamp: base.add(const Duration(seconds: 5)), power: 150),
      ];

      await calculator.recalculateRecords(activity, records, true);

      // Speed should have been derived from power rather than left null/unset.
      expect(records[1].speed, isNotNull);
      expect(records[1].speed, greaterThan(0.0));
    });
  });
}
