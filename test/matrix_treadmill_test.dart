import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/matrix_treadmill_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class FlagBytes {
  final int lsb;
  final int msb;
  final String description;

  const FlagBytes({required this.lsb, required this.msb, required this.description});
}

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Matrix Treadmill constructor tests', () async {
    final treadmill = MatrixTreadmillDescriptor();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.fourCC, matrixTreadmillFourCC);
  });

  group('Matrix Treadmill interprets faulty FTMS Treadmill Data flags properly', () {
    for (final flagBytes in [
      const FlagBytes(lsb: 158, msb: 27, description: "before workout"),
      const FlagBytes(lsb: 158, msb: 31, description: "during workout"),
    ]) {
      test(flagBytes.description, () async {
        final treadmill = MatrixTreadmillDescriptor();
        final flag = maxUint8 * flagBytes.msb + flagBytes.lsb;
        treadmill.initFlag();
        treadmill.stopWorkout();
        treadmill.processFlag(flag, 20);

        expect(treadmill.speedMetric, isNotNull);
        expect(treadmill.cadenceMetric, null);
        expect(treadmill.distanceMetric, isNotNull);
        expect(treadmill.powerMetric, null);
        expect(treadmill.caloriesMetric, isNotNull);
        expect(treadmill.timeMetric, null);
        expect(treadmill.caloriesPerHourMetric, null);
        expect(treadmill.caloriesPerMinuteMetric, null);
        expect(treadmill.strokeCountMetric, null);
        expect(treadmill.heartRateByteIndex, null);
      });
    }
  });

  test('Matrix Treadmill interprets conforming FTMS Treadmill Data flags 1 properly', () async {
    // Matrix Performance TouchXL packet 1
    final treadmill = MatrixTreadmillDescriptor();
    const flag = maxUint8 * 0 + 159;
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 20);

    expect(treadmill.speedMetric, null);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, isNotNull);
    expect(treadmill.timeMetric, null);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, null);
  });

  test('Matrix Treadmill interprets conforming FTMS Treadmill Data flags 2 properly', () async {
    // Matrix Performance TouchXL packet 2
    final treadmill = MatrixTreadmillDescriptor();
    const flag = maxUint8 * 31 + 0;
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 14);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, null);
    expect(treadmill.powerMetric, isNotNull);
    expect(treadmill.caloriesMetric, null);
    expect(treadmill.timeMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, null);
    expect(treadmill.caloriesPerMinuteMetric, null);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, isNotNull);
  });

  group('Matrix Treadmill interprets faulty FTMS Treadmill Data properly', () {
    for (final testPair in [
      TestPair(
        data: [158, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 127, 0, 0, 255, 255, 0, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: null,
          calories: 0,
          power: null,
          speed: 0.0,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [158, 31, 81, 0, 178, 0, 88, 0, 0, 0, 0, 255, 127, 0, 0, 255, 255, 12, 0, 151],
        record: RecordWithSport(
          distance: 88.0,
          elapsed: null,
          calories: 12,
          power: null,
          speed: 0.81,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [158, 31, 81, 0, 113, 0, 213, 0, 0, 0, 0, 255, 127, 30, 0, 255, 255, 38, 0, 151],
        record: RecordWithSport(
          distance: 213.0,
          elapsed: null,
          calories: 38,
          power: null,
          speed: 0.81,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [158, 31, 198, 3, 148, 2, 62, 1, 0, 90, 0, 255, 127, 50, 0, 255, 255, 37, 0, 244],
        record: RecordWithSport(
          distance: 318.0,
          elapsed: null,
          calories: 37,
          power: null,
          speed: 9.66,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [158, 31, 198, 3, 118, 3, 184, 5, 0, 0, 0, 255, 127, 60, 0, 255, 255, 169, 0, 92],
        record: RecordWithSport(
          distance: 1464.0,
          elapsed: null,
          calories: 169,
          power: null,
          speed: 9.66,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [159, 0, 97, 0, 54, 0, 0, 0, 0, 255, 127, 0, 0, 255, 255, 5, 0, 110, 0, 2],
        record: RecordWithSport(
          distance: 54.0,
          elapsed: null,
          calories: 5,
          power: null,
          speed: null,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: 110.0,
          caloriesPerMinute: 2.0,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [0, 31, 113, 0, 0, 2, 204, 0, 60, 6, 255, 127, 26, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: 204,
          calories: null,
          power: 26,
          speed: 1.13,
          cadence: null,
          heartRate: 0,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final treadmill = MatrixTreadmillDescriptor();
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
      });
    }
  });
}
