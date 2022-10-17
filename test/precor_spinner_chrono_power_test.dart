import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/precor_spinner_chrono_power.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Precor Spinner Chrono Power constructor tests', () async {
    final bike = PrecorSpinnerChronoPower();

    expect(bike.defaultSport, ActivityType.ride);
    expect(bike.fourCC, precorSpinnerChronoPowerFourCC);
  });

  test('Precor Spinner Chrono Power interprets Data flags properly', () async {
    final bike = PrecorSpinnerChronoPower();
    final data = [83, 89, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    expect(bike.isDataProcessable(data), true);
    expect(bike.speedMetric, isNotNull);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, isNotNull);
    expect(bike.powerMetric, isNotNull);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
  });

  group('Precor Spinner Chrono Power interprets Data properly', () {
    for (final testPair in [
      TestPair(
        data: [83, 89, 22, 110, 2, 0, 200, 8, 84, 1, 80, 14, 0, 57, 0, 47, 0, 90, 0],
        record: RecordWithSport(
          distance: 3664.0,
          elapsed: 622,
          calories: 57,
          power: 90,
          speed: 22.48,
          cadence: 34,
          heartRate: 0,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 248, 4, 77, 235, 8, 94, 1, 220, 29, 0, 124, 0, 103, 0, 94, 0],
        record: RecordWithSport(
          distance: 7644.0,
          elapsed: 1272,
          calories: 124,
          power: 94,
          speed: 22.83,
          cadence: 35,
          heartRate: 77,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 4, 5, 67, 0, 0, 0, 0, 24, 30, 0, 125, 0, 104, 0, 0, 0],
        record: RecordWithSport(
          distance: 7704.0,
          elapsed: 1284,
          calories: 125,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: 67,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 57, 5, 0, 0, 0, 0, 0, 59, 31, 0, 129, 0, 108, 0, 0, 0],
        record: RecordWithSport(
          distance: 7995.0,
          elapsed: 1337,
          calories: 129,
          power: 0,
          speed: 0.0,
          cadence: 0,
          heartRate: 0,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 247, 0, 79, 0, 14, 128, 2, 71, 6, 0, 31, 0, 26, 0, 24, 1],
        record: RecordWithSport(
          distance: 1607.0,
          elapsed: 247,
          calories: 31,
          power: 280,
          speed: 35.84,
          cadence: 64,
          heartRate: 79,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 8, 1, 103, 222, 13, 118, 2, 235, 6, 0, 36, 0, 30, 0, 18, 1],
        record: RecordWithSport(
          distance: 1771.0,
          elapsed: 264,
          calories: 36,
          power: 274,
          speed: 35.5,
          cadence: 63,
          heartRate: 103,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 225, 6, 88, 156, 9, 164, 1, 207, 47, 0, 1, 1, 214, 0, 115, 0],
        record: RecordWithSport(
          distance: 12239.0,
          elapsed: 1761,
          calories: 257,
          power: 115,
          speed: 24.6,
          cadence: 42,
          heartRate: 88,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 15, 7, 81, 98, 9, 144, 1, 0, 49, 0, 6, 1, 219, 0, 108, 0],
        record: RecordWithSport(
          distance: 12544.0,
          elapsed: 1807,
          calories: 262,
          power: 108,
          speed: 24.02,
          cadence: 40,
          heartRate: 81,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 132, 8, 68, 134, 11, 152, 3, 93, 58, 0, 51, 1, 0, 1, 179, 0],
        record: RecordWithSport(
          distance: 14941.0,
          elapsed: 2180,
          calories: 307,
          power: 179,
          speed: 29.5,
          cadence: 92,
          heartRate: 68,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
      TestPair(
        data: [83, 89, 22, 193, 8, 83, 245, 11, 252, 3, 35, 60, 0, 60, 1, 7, 1, 195, 0],
        record: RecordWithSport(
          distance: 15395.0,
          elapsed: 2241,
          calories: 316,
          power: 195,
          speed: 30.61,
          cadence: 102,
          heartRate: 83,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final bike = PrecorSpinnerChronoPower();
        expect(bike.isDataProcessable(testPair.data), true);

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
