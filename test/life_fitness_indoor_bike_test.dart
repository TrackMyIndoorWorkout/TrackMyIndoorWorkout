import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/life_fitness_bike_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Life Fitness Indoor Bike constructor tests', () async {
    final bike = LifeFitnessBikeDescriptor();

    expect(bike.sport, ActivityType.ride);
    expect(bike.fourCC, lifeFitnessBikeFourCC);
    expect(bike.isMultiSport, false);
  });

  test('Life Fitness Indoor Bike interprets FTMS Indoor Bike Data flags wo Heart Rate properly',
      () async {
    final bike = LifeFitnessBikeDescriptor();
    const lsb = 250;
    const msb = 9;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag, 26);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, isNotNull);
    expect(bike.caloriesPerMinuteMetric, isNotNull);
    expect(bike.strokeCountMetric, null);
    expect(bike.heartRateByteIndex, null);
    expect(bike.resistanceMetric, isNotNull);
  });

  test('Life Fitness Indoor Bike interprets FTMS Indoor Bike Data flags w Heart Rate properly',
      () async {
    final bike = LifeFitnessBikeDescriptor();
    const lsb = 250;
    const msb = 11;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag, 27);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, isNotNull);
    expect(bike.caloriesPerMinuteMetric, isNotNull);
    expect(bike.strokeCountMetric, null);
    expect(bike.heartRateByteIndex, 24);
    expect(bike.resistanceMetric, isNotNull);
  });

  group('Life Fitness Indoor Bike interprets FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [
          250,
          9,
          45,
          9,
          242,
          8,
          116,
          0,
          119,
          0,
          101,
          0,
          0,
          13,
          0,
          102,
          0,
          97,
          0,
          2,
          0,
          255,
          255,
          255,
          17,
          0,
        ],
        record: RecordWithSport(
          distance: 101.0,
          elapsed: 17,
          calories: 2,
          power: 102,
          speed: 23.49,
          cadence: 58,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: 13,
        ),
      ),
      // High RPM
      TestPair(
        data: [
          250,
          11,
          50,
          12,
          137,
          9,
          198,
          0,
          124,
          0,
          196,
          1,
          0,
          13,
          0,
          206,
          0,
          112,
          0,
          10,
          0,
          255,
          255,
          255,
          83,
          68,
          0,
        ],
        record: RecordWithSport(
          distance: 452.0,
          elapsed: 68,
          calories: 10,
          power: 206,
          speed: 31.22,
          cadence: 99,
          heartRate: 83,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: 13,
        ),
      ),
      // High Power (and speed)
      TestPair(
        data: [
          250,
          11,
          85,
          14,
          190,
          9,
          204,
          0,
          177,
          0,
          11,
          2,
          0,
          19,
          0,
          54,
          1,
          118,
          0,
          12,
          0,
          255,
          255,
          255,
          89,
          77,
          0,
        ],
        record: RecordWithSport(
          distance: 523.0,
          elapsed: 77,
          calories: 12,
          power: 310,
          speed: 36.69,
          cadence: 102,
          heartRate: 89,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: 19,
        ),
      ),
      TestPair(
        data: [
          250,
          11,
          247,
          4,
          193,
          9,
          36,
          0,
          120,
          0,
          240,
          2,
          0,
          7,
          0,
          25,
          0,
          120,
          0,
          18,
          0,
          255,
          255,
          255,
          100,
          109,
          0,
        ],
        record: RecordWithSport(
          distance: 752.0,
          elapsed: 109,
          calories: 18,
          power: 25,
          speed: 12.71,
          cadence: 18,
          heartRate: 100,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: 7,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final bike = LifeFitnessBikeDescriptor();
        bike.initFlag();
        expect(bike.isDataProcessable(testPair.data), true);
        bike.stopWorkout();

        final record = bike.wrappedStubRecord(testPair.data)!;

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
