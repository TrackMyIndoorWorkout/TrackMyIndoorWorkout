import 'package:flutter_test/flutter_test.dart';
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

  test('KayakPro Rower Device constructor tests', () async {
    final rower = DeviceFactory.getKayaPro();

    expect(rower.sport, ActivityType.kayaking);
    expect(rower.fourCC, kayakProGenesisPortFourCC);
    expect(rower.isMultiSport, true);
  });

  test('Rower Device interprets KayakPro flags properly', () async {
    final rower = DeviceFactory.getKayaPro();
    const lsb = 44;
    const msb = 9;
    // C1 stroke rate uint8 (spm) 0.5
    // C1 stroke count uint16
    // C3 distance uint24 (m) 1
    // C4 pace uint16 seconds 1
    // C6 power sint16 (watts) 1
    // -
    // C9 total energy uint16 (kcal) 1
    // C9 energy/h uint16 1
    // C9 energy/min uint8 1
    // C12 elapsed time uint16 (s) 1
    // total length (1 + 2 + 3 + 2 + 2) + (2 + 2 + 1 + 2) = 10 + 7 = 17
    const flag = maxUint8 * msb + lsb;
    rower.initFlag();
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
          strokeCount: 0.0,
          heartRate: null,
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
          strokeCount: 33.0,
          heartRate: null,
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
          strokeCount: 65.0,
          heartRate: null,
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
          strokeCount: 150.0,
          heartRate: null,
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
          strokeCount: 184.0,
          heartRate: null,
          pace: 256.0,
          sport: ActivityType.kayaking,
          caloriesPerHour: 389.0,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final rower = DeviceFactory.getKayaPro();
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
