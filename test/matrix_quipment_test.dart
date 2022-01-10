import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/treadmill_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Generic Treadmill constructor tests', () async {
    final treadmill = deviceMap[genericFTMSTreadmillFourCC]!;

    expect(treadmill.canMeasureHeartRate, false);
    expect(treadmill.defaultSport, ActivityType.run);
    expect(treadmill.fourCC, genericFTMSTreadmillFourCC);
  });

  test('Generic Indoor Bike constructor tests', () async {
    final indoorBike = deviceMap[genericFTMSBikeFourCC]!;

    expect(indoorBike.canMeasureHeartRate, true);
    expect(indoorBike.canMeasureCalories, true);
    expect(indoorBike.defaultSport, ActivityType.ride);
    expect(indoorBike.fourCC, genericFTMSBikeFourCC);
  });

  test('GRun interprets FTMS Matrix Data flags properly', () async {
    final treadmill = deviceMap[genericFTMSTreadmillFourCC] as TreadmillDeviceDescriptor;
    const lsb = 158;
    const msb = 27;
    const flag = maxUint8 * msb + lsb;
    treadmill.stopWorkout();

    treadmill.processFlag(flag);

    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.distanceMetric, isNotNull);
    expect(treadmill.paceMetric, null);
    expect(treadmill.powerMetric, isNotNull);
    expect(treadmill.caloriesMetric, isNotNull);
    expect(treadmill.caloriesPerHourMetric, isNotNull);
    expect(treadmill.caloriesPerMinuteMetric, isNotNull);
    expect(treadmill.heartRateByteIndex, 22);
    expect(treadmill.timeMetric, null);
    expect(treadmill.powerMetric, isNotNull);
    expect(treadmill.byteCounter, 30);
  });

  group('GRun interprets FTMS Matrix Data properly', () {
    for (final testPair in [
      TestPair(
        data: [158, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 127, 0, 0, 255, 255, 0, 0, 0],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 122,
          speed: 29.1,
          cadence: 120,
          heartRate: 84,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final treadmill = deviceMap[genericFTMSTreadmillFourCC]!;
        treadmill.stopWorkout();

        final record = treadmill.stubRecord(testPair.data)!;

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
