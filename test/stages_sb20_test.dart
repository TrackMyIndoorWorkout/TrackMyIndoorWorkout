import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Stages SB20 constructor tests', () async {
    final bike = DeviceFactory.getStagesSB20();

    expect(bike.sport, ActivityType.ride);
    expect(bike.fourCC, stagesSB20FourCC);
    expect(bike.isMultiSport, false);
  });

  test('Stages SB20 interprets FTMS Indoor Bike Data 1 flags properly', () async {
    final bike = DeviceFactory.getStagesSB20();
    const lsb = 0;
    const msb = 0;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, null);
    expect(bike.distanceMetric, null);
    expect(bike.powerMetric, null);
    expect(bike.caloriesMetric, null);
    expect(bike.timeMetric, null);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
    expect(bike.heartRateByteIndex, null);
  });

  test('Stages SB20 interprets FTMS Indoor Bike Data 2 flags properly', () async {
    final bike = DeviceFactory.getStagesSB20();
    const lsb = 17; // 0x11
    const msb = 0;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, null);
    expect(bike.cadenceMetric, null);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, null);
    expect(bike.caloriesMetric, null);
    expect(bike.timeMetric, null);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
    expect(bike.heartRateByteIndex, null);
  });

  test('Stages SB20 interprets FTMS Indoor Bike Data 3 flags properly', () async {
    final bike = DeviceFactory.getStagesSB20();
    const lsb = 197; // 0xC5
    const msb = 0;
    const flag = maxUint8 * msb + lsb;
    bike.initFlag();
    bike.stopWorkout();
    bike.processFlag(flag);

    expect(bike.speedMetric, null);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, null);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, null);
    expect(bike.timeMetric, null);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
    expect(bike.heartRateByteIndex, null);
  });

  group('Stages SB20 interprets FTMS Indoor Bike Data properly', () {
    for (final testPair in [
      TestPair(
        data: [0, 0, 131, 6],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: null,
          speed: 16.67,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [0, 0, 233, 13],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: null,
          speed: 35.61,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [17, 0, 4, 1, 0],
        record: RecordWithSport(
          distance: 260.0,
          elapsed: null,
          calories: null,
          power: null,
          speed: null,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [17, 0, 181, 3, 0],
        record: RecordWithSport(
          distance: 949.0,
          elapsed: null,
          calories: null,
          power: null,
          speed: null,
          cadence: null,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [197, 0, 182, 0, 93, 2, 0, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 605,
          speed: null,
          cadence: 91,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [197, 0, 224, 0, 35, 3, 0, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 803,
          speed: null,
          cadence: 112,
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
        final bike = DeviceFactory.getStagesSB20();
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
