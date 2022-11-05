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
  test('LifePro FlexStride Pro Device constructor tests', () async {
    final xTrainer = DeviceFactory.getGenericFTMSCrossTrainer();

    expect(xTrainer.defaultSport, ActivityType.elliptical);
    expect(xTrainer.fourCC, genericFTMSCrossTrainerFourCC);
    expect(xTrainer.isMultiSport, false);
  });

  test('Cross Trainer Device interprets LifePro FlexStride Pro flags properly', () async {
    final xTrainer = DeviceFactory.getGenericFTMSCrossTrainer();
    const lsb = 12;
    const msb = 33;
    const flag = maxUint8 * msb + lsb;
    xTrainer.initFlag();
    xTrainer.stopWorkout();
    xTrainer.processFlag(flag);

    expect(xTrainer.speedMetric, isNotNull);
    expect(xTrainer.cadenceMetric, isNotNull);
    expect(xTrainer.distanceMetric, isNotNull);
    expect(xTrainer.powerMetric, isNotNull);
    expect(xTrainer.caloriesMetric, null);
    expect(xTrainer.timeMetric, isNotNull);
    expect(xTrainer.caloriesPerHourMetric, null);
    expect(xTrainer.caloriesPerMinuteMetric, null);
    expect(xTrainer.heartRateByteIndex, null);
  });

  group('Cross Trainer Device interprets LifePro FlexStride Pro data properly', () {
    for (final testPair in [
      TestPair(
        data: [12, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: 32,
          calories: null,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [12, 33, 0, 2, 0, 0, 0, 0, 6, 0, 0, 0, 5, 0, 36, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: 36,
          calories: null,
          power: 5,
          speed: 0.02,
          cadence: 6,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [12, 33, 0, 116, 0, 4, 0, 0, 100, 0, 0, 0, 90, 0, 56, 0],
        record: RecordWithSport(
          distance: 4.0,
          elapsed: 56,
          calories: null,
          power: 90,
          speed: 1.16,
          cadence: 100,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [12, 33, 0, 84, 0, 26, 0, 0, 74, 0, 0, 0, 66, 0, 144, 0],
        record: RecordWithSport(
          distance: 26.0,
          elapsed: 144,
          calories: null,
          power: 66,
          speed: 0.84,
          cadence: 74,
          heartRate: null,
          sport: ActivityType.elliptical,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final xTrainer = DeviceFactory.getGenericFTMSCrossTrainer();
        xTrainer.initFlag();
        expect(xTrainer.isDataProcessable(testPair.data), true);
        xTrainer.stopWorkout();

        final record = xTrainer.wrappedStubRecord(testPair.data)!;

        expect(record.id, null);
        expect(record.id, testPair.record.id);
        expect(record.activityId, null);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.sport, testPair.record.sport);
      });
    }
  });
}
