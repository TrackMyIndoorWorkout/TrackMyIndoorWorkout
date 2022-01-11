import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/rower_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('KayakPro Rower Device constructor tests', () async {
    final rower = deviceMap[kayakProGenesisPortFourCC]!;

    expect(rower.canMeasureHeartRate, false);
    expect(rower.defaultSport, ActivityType.kayaking);
    expect(rower.fourCC, kayakProGenesisPortFourCC);
  });

  test('Rower Device interprets KayakPro flags properly', () async {
    final rower = deviceMap[kayakProGenesisPortFourCC] as RowerDeviceDescriptor;
    const lsb = 44;
    const msb = 9;
    const flag = maxUint8 * msb + lsb;
    await initPrefServiceForTest();
    rower.stopWorkout();

    rower.processFlag(flag);

    expect(rower.strokeRateMetric, isNotNull);
    expect(rower.strokeCountMetric, isNotNull);
    expect(rower.paceMetric, isNotNull);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, isNotNull);
    expect(rower.powerMetric, isNotNull);
    expect(rower.caloriesMetric, isNotNull); // It's there but mute
    expect(rower.timeMetric, isNotNull);
    expect(rower.caloriesPerHourMetric, isNotNull);
    expect(rower.caloriesPerMinuteMetric, isNotNull); // It's there but mute
    expect(rower.heartRateByteIndex, null);
  });

  group('Rower Device interprets KayakPro data properly', () {
    for (final testPair in [
      TestPair(
        data: [44, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, maxByte, maxByte, 0, 0, maxByte, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: 0,
          calories: null,
          power: 0,
          speed: null,
          cadence: 0,
          heartRate: 0,
          pace: 0.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 0.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 79, 33, 0, 50, 0, 0, 86, 1, 12, 0, maxByte, maxByte, 89, 1, maxByte, 62, 0],
        record: RecordWithSport(
          distance: 50.0,
          elapsed: 62,
          calories: null,
          power: 12,
          speed: null,
          cadence: 39,
          heartRate: 0,
          pace: 342.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 345.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [
          44,
          9,
          152,
          65,
          0,
          105,
          0,
          0,
          60,
          1,
          16,
          0,
          maxByte,
          maxByte,
          97,
          1,
          maxByte,
          106,
          0
        ],
        record: RecordWithSport(
          distance: 105.0,
          elapsed: 106,
          calories: null,
          power: 16,
          speed: null,
          cadence: 76,
          heartRate: 0,
          pace: 316.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 353.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [
          44,
          9,
          85,
          150,
          0,
          246,
          0,
          0,
          39,
          1,
          20,
          0,
          maxByte,
          maxByte,
          107,
          1,
          maxByte,
          45,
          1
        ],
        record: RecordWithSport(
          distance: 246.0,
          elapsed: 301,
          calories: null,
          power: 20,
          speed: null,
          cadence: 42,
          heartRate: 0,
          pace: 295.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 363.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 177, 184, 0, 48, 1, 0, 0, 1, 30, 0, maxByte, maxByte, 133, 1, maxByte, 91, 1],
        record: RecordWithSport(
          distance: 304.0,
          elapsed: 347,
          calories: null,
          power: 30,
          speed: null,
          cadence: 88,
          heartRate: 0,
          pace: 256.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 389.0,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        await initPrefServiceForTest();
        final rower = deviceMap[kayakProGenesisPortFourCC]!;
        rower.stopWorkout();

        final record = rower.stubRecord(testPair.data)!;

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
