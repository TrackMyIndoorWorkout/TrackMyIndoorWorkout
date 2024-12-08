import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/life_fitness_elliptical_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Life Fitness Elliptical Device constructor tests', () async {
    final sClimber = LifeFitnessEllipticalDescriptor();

    expect(sClimber.sport, ActivityType.elliptical);
    expect(sClimber.fourCC, lifeFitnessEllipticalFourCC);
    expect(sClimber.isMultiSport, false);
  });

  test('Elliptical Device interprets Life Fitness Elliptical flags without Heart Rate properly',
      () async {
    final sClimber = LifeFitnessEllipticalDescriptor();
    const lsb = 0xbe; // 190
    const msb = 0x27; // 39
    const flag = maxUint8 * msb + lsb;
    sClimber.initFlag();
    sClimber.stopWorkout();
    sClimber.processFlag(flag, 33);

    expect(sClimber.speedMetric, isNotNull);
    expect(sClimber.cadenceMetric, isNotNull);
    expect(sClimber.distanceMetric, isNotNull);
    expect(sClimber.powerMetric, isNotNull);
    expect(sClimber.timeMetric, isNotNull);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.caloriesPerHourMetric, isNotNull);
    expect(sClimber.caloriesPerMinuteMetric, isNotNull);
    expect(sClimber.heartRateByteIndex, null);
    expect(sClimber.strokeCountMetric, isNotNull);
    expect(sClimber.resistanceMetric, isNotNull);
  });

  test('Elliptical Device interprets Life Fitness Elliptical flags with Heart Rate properly',
      () async {
    final sClimber = LifeFitnessEllipticalDescriptor();
    const lsb = 0xbe; // 190
    const msb = 0x2f; // 47
    const flag = maxUint8 * msb + lsb;
    sClimber.initFlag();
    sClimber.stopWorkout();
    sClimber.processFlag(flag, 34);

    expect(sClimber.speedMetric, isNotNull);
    expect(sClimber.cadenceMetric, isNotNull);
    expect(sClimber.distanceMetric, isNotNull);
    expect(sClimber.powerMetric, isNotNull);
    expect(sClimber.timeMetric, isNotNull);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.caloriesPerHourMetric, isNotNull);
    expect(sClimber.caloriesPerMinuteMetric, isNotNull);
    expect(sClimber.heartRateByteIndex, 31);
    expect(sClimber.strokeCountMetric, isNotNull);
    expect(sClimber.resistanceMetric, isNotNull);
  });

  test('Elliptical Device interprets Life Fitness Elliptical flags with Heart Rate properly',
      () async {
    final sClimber = LifeFitnessEllipticalDescriptor();
    const lsb = 0xbe; // 190
    const msb = 0x67; // 103
    const flag = maxUint8 * msb + lsb;
    sClimber.initFlag();
    sClimber.stopWorkout();
    sClimber.processFlag(flag, 35);

    expect(sClimber.speedMetric, isNotNull);
    expect(sClimber.cadenceMetric, isNotNull);
    expect(sClimber.distanceMetric, isNotNull);
    expect(sClimber.powerMetric, isNotNull);
    expect(sClimber.timeMetric, isNotNull);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.caloriesPerHourMetric, isNotNull);
    expect(sClimber.caloriesPerMinuteMetric, isNotNull);
    expect(sClimber.heartRateByteIndex, null);
    expect(sClimber.strokeCountMetric, isNotNull);
    expect(sClimber.resistanceMetric, isNotNull);
  });

  group('Elliptical Device interprets Life Fitness Elliptical data properly', () {
    for (final testPair in [
      // Higher speed
      TestPair(
        data: [
          190,
          47,
          0,
          115,
          2,
          45,
          2,
          69,
          0,
          0,
          96,
          0,
          86,
          0,
          152,
          2,
          14,
          0,
          255,
          255,
          60,
          0,
          80,
          0,
          61,
          0,
          6,
          0,
          255,
          255,
          255,
          76,
          46,
          0
        ],
        record: RecordWithSport(
          distance: 69.0,
          elapsed: 46,
          calories: 12,
          power: 80,
          speed: 6.27,
          cadence: 96,
          heartRate: 76,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 66.4,
          resistance: 6,
        ),
      ),
      // Higher power
      TestPair(
        data: [
          190,
          47,
          0,
          99,
          2,
          54,
          2,
          87,
          0,
          0,
          94,
          0,
          87,
          0,
          66,
          3,
          18,
          0,
          255,
          255,
          60,
          0,
          80,
          0,
          64,
          0,
          7,
          0,
          255,
          255,
          255,
          78,
          57,
          00
        ],
        record: RecordWithSport(
          distance: 87.0,
          elapsed: 57,
          calories: 5,
          power: 80,
          speed: 6.11,
          cadence: 94,
          heartRate: 78,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 83.4,
          resistance: 6,
        ),
      ),
      // No HR
      TestPair(
        data: [
          190,
          39,
          0,
          51,
          2,
          56,
          2,
          105,
          0,
          0,
          88,
          0,
          88,
          0,
          231,
          3,
          22,
          0,
          255,
          255,
          60,
          0,
          61,
          0,
          65,
          0,
          8,
          0,
          255,
          255,
          255,
          68,
          0
        ],
        record: RecordWithSport(
          distance: 105.0,
          elapsed: 68,
          calories: 12,
          power: 61,
          speed: 5.63,
          cadence: 88,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 99.9,
          resistance: 6,
        ),
      ),
      TestPair(
        data: [
          190,
          103,
          0,
          35,
          2,
          47,
          2,
          140,
          0,
          0,
          86,
          0,
          85,
          0,
          37,
          5,
          26,
          0,
          255,
          255,
          20,
          0,
          59,
          0,
          57,
          0,
          4,
          0,
          255,
          255,
          255,
          93,
          0,
          57,
          0
        ],
        record: RecordWithSport(
          distance: 140.0,
          elapsed: 93,
          calories: 12,
          power: 59,
          speed: 5.47,
          cadence: 86,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 131.7,
          resistance: 2,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final sClimber = LifeFitnessEllipticalDescriptor();
        sClimber.initFlag();
        expect(sClimber.isDataProcessable(testPair.data), true);
        sClimber.stopWorkout();

        final record = sClimber.wrappedStubRecord(testPair.data)!;

        expect(record.id, Isar.autoIncrement);
        expect(record.id, testPair.record.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.resistance, testPair.record.resistance);
      });
    }
  });
}
