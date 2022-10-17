import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
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

  test('Technogym Skillrow Rower Device constructor tests', () async {
    final rower = DeviceFactory.getGenericFTMSRower();

    expect(rower.defaultSport, ActivityType.rowing);
    expect(rower.fourCC, genericFTMSRowerFourCC);
    expect(rower.isMultiSport, false);
  });

  test('Rower Device interprets Technogym Skillrow flags 1 properly', () async {
    final rower = DeviceFactory.getGenericFTMSRower();
    const lsb = 2;
    const msb = 33;
    const flag = maxUint8 * msb + lsb;
    rower.stopWorkout();

    rower.processFlag(flag);

    expect(rower.strokeRateMetric, isNotNull);
    expect(rower.strokeCountMetric, isNotNull);
    expect(rower.paceMetric, null);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, null);
    expect(rower.powerMetric, null);
    expect(rower.caloriesMetric, isNotNull);
    expect(rower.timeMetric, null);
    expect(rower.caloriesPerHourMetric, isNotNull);
    expect(rower.caloriesPerMinuteMetric, isNotNull);
    expect(rower.heartRateByteIndex, null);
  });

  test('Rower Device interprets Technogym Skillrow flags 2 properly', () async {
    final rower = DeviceFactory.getGenericFTMSRower();
    const lsb = 253;
    const msb = 12;
    const flag = maxUint8 * msb + lsb;
    rower.stopWorkout();

    rower.processFlag(flag);

    expect(rower.strokeRateMetric, null);
    expect(rower.strokeCountMetric, null);
    expect(rower.paceMetric, isNotNull);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, isNotNull);
    expect(rower.powerMetric, isNotNull);
    expect(rower.caloriesMetric, null);
    expect(rower.timeMetric, isNotNull);
    expect(rower.caloriesPerHourMetric, null);
    expect(rower.caloriesPerMinuteMetric, null);
    expect(rower.heartRateByteIndex, null);
  });

  group('Rower Device interprets Technogym Skillrow data properly', () {
    for (final testPair in [
      TestPair(
        data: [2, 33, 52, 19, 0, 49, 4, 0, 255, 255, 255, 184, 1, 0, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: 4,
          power: null,
          speed: null,
          cadence: 26,
          heartRate: null,
          pace: null,
          sport: ActivityType.rowing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [253, 12, 128, 0, 0, 164, 0, 175, 0, 79, 0, 70, 0, 7, 0, 51, 45, 0],
        record: RecordWithSport(
          distance: 128.0,
          elapsed: 45,
          calories: null,
          power: 79,
          speed: 10.97560975609756,
          cadence: null,
          heartRate: null,
          pace: 164.0,
          sport: ActivityType.rowing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final rower = DeviceFactory.getGenericFTMSRower();
        rower.initFlag();
        expect(rower.isDataProcessable(testPair.data), true);
        rower.stopWorkout();

        final record = rower.wrappedStubRecord(testPair.data)!;

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
