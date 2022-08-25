import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/mr_captain_descriptor.dart';
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

  test('Mr Captain Rower Device constructor tests', () async {
    final rower = MrCaptainDescriptor();

    expect(rower.defaultSport, ActivityType.rowing);
    expect(rower.fourCC, mrCaptainRowerFourCC);
    expect(rower.isMultiSport, false);
  });

  test('Rower Device interprets Mr Captain flags properly', () async {
    final rower = MrCaptainDescriptor();
    const lsb = 60;
    const msb = 11;
    // C1 stroke rate uint8 (spm) 0.5
    // C1 stroke count uint16
    // C3 distance uint24 (m) 1
    // C4 pace uint16 seconds 1
    // C5 avg pace? uint16
    // C6 power sint16 (watts) 1
    // -
    // C9 total energy uint16 (kcal) 1
    // C9 energy/h uint16 1
    // C9 energy/min uint8 1
    // C10 HR uint8 (bpm) 1
    // C12 elapsed time uint16 (s) 1
    // total length (1 + 2 + 3 + 2 + 2 + 2) + (2 + 2 + 1 + 1 + 2) = 12 + 8 = 20
    const flag = maxUint8 * msb + lsb;
    rower.stopWorkout();

    rower.processFlag(flag);

    expect(rower.strokeRateMetric, isNotNull);
    expect(rower.strokeCountMetric, isNotNull);
    expect(rower.paceMetric, isNotNull);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric, isNotNull);
    expect(rower.powerMetric, isNotNull);
    expect(rower.caloriesMetric, isNotNull);
    expect(rower.timeMetric, null);
    expect(rower.caloriesPerHourMetric, isNotNull);
    expect(rower.caloriesPerMinuteMetric, isNotNull); // It's there but mute
    expect(rower.heartRateByteIndex, 19);
  });

  group('Rower Device interprets Mr Captain data properly', () {
    for (final testPair in [
      TestPair(
        data: [60, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: null,
          calories: 0,
          power: 0,
          speed: null,
          cadence: 0,
          heartRate: 0,
          pace: 0.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 0.0,
          caloriesPerMinute: 0.0,
        ),
      ),
      TestPair(
        data: [60, 11, 2, 1, 0, 0, 0, 0, 112, 23, 5, 0, 18, 0, 0, 0, 0, 0, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: null,
          calories: 0,
          power: 5,
          speed: null,
          cadence: 1,
          heartRate: 0,
          pace: 6000.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 0.0,
          caloriesPerMinute: 18.0,
        ),
      ),
      TestPair(
        data: [60, 11, 48, 2, 0, 10, 0, 0, 209, 0, 94, 1, 22, 0, 1, 0, 2, 2, 8, 0],
        record: RecordWithSport(
          distance: 10.0,
          elapsed: null,
          calories: 1,
          power: 350,
          speed: null,
          cadence: 24,
          heartRate: 0,
          pace: 209.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 514.0,
          caloriesPerMinute: 22.0,
        ),
      ),
      TestPair(
        data: [60, 11, 34, 3, 0, 10, 0, 0, 39, 1, 88, 2, 15, 0, 1, 0, 44, 1, 5, 0],
        record: RecordWithSport(
          distance: 10.0,
          elapsed: null,
          calories: 1,
          power: 600,
          speed: null,
          cadence: 17,
          heartRate: 0,
          pace: 295.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 300.0,
          caloriesPerMinute: 15.0,
        ),
      ),
      TestPair(
        data: [60, 11, 44, 4, 0, 20, 0, 0, 227, 0, 119, 1, 20, 0, 2, 0, 224, 1, 8, 0],
        record: RecordWithSport(
          distance: 20.0,
          elapsed: null,
          calories: 2,
          power: 375,
          speed: null,
          cadence: 22,
          heartRate: 0,
          pace: 227.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 480.0,
          caloriesPerMinute: 20.0,
        ),
      ),
      TestPair(
        data: [60, 11, 36, 5, 0, 30, 0, 0, 25, 1, 94, 1, 16, 0, 2, 0, 86, 1, 5, 0],
        record: RecordWithSport(
          distance: 30.0,
          elapsed: null,
          calories: 2,
          power: 350,
          speed: null,
          cadence: 18,
          heartRate: 0,
          pace: 281.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 342.0,
          caloriesPerMinute: 16.0,
        ),
      ),
      TestPair(
        data: [60, 11, 132, 0, 0, 30, 0, 0, 0, 0, 110, 1, 0, 0, 2, 0, 71, 1, 5, 0],
        record: RecordWithSport(
          distance: 30.0,
          elapsed: null,
          calories: 2,
          power: 366,
          speed: null,
          cadence: 66,
          heartRate: 0,
          pace: 0.0,
          sport: ActivityType.rowing,
          caloriesPerHour: 327.0,
          caloriesPerMinute: 0.0,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final rower = MrCaptainDescriptor();
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
