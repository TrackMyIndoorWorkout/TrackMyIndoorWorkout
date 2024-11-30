import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/life_fitness_treadmill_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Life Fitness Treadmill constructor tests', () async {
    final treadmill = LifeFitnessTreadmillDescriptor();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.fourCC, lifeFitnessTreadmillFourCC);
    expect(treadmill.isMultiSport, false);
  });

  test('Life Fitness Treadmill interprets FTMS Treadmill Data flags wo heart rate properly',
      () async {
    final treadmill = LifeFitnessTreadmillDescriptor();
    const flag = maxUint8 * 4 + 158;
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 24);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, isNotNull);
    expect(treadmill.timeMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, null);
    expect(treadmill.resistanceMetric, null);
  });

  test('Life Fitness Treadmill interprets FTMS Treadmill Data flags with heart rate properly',
      () async {
    final treadmill = LifeFitnessTreadmillDescriptor();
    const flag = maxUint8 * 5 + 158;
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 25);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, isNotNull);
    expect(treadmill.timeMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, 22);
    expect(treadmill.resistanceMetric, null);
  });

  test('Life Fitness Treadmill interprets FTMS Treadmill Data flags with remaining time properly',
      () async {
    final treadmill = LifeFitnessTreadmillDescriptor();
    const flag = maxUint8 * 12 + 158;
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 26);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, isNotNull);
    expect(treadmill.timeMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, null);
    expect(treadmill.resistanceMetric, null);
  });

  group('Life Fitness Treadmill interprets faulty FTMS Treadmill Data properly', () {
    for (final testPair in [
      TestPair(
        data: [
          158,
          4,
          115,
          2,
          51,
          2,
          37,
          0,
          0,
          60,
          0,
          255,
          127,
          0,
          0,
          255,
          127,
          2,
          0,
          255,
          255,
          255,
          31,
          0
        ],
        record: RecordWithSport(
          distance: 37.0,
          elapsed: 31,
          calories: 2,
          power: null,
          speed: 6.27,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [
          158,
          4,
          146,
          1,
          77,
          2,
          122,
          0,
          0,
          130,
          0,
          255,
          127,
          171,
          0,
          255,
          127,
          16,
          0,
          255,
          255,
          255,
          77,
          0
        ],
        record: RecordWithSport(
          distance: 122.0,
          elapsed: 77,
          calories: 16,
          power: null,
          speed: 4.02,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [
          158,
          5,
          23,
          5,
          146,
          2,
          251,
          0,
          0,
          0,
          0,
          255,
          127,
          124,
          0,
          255,
          127,
          27,
          0,
          255,
          255,
          255,
          105,
          138,
          0
        ],
        record: RecordWithSport(
          distance: 251.0,
          elapsed: 138,
          calories: 27,
          power: null,
          speed: 13.03,
          cadence: null,
          heartRate: 105,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [
          158,
          12,
          80,
          0,
          189,
          2,
          83,
          1,
          0,
          0,
          0,
          255,
          127,
          124,
          0,
          255,
          127,
          35,
          0,
          255,
          255,
          255,
          173,
          0,
          59,
          0
        ],
        record: RecordWithSport(
          distance: 339.0,
          elapsed: 173,
          calories: 35,
          power: null,
          speed: 0.8,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final treadmill = LifeFitnessTreadmillDescriptor();
        treadmill.initFlag();
        expect(treadmill.isDataProcessable(testPair.data), true);
        treadmill.stopWorkout();

        final record = treadmill.wrappedStubRecord(testPair.data)!;

        expect(record.id, Isar.autoIncrement);
        expect(record.id, testPair.record.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.calories, testPair.record.calories);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.pace, testPair.record.pace);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.resistance, testPair.record.resistance);
      });
    }
  });
}
