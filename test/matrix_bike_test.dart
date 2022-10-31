import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/matrix_bike_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/record.dart';
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
  test('Matrix Bike constructor tests', () async {
    final bike = MatrixBikeDescriptor();

    expect(bike.defaultSport, ActivityType.ride);
    expect(bike.fourCC, matrixBikeFourCC);
  });

  group('Matrix Bike interprets faulty FTMS Treadmill Data flags properly', () {
    for (final flagBytes in [
      const FlagBytes(lsb: 254, msb: 21, description: "before workout"),
      const FlagBytes(lsb: 254, msb: 29, description: "during workout"),
    ]) {
      test(flagBytes.description, () async {
        final bike = MatrixBikeDescriptor();
        final flag = maxUint8 * flagBytes.msb + flagBytes.lsb;
        bike.stopWorkout();

        bike.processFlag(flag);

        expect(bike.speedMetric, isNotNull);
        expect(bike.cadenceMetric, isNotNull);
        expect(bike.distanceMetric, isNotNull);
        expect(bike.powerMetric, isNotNull);
        expect(bike.caloriesMetric, null);
        expect(bike.timeMetric, null);
        expect(bike.caloriesPerHourMetric, null);
        expect(bike.caloriesPerMinuteMetric, null);
        expect(bike.heartRateByteIndex, null);
      });
    }
  });

  group('Matrix Bike interprets faulty FTMS Treadmill Data properly', () {
    for (final testPair in [
      TestPair(
        data: [254, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: null,
          calories: null,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [254, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: null,
          calories: null,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [254, 29, 131, 12, 51, 12, 134, 0, 128, 0, 193, 9, 0, 13, 0, 162, 0, 157, 0, 54],
        record: RecordWithSport(
          distance: 2497.0,
          elapsed: null,
          calories: null,
          power: 162,
          speed: 32.03,
          cadence: 67,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final bike = MatrixBikeDescriptor();
        bike.initFlag();
        expect(bike.isDataProcessable(testPair.data), true);
        bike.stopWorkout();

        final record = bike.wrappedStubRecord(testPair.data)!;

        expect(record.id, null);
        expect(record.id, testPair.record.id);
        expect(record.activityId, null);
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
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
      });
    }
  });
}
