import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'heart_rate_monitor_sensor_test.mocks.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [4, 84];

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('HRM interprets flags properly', () async {
    final hrm = HeartRateMonitor(MockBluetoothDevice());

    final canProcess = hrm.canMeasurementProcessed(sampleData);

    expect(canProcess, true);
    expect(hrm.heartRateMetric, isNotNull);
    expect(hrm.caloriesMetric, null);
  });

  group('HRM Device interprets HR data properly', () {
    for (final testPair in [
      TestPair(
        data: sampleData,
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: null,
          speed: null,
          cadence: null,
          heartRate: sampleData[1],
          pace: null,
          sport: ActivityType.workout,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final record = hrm.processMeasurement(testPair.data);

        expect(record.id, null);
        expect(record.id, testPair.record.id);
        expect(record.activityId, null);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.calories, testPair.record.calories);
        expect(record.power, testPair.record.power);
        if (testPair.record.speed != null) {
          expect(record.speed, closeTo(testPair.record.speed!, eps));
        } else {
          expect(record.speed, null);
        }
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
