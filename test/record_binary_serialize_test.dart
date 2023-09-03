import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Indoor Bike interprets FTMS Indoor Bike Data flags properly', () async {
    final bike = DeviceFactory.getGenericFTMSBike();
    const lsb = 84;
    const msb = 11;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, isNotNull);
    expect(bike.caloriesPerMinuteMetric, isNotNull);
    expect(bike.heartRateByteIndex, 16);
  });

  group('Record binary serializes FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [84, 11, 94, 11, 26, 1, 56, 144, 13, 37, 3, 87, 4, 0, 0, 0, 155, 136, 19],
        record: RecordWithSport(
          distance: 888888.0,
          elapsed: 5000,
          calories: 1111,
          power: 805,
          speed: 29.1,
          cadence: 141,
          heartRate: 155,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: 0.0,
          caloriesPerMinute: 0.0,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final bike = DeviceFactory.getGenericFTMSBike();
        bike.initFlag();
        expect(bike.isDataProcessable(testPair.data), true);
        bike.stopWorkout();

        final record = bike.wrappedStubRecord(testPair.data)!;

        // Test 1
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
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);

        // Test 2: idempotent
        expect(listEquals(testPair.data, testPair.record.binarySerialize()), true);
      });
    }
  });

  test('Kayak ergometer interprets FTMS Rower Data flags properly', () async {
    final ergometer = DeviceFactory.getGenericFTMSKayaker();
    const lsb = 44;
    const msb = 11;
    const flag = maxUint8 * msb + lsb;
    ergometer.initFlag();
    ergometer.stopWorkout();
    ergometer.processFlag(flag);

    expect(ergometer.strokeRateMetric, isNotNull);
    expect(ergometer.strokeCountMetric, isNotNull);
    expect(ergometer.speedMetric, null);
    expect(ergometer.paceMetric, isNotNull);
    expect(ergometer.cadenceMetric, null);
    expect(ergometer.distanceMetric, isNotNull);
    expect(ergometer.powerMetric, isNotNull);
    expect(ergometer.caloriesMetric, isNotNull);
    expect(ergometer.timeMetric, isNotNull);
    expect(ergometer.caloriesPerHourMetric, isNotNull);
    expect(ergometer.caloriesPerMinuteMetric, isNotNull);
    expect(ergometer.heartRateByteIndex, 17);
  });

  group('Record binary serializes FTMS Rower Data properly', () {
    for (final testPair in [
      TestPair(
        data: [44, 11, 216, 112, 23, 56, 144, 13, 118, 2, 37, 3, 87, 4, 0, 0, 0, 155, 136, 19],
        record: RecordWithSport(
          distance: 888888.0,
          elapsed: 5000,
          calories: 1111,
          power: 805,
          speed: null,
          cadence: 108,
          strokeCount: 6000.0,
          heartRate: 155,
          pace: 630.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 0.0,
          caloriesPerMinute: 0.0,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final ergometer = DeviceFactory.getGenericFTMSKayaker();
        ergometer.initFlag();
        expect(ergometer.isDataProcessable(testPair.data), true);
        ergometer.stopWorkout();

        final record = ergometer.wrappedStubRecord(testPair.data)!;

        // Test 1
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
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);

        // Test 2: idempotent
        expect(listEquals(testPair.data, testPair.record.binarySerialize()), true);
      });
    }
  });
}
