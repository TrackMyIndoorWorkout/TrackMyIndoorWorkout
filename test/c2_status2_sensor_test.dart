import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/c2_additional_status2.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [
  [245, 46, 0, 0, 19, 0, 12, 0, 132, 103, 19, 0, 12, 0, 0, 0, 0, 179, 0, 0],
  [90, 47, 0, 0, 19, 0, 12, 0, 132, 103, 19, 0, 12, 0, 0, 0, 0, 179, 0, 0],
];

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('C2 Status 2 Sensor accepts proper data', () {
    for (final testData in sampleData) {
      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status2 = C2AdditionalStatus2(MockBluetoothDevice());

        final canProcess = status2.canMeasurementProcessed(testData);

        expect(canProcess, true);
        expect(status2.expectedLength, testData.length);
        expect(status2.caloriesMetric, isNotNull);
      });
    }
  });

  group('C2 Status 1 Sensor rejects improper data', () {
    for (final testData in sampleData) {
      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status2 = C2AdditionalStatus2(MockBluetoothDevice());

        final canProcess =
            status2.canMeasurementProcessed(testData.sublist(0, testData.length - 2));

        expect(canProcess, false);
      });
    }
  });

  group('C2 Status 1 Sensor interprets data properly', () {
    for (final testData in sampleData) {
      final calories = testData[C2AdditionalStatus2.caloriesLsbByteIndex] +
          256 * testData[C2AdditionalStatus2.caloriesLsbByteIndex + 1];
      final expectedRecord = RecordWithSport(
        distance: null,
        elapsed: null,
        calories: calories,
        power: null,
        speed: null,
        cadence: null,
        heartRate: null,
        pace: null,
        sport: ActivityType.rowing,
        caloriesPerHour: null,
        caloriesPerMinute: null,
        strokeCount: null,
      );

      final sum = testData.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final status2 = C2AdditionalStatus2(MockBluetoothDevice());

        final record = status2.processMeasurement(testData);

        expect(record.id, Isar.autoIncrement);
        expect(record.id, expectedRecord.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, expectedRecord.activityId);
        expect(record.distance, expectedRecord.distance);
        expect(record.elapsed, expectedRecord.elapsed);
        expect(record.calories, expectedRecord.calories);
        expect(record.power, expectedRecord.power);
        expect(record.speed, null);
        expect(record.cadence, expectedRecord.cadence);
        expect(record.heartRate, expectedRecord.heartRate);
        expect(record.elapsedMillis, expectedRecord.elapsedMillis);
        expect(record.pace, null);
        expect(record.sport, expectedRecord.sport);
        expect(record.caloriesPerHour, expectedRecord.caloriesPerHour);
        expect(record.caloriesPerMinute, expectedRecord.caloriesPerMinute);
        expect(record.strokeCount, expectedRecord.strokeCount);
      });
    }
  });
}
