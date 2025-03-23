import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/c2_additional_status1.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [
  [139, 47, 0, 164, 8, 40, 255, 123, 88, 132, 103, 0, 0, 0, 0, 0, 0],
  [39, 47, 0, 164, 8, 40, 255, 123, 88, 132, 103, 0, 0, 0, 0, 0, 0],
];

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('C2 Status 1 Sensor accepts proper data', () {
    for (final testData in sampleData) {
      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status1 = C2AdditionalStatus1(MockBluetoothDevice());

        final canProcess = status1.canMeasurementProcessed(testData);

        expect(canProcess, true);
        expect(status1.expectedLength, testData.length);
        expect(status1.speedMetric, isNotNull);
        expect(status1.paceMetric, isNotNull);
      });
    }
  });

  group('C2 Status 1 Sensor rejects improper data', () {
    for (final testData in sampleData) {
      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status1 = C2AdditionalStatus1(MockBluetoothDevice());

        final canProcess = status1.canMeasurementProcessed(
          testData.sublist(0, testData.length - 2),
        );

        expect(canProcess, false);
      });
    }
  });

  group('C2 Status 1 Sensor interprets data properly', () {
    for (final testData in sampleData) {
      final speed =
          (testData[C2AdditionalStatus1.speedLsbByteIndex] +
              256 * testData[C2AdditionalStatus1.speedLsbByteIndex + 1]) /
          1000.0 *
          DeviceDescriptor.ms2kmh;
      final hr = testData[C2AdditionalStatus1.heartRateByteIndex];
      final pace =
          (testData[C2AdditionalStatus1.paceLsbByteIndex] +
              256 * testData[C2AdditionalStatus1.paceLsbByteIndex + 1]) /
          100.0;
      final expectedRecord = RecordWithSport(
        distance: null,
        elapsed: null,
        calories: null,
        power: null,
        speed: speed,
        cadence: testData[C2AdditionalStatus1.strokeRateByteIndex],
        heartRate: hr < 255 && hr > 0 ? hr : null,
        pace: pace,
        sport: ActivityType.rowing,
        caloriesPerHour: null,
        caloriesPerMinute: null,
        strokeCount: null,
      );

      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status1 = C2AdditionalStatus1(MockBluetoothDevice());

        final record = status1.processMeasurement(testData);

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
        if (expectedRecord.pace != null) {
          expect(record.pace, closeTo(expectedRecord.pace!, eps));
        } else {
          expect(record.pace, null);
        }
        expect(record.sport, expectedRecord.sport);
        expect(record.caloriesPerHour, expectedRecord.caloriesPerHour);
        expect(record.caloriesPerMinute, expectedRecord.caloriesPerMinute);
        expect(record.strokeCount, expectedRecord.strokeCount);
      });
    }
  });
}
