import 'package:flutter_test/flutter_test.dart';
import 'package:preferences/preference_service.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/rower_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/persistence/preferences.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  TestPair({this.data, this.record});
}

void main() {
  test('KayakPro Rower Device constructor tests', () async {
    final rower = deviceMap["KPro"];

    expect(rower.canMeasureHeartRate, false);
    expect(rower.defaultSport, ActivityType.Kayaking);
    expect(rower.fourCC, "KPro");
  });

  test('Rower Device interprets KayakPro flags properly', () async {
    final rower = deviceMap["KPro"] as RowerDeviceDescriptor;
    final lsb = 44;
    final msb = 9;
    final flag = 256 * msb + lsb;
    await PrefService.init(prefix: 'pref_');
    PrefService.setDefaultValues({STROKE_RATE_SMOOTHING_TAG: STROKE_RATE_SMOOTHING_DEFAULT});
    rower.stopWorkout();

    rower.processFlag(flag);

    expect(rower.strokeRateMetric != null, true);
    expect(rower.strokeCountMetric != null, true);
    expect(rower.paceMetric != null, true);
    expect(rower.speedMetric, null);
    expect(rower.cadenceMetric, null);
    expect(rower.distanceMetric != null, true);
    expect(rower.powerMetric != null, true);
    expect(rower.caloriesMetric != null, true); // It's there but mute
    expect(rower.timeMetric != null, true);
    expect(rower.caloriesPerHourMetric != null, true);
    expect(rower.caloriesPerMinuteMetric != null, true); // It's there but mute
  });

  group('Rower Device interprets KayakPro data properly', () {
    [
      TestPair(
        data: [44, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0, 0, 255, 0, 0],
        record: RecordWithSport(
          distance: 0.0,
          elapsed: 0,
          calories: null,
          power: 0,
          speed: null,
          cadence: 0,
          heartRate: 0,
          pace: 0.0,
          sport: ActivityType.Kayaking,
          caloriesPerHour: 0.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 79, 33, 0, 50, 0, 0, 86, 1, 12, 0, 255, 255, 89, 1, 255, 62, 0],
        record: RecordWithSport(
          distance: 50.0,
          elapsed: 62,
          calories: null,
          power: 12,
          speed: null,
          cadence: 39,
          heartRate: 0,
          pace: 342.0,
          sport: ActivityType.Kayaking,
          caloriesPerHour: 345.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 152, 65, 0, 105, 0, 0, 60, 1, 16, 0, 255, 255, 97, 1, 255, 106, 0],
        record: RecordWithSport(
          distance: 105.0,
          elapsed: 106,
          calories: null,
          power: 16,
          speed: null,
          cadence: 76,
          heartRate: 0,
          pace: 316.0,
          sport: ActivityType.Kayaking,
          caloriesPerHour: 353.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 85, 150, 0, 246, 0, 0, 39, 1, 20, 0, 255, 255, 107, 1, 255, 45, 1],
        record: RecordWithSport(
          distance: 246.0,
          elapsed: 301,
          calories: null,
          power: 20,
          speed: null,
          cadence: 42,
          heartRate: 0,
          pace: 295.0,
          sport: ActivityType.Kayaking,
          caloriesPerHour: 363.0,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [44, 9, 177, 184, 0, 48, 1, 0, 0, 1, 30, 0, 255, 255, 133, 1, 255, 91, 1],
        record: RecordWithSport(
          distance: 304.0,
          elapsed: 347,
          calories: null,
          power: 30,
          speed: null,
          cadence: 88,
          heartRate: 0,
          pace: 256.0,
          sport: ActivityType.Kayaking,
          caloriesPerHour: 389.0,
          caloriesPerMinute: null,
        ),
      ),
    ].forEach((testPair) {
      final sum = testPair.data.fold(0.0, (a, b) => a + b);
      test("$sum", () async {
        PrefService.init(prefix: 'pref_');
        PrefService.setDefaultValues({STROKE_RATE_SMOOTHING_TAG: STROKE_RATE_SMOOTHING_DEFAULT});
        final rower = deviceMap["KPro"];
        rower.stopWorkout();

        final record = rower.stubRecord(testPair.data);

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
    });
  });
}
