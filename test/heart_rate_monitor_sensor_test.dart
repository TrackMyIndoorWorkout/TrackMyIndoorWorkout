import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const byteHrmSampleData = [4, 84];
const moreHrmSampleData = [
  [22, 89, 162, 2],
  [22, 90, 154, 2],
  [22, 92, 140, 2],
  [22, 93, 133, 2],
];
const polarH7SampleData = [
  [22, 115, 16, 2, 13, 2],
  [22, 115, 15, 2, 17, 2],
  [22, 116, 20, 2, 22, 2],
  [22, 116, 41, 2],
];

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Byte HRM interprets flags properly', () async {
    final hrm = HeartRateMonitor(MockBluetoothDevice());

    final canProcess = hrm.canMeasurementProcessed(byteHrmSampleData);

    expect(canProcess, true);
    expect(hrm.expectedLength, byteHrmSampleData.length);
    expect(hrm.heartRateMetric, isNotNull);
    expect(hrm.caloriesMetric, null);
  });

  group('Byte HRM Device interprets HR data properly', () {
    for (final testPair in [
      TestPair(
        data: byteHrmSampleData,
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: null,
          speed: null,
          cadence: null,
          heartRate: byteHrmSampleData[1],
          pace: null,
          sport: ActivityType.workout,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final record = hrm.processMeasurement(testPair.data);

        expect(record.id, Isar.autoIncrement);
        expect(record.id, testPair.record.id);
        expect(record.activityId, Isar.minId);
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
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
        expect(record.strokeCount, testPair.record.strokeCount);
      });
    }
  });

  group('More HRM Device interprets flags properly', () {
    for (final moreTestData in moreHrmSampleData) {
      final sum = moreTestData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final canProcess = hrm.canMeasurementProcessed(moreTestData);

        expect(canProcess, true);
        expect(hrm.expectedLength, moreTestData.length);
        expect(hrm.heartRateMetric, isNotNull);
        expect(hrm.caloriesMetric, null);
      });
    }
  });

  group('More HRM Device interprets HR data properly', () {
    for (final moreTestData in moreHrmSampleData) {
      final expectedRecord = RecordWithSport(
        distance: null,
        elapsed: null,
        calories: null,
        power: null,
        speed: null,
        cadence: null,
        heartRate: moreTestData[1],
        pace: null,
        sport: ActivityType.workout,
        caloriesPerHour: null,
        caloriesPerMinute: null,
        strokeCount: null,
      );

      final sum = moreTestData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final record = hrm.processMeasurement(moreTestData);

        expect(record.id, Isar.autoIncrement);
        expect(record.id, expectedRecord.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, expectedRecord.activityId);
        expect(record.distance, expectedRecord.distance);
        expect(record.elapsed, expectedRecord.elapsed);
        expect(record.calories, expectedRecord.calories);
        expect(record.power, expectedRecord.power);
        if (expectedRecord.speed != null) {
          expect(record.speed, closeTo(expectedRecord.speed!, eps));
        } else {
          expect(record.speed, null);
        }
        expect(record.cadence, expectedRecord.cadence);
        expect(record.heartRate, expectedRecord.heartRate);
        expect(record.elapsedMillis, expectedRecord.elapsedMillis);
        expect(record.pace, expectedRecord.pace);
        expect(record.sport, expectedRecord.sport);
        expect(record.caloriesPerHour, expectedRecord.caloriesPerHour);
        expect(record.caloriesPerMinute, expectedRecord.caloriesPerMinute);
        expect(record.strokeCount, expectedRecord.strokeCount);
      });
    }
  });

  group('HRM interprets Polar H7 flags + data length properly', () {
    for (final polarH7TestData in polarH7SampleData) {
      final sum = polarH7TestData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final canProcess = hrm.canMeasurementProcessed(polarH7TestData);

        expect(canProcess, true);
        if (hrm.hasRRIntervals) {
          expect(hrm.expectedLength <= polarH7TestData.length, true);
          expect((polarH7TestData.length - hrm.expectedLength) % 2, 0);
        } else {
          expect(hrm.expectedLength, polarH7TestData.length);
        }
        expect(hrm.heartRateMetric, isNotNull);
        expect(hrm.caloriesMetric, null);
      });
    }
  });

  group('More HRM Device interprets HR data properly', () {
    for (final polarH7TestData in polarH7SampleData) {
      final expectedRecord = RecordWithSport(
        distance: null,
        elapsed: null,
        calories: null,
        power: null,
        speed: null,
        cadence: null,
        heartRate: polarH7TestData[1],
        pace: null,
        sport: ActivityType.workout,
        caloriesPerHour: null,
        caloriesPerMinute: null,
      );

      final sum = polarH7TestData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final hrm = HeartRateMonitor(MockBluetoothDevice());

        final record = hrm.processMeasurement(polarH7TestData);

        expect(record.id, Isar.autoIncrement);
        expect(record.id, expectedRecord.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, expectedRecord.activityId);
        expect(record.distance, expectedRecord.distance);
        expect(record.elapsed, expectedRecord.elapsed);
        expect(record.calories, expectedRecord.calories);
        expect(record.power, expectedRecord.power);
        if (expectedRecord.speed != null) {
          expect(record.speed, closeTo(expectedRecord.speed!, eps));
        } else {
          expect(record.speed, null);
        }
        expect(record.cadence, expectedRecord.cadence);
        expect(record.heartRate, expectedRecord.heartRate);
        expect(record.elapsedMillis, expectedRecord.elapsedMillis);
        expect(record.pace, expectedRecord.pace);
        expect(record.sport, expectedRecord.sport);
        expect(record.caloriesPerHour, expectedRecord.caloriesPerHour);
        expect(record.caloriesPerMinute, expectedRecord.caloriesPerMinute);
        expect(record.strokeCount, expectedRecord.strokeCount);
      });
    }
  });
}
