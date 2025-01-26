import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Bowflex C7 interprets FTMS Indoor Bike Data flags properly', () async {
    final bike = DeviceFactory.getGenericFTMSBike();
    const lsb = 254;
    const msb = 9;
    // Bowflex C7
    // 254 1111 1110 instant speed, avg speed, instant cadence, avg cadence, instant power, avg power
    //   9 0000 1001 total energy, energy/h, energy/min, elapsed time
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

  group('Bowflex C7 interprets FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [
          254,
          9,
          238,
          8,
          0,
          0,
          114,
          0,
          0,
          0,
          99,
          2,
          0,
          26,
          0,
          64,
          0,
          0,
          0,
          8,
          0,
          18,
          1,
          4,
          89,
          0
        ],
        record: RecordWithSport(
          distance: 611.0,
          elapsed: 89,
          calories: 8,
          power: 64,
          speed: 22.86,
          cadence: 57,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: 274.0,
          caloriesPerMinute: 4.0,
          strokeCount: null,
          resistance: 26,
        ),
      ),
      TestPair(
        data: [
          254,
          9,
          125,
          4,
          0,
          0,
          52,
          0,
          0,
          0,
          13,
          3,
          0,
          26,
          0,
          15,
          0,
          0,
          0,
          10,
          0,
          66,
          0,
          1,
          119,
          0
        ],
        record: RecordWithSport(
          distance: 781.0,
          elapsed: 119,
          calories: 10,
          power: 15,
          speed: 11.49,
          cadence: 26,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: 66.0,
          caloriesPerMinute: 1.0,
          strokeCount: null,
          resistance: 26,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final bike = DeviceFactory.getSchwinnIcBike();
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
