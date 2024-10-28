import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
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

  test('Old Concept2 FTMS Rower constructor tests', () async {
    final rower = DeviceFactory.getGenericFTMSRower();

    expect(rower.sport, ActivityType.rowing);
    expect(rower.fourCC, genericFTMSRowerFourCC);
    expect(rower.isMultiSport, false);
  });

  test('Old Concept2 FTMS Rower flags 1 properly', () async {
    final rower = DeviceFactory.getGenericFTMSRower();
    const lsb = 255;
    const msb = 10;
    // C2 average stroke uint8 0.5 (igonred)
    // C3 distance uint24 (m) 1
    // C4 pace uint16 seconds 1
    // C5 avg pace? uint16 (ignored)
    // C6 power sint16 (watts) 1
    // C7 avg power sint16 (watts) 1 (ignored)
    // C8 Resistance Level sint16 1
    // C10 HR uint8 (bpm) 1
    // C12 elapsed time uint16 (s) 1
    // total length 1 + 3 + 2 + 2 + 2 + 2 + 2 + 1 + 2 = 17
    const flag = maxUint8 * msb + lsb;
    rower.initFlag();
    rower.stopWorkout();
    rower.processFlag(flag, 20); // It's 20 bytes long instead of 19

    expect(rower.strokeRateMetric, null);
    expect(rower.paceMetric, isNotNull);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, isNotNull);
    expect(rower.powerMetric, isNotNull);
    expect(rower.caloriesMetric, null);
    expect(rower.timeMetric, isNotNull);
    expect(rower.caloriesPerHourMetric, null);
    expect(rower.caloriesPerMinuteMetric, null);
    expect(rower.strokeCountMetric, null);
    expect(rower.heartRateByteIndex, isNotNull);
  });

  test('Old Concept2 FTMS Rower flags 2 properly', () async {
    final rower = DeviceFactory.getGenericFTMSRower();
    const lsb = 0;
    const msb = 1;
    // C1 stroke rate uint8 (spm) 0.5
    // C1 stroke count uint16
    // C9 total energy uint16 (kcal) 1
    // C9 energy/h uint16 1
    // C9 energy/min uint8 1
    // total length (1 + 2) + 1* + 2 + (2 + 2 + 1) = 11
    const flag = maxUint8 * msb + lsb;
    rower.initFlag();
    rower.stopWorkout();
    rower.processFlag(flag, 10);

    expect(rower.strokeRateMetric, isNotNull);
    expect(rower.paceMetric, null);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, null);
    expect(rower.powerMetric, null);
    expect(rower.caloriesMetric, isNotNull);
    expect(rower.timeMetric, null);
    expect(rower.caloriesPerHourMetric, isNotNull);
    expect(rower.caloriesPerMinuteMetric, isNotNull);
    expect(rower.strokeCountMetric, isNotNull);
    expect(rower.heartRateByteIndex, null);
  });

  group('Rower Device interprets Old Concept2 FTMS Rower data properly', () {
    for (final testPair in [
      TestPair(
        data: [maxByte, 10, 52, 203, 0, 0, 192, 0, 207, 0, 50, 0, 39, 0, 140, 0, 0, 84, 0, 0],
        record: RecordWithSport(
          distance: 203.0,
          elapsed: 84,
          calories: null,
          power: 50,
          speed: null,
          cadence: null,
          heartRate: 0,
          pace: 192.0,
          sport: ActivityType.rowing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          resistance: 140,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [0, 1, 62, 36, 0, 9, 0, 215, 1, maxByte],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: 9,
          power: null,
          speed: null,
          cadence: 31,
          heartRate: null,
          pace: null,
          sport: ActivityType.rowing,
          caloriesPerHour: 471.0,
          caloriesPerMinute: null,
          resistance: null,
          strokeCount: 36.0,
        ),
      ),
      TestPair(
        data: [maxByte, 10, 48, 82, 1, 0, 173, 0, 193, 0, 67, 0, 48, 0, 118, 0, 0, 131, 0, 0],
        record: RecordWithSport(
          distance: 338.0,
          elapsed: 131,
          calories: null,
          power: 67,
          speed: null,
          cadence: null,
          heartRate: 0,
          pace: 173.0,
          sport: ActivityType.rowing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          resistance: 118,
          strokeCount: null,
        ),
      ),
      TestPair(
        data: [0, 1, 50, 52, 0, 16, 0, 20, 2, maxByte],
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: 16,
          power: null,
          speed: null,
          cadence: 25,
          heartRate: null,
          pace: null,
          sport: ActivityType.rowing,
          caloriesPerHour: 532.0,
          caloriesPerMinute: null,
          resistance: null,
          strokeCount: 52.0,
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
