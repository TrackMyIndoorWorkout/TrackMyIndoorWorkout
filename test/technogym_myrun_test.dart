import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
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

var sampleData = [
  TestPair(
    data: [31, 0, 132, 1, 42, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    record: RecordWithSport(
      distance: 42.0,
      elapsed: null,
      calories: null,
      power: null,
      speed: null,
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
    data: [128, 6, 78, 2, 2, 0, 255, 255, 255, 55, 39, 0],
    record: RecordWithSport(
      distance: null,
      elapsed: 39,
      calories: 2,
      power: null,
      speed: 5.9,
      cadence: null,
      heartRate: null,
      pace: null,
      sport: ActivityType.run,
      caloriesPerHour: null,
      caloriesPerMinute: null,
      strokeCount: null,
    ),
  ),
];

void main() {
  test('Technogym MyRun constructor tests', () async {
    final treadmill = DeviceFactory.getGenericFTMSTreadmill();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.fourCC, genericFTMSTreadmillFourCC);
    expect(treadmill.isMultiSport, false);
  });

  test('Technogym MyRun interprets FTMS Treadmill Data 1 flags properly', () async {
    final treadmill = DeviceFactory.getGenericFTMSTreadmill();
    final flag = maxUint8 * sampleData[0].data[1] + sampleData[0].data[0];
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 15);

    expect(treadmill.speedMetric, null); // only average speed
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, null);
    expect(treadmill.timeMetric, null);
    expect(treadmill.caloriesPerHourMetric, null);
    expect(treadmill.caloriesPerMinuteMetric, null);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, null);
    // Also has Inclination, Ramp Angle setting, Positive and Negative Elevation Gain
  });

  test('Technogym MyRun interprets FTMS Treadmill Data 2 flags properly', () async {
    final treadmill = DeviceFactory.getGenericFTMSTreadmill();
    final flag = maxUint8 * sampleData[1].data[1] + sampleData[1].data[0];
    treadmill.initFlag();
    treadmill.stopWorkout();
    treadmill.processFlag(flag, 12);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, null);
    expect(treadmill.distanceMetric, null);
    expect(treadmill.powerMetric, null);
    expect(treadmill.caloriesMetric, isNotNull); // Also has metabolic equivalent
    expect(treadmill.timeMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.strokeCountMetric, null);
    expect(treadmill.heartRateByteIndex, null);
  });

  group('Technogym MyRun interprets FTMS Treadmill Data properly', () {
    for (final testPair in sampleData) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final treadmill = DeviceFactory.getGenericFTMSTreadmill();
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
