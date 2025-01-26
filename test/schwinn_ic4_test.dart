import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Schwinn IC4 constructor tests', () async {
    final bike = DeviceFactory.getSchwinnIcBike();

    expect(bike.sport, ActivityType.ride);
    expect(bike.fourCC, schwinnICBikeFourCC);
    expect(bike.isMultiSport, false);
  });

  test('Schwinn IC4 interprets FTMS Indoor Bike Data flags properly', () async {
    final bike = DeviceFactory.getSchwinnIcBike();
    const lsb = 68;
    const msb = 2;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag, 9);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, null);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, null);
    expect(bike.timeMetric, null);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
    expect(bike.strokeCountMetric, null);
    expect(bike.heartRateByteIndex, 8);
    expect(bike.resistanceMetric, null);
  });

  group('Schwinn IC4 interprets FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [68, 2, 94, 11, 240, 0, 122, 0, 84],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 122,
          speed: 29.1,
          cadence: 120,
          heartRate: 84,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 154, 11, 250, 0, 128, 0, 101],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 128,
          speed: 29.7,
          cadence: 125,
          heartRate: 101,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 4, 16, 250, 0, 43, 1, 115],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 299,
          speed: 41.0,
          cadence: 125,
          heartRate: 115,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 160, 20, 106, 0, 117, 2, 117],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 629,
          speed: 52.8,
          cadence: 53,
          heartRate: 117,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 54, 21, 114, 0, 180, 2, 90],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 692,
          speed: 54.3,
          cadence: 57,
          heartRate: 90,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 230, 20, 110, 0, 148, 2, 116],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 660,
          speed: 53.5,
          cadence: 55,
          heartRate: 116,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
        ),
      ),
      TestPair(
        data: [68, 2, 0, 0, 0, 0, 0, 0, 85],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: 85,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
          resistance: null,
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
