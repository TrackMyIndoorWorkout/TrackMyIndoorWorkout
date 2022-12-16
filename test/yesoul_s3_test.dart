import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Yesoul S3 constructor tests', () async {
    final bike = DeviceFactory.getYesoulS3();

    expect(bike.sport, ActivityType.ride);
    expect(bike.fourCC, yesoulS3FourCC);
    expect(bike.isMultiSport, false);
  });

  test('Yesoul S3 interprets FTMS Indoor Bike Data 1 flags properly', () async {
    final bike = DeviceFactory.getYesoulS3();
    const lsb = 0;
    const msb = 8;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, null);
    expect(bike.distanceMetric, null);
    expect(bike.powerMetric, null);
    expect(bike.caloriesMetric, null);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
    expect(bike.heartRateByteIndex, null);
  });

  test('Yesoul S3 interprets FTMS Indoor Bike Data 2 flags properly', () async {
    final bike = DeviceFactory.getYesoulS3();
    const lsb = 245; // 0xF5
    const msb = 1;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, null);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, null);
    expect(bike.caloriesPerHourMetric, isNotNull);
    expect(bike.caloriesPerMinuteMetric, isNotNull);
    expect(bike.heartRateByteIndex, null);
  });

  group('Yesoul S3 interprets FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [0, 8, 22, 10, 53, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: 53,
          calories: null,
          power: null,
          speed: 25.82,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [0, 8, 40, 8, 119, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: 119,
          calories: null,
          power: null,
          speed: 20.88,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [0, 8, 0, 0, 122, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: 122,
          calories: null,
          power: null,
          speed: 0.0,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [245, 1, 136, 0, 246, 0, 0, 53, 0, 107, 0, 71, 0, 4, 0, 255, 255, 255],
        record: RecordWithSport(
          distance: 246.0,
          elapsed: null,
          calories: 4,
          power: 107,
          speed: null,
          cadence: 68,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [245, 1, 134, 0, 253, 0, 0, 53, 0, 105, 0, 72, 0, 5, 0, 255, 255, 255],
        record: RecordWithSport(
          distance: 253.0,
          elapsed: null,
          calories: 5,
          power: 105,
          speed: null,
          cadence: 67,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [245, 1, 110, 0, 132, 2, 0, 52, 0, 76, 0, 87, 0, 13, 0, 255, 255, 255],
        record: RecordWithSport(
          distance: 644.0,
          elapsed: null,
          calories: 13,
          power: 76,
          speed: null,
          cadence: 55,
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
        final bike = DeviceFactory.getYesoulS3();
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
