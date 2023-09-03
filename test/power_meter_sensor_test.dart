// import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/cycling_power_meter_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [44, 0, 103, 0, 209, 181, 228, 0, 72, 85];

class CadenceTestData {
  final List<int> data;
  final String timeStamp;
  final int queueLength;
  final int cadence;

  const CadenceTestData(
      {required this.data,
      required this.timeStamp,
      required this.queueLength,
      required this.cadence});
}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Power meter interprets flags properly', () async {
    final powerMeter = CyclingPowerMeterSensor(MockBluetoothDevice());

    final canProcess = powerMeter.canMeasurementProcessed(sampleData);

    expect(canProcess, true);
    expect(powerMeter.powerMetric, isNotNull);
    expect(powerMeter.wheelRevolutionMetric, null);
    expect(powerMeter.crankRevolutionMetric, isNotNull);
    expect(powerMeter.caloriesMetric, null);
  });

  group('Power meter Device interprets data properly', () {
    for (final testPair in [
      TestPair(
        data: sampleData,
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: 103,
          speed: null,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final powerMeter = CyclingPowerMeterSensor(MockBluetoothDevice());

        final record = powerMeter.processMeasurement(testPair.data);

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
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
      });
    }
  });

  test('Stages SC3 Power meter Device interprets cadence data properly', () async {
    final powerMeter = CyclingPowerMeterSensor(MockBluetoothDevice());
    final powerMeterDescriptor = DeviceFactory.getPowerMeterBasedBike()..sensor = powerMeter;
    for (final testData in [
      const CadenceTestData(
        data: [44, 0, 139, 0, 221, 102, 6, 12, 178, 74],
        timeStamp: "08 October 2022 11:17:38.791 AM",
        queueLength: 1,
        cadence: 0,
      ),
      const CadenceTestData(
        data: [44, 0, 139, 0, 221, 102, 6, 12, 178, 74],
        timeStamp: "08 October 2022 11:17:38.798 AM",
        queueLength: 1,
        cadence: 0,
      ),
      const CadenceTestData(
        data: [44, 0, 139, 0, 221, 102, 6, 12, 178, 74],
        timeStamp: "08 October 2022 11:17:38.800 AM",
        queueLength: 1,
        cadence: 0,
      ),
      const CadenceTestData(
        data: [44, 0, 141, 0, 202, 105, 7, 12, 221, 78],
        timeStamp: "08 October 2022 11:17:39.933 AM",
        queueLength: 2,
        cadence: 57,
      ),
      const CadenceTestData(
        data: [44, 0, 141, 0, 202, 105, 7, 12, 221, 78],
        timeStamp: "08 October 2022 11:17:39.957 AM",
        queueLength: 2,
        cadence: 57,
      ),
      const CadenceTestData(
        data: [44, 0, 141, 0, 202, 105, 7, 12, 221, 78],
        timeStamp: "08 October 2022 11:17:40.309 AM",
        queueLength: 2,
        cadence: 57,
      ),
      const CadenceTestData(
        data: [44, 0, 136, 0, 126, 108, 8, 12, 219, 82],
        timeStamp: "08 October 2022 11:17:40.323 AM",
        queueLength: 3,
        cadence: 58,
      ),
      const CadenceTestData(
        data: [44, 0, 136, 0, 126, 108, 8, 12, 219, 82],
        timeStamp: "08 October 2022 11:17:41.239 AM",
        queueLength: 3,
        cadence: 58,
      ),
      const CadenceTestData(
        data: [44, 0, 136, 0, 126, 108, 8, 12, 219, 82],
        timeStamp: "08 October 2022 11:17:41.268 AM",
        queueLength: 3,
        cadence: 58,
      ),
      const CadenceTestData(
        data: [44, 0, 148, 0, 92, 111, 9, 12, 193, 86],
        timeStamp: "08 October 2022 11:17:41.273 AM",
        queueLength: 4,
        cadence: 59,
      ),
      const CadenceTestData(
        data: [44, 0, 148, 0, 92, 111, 9, 12, 193, 86],
        timeStamp: "08 October 2022 11:17:41.788 AM",
        queueLength: 4,
        cadence: 59,
      ),
      const CadenceTestData(
        data: [44, 0, 148, 0, 92, 111, 9, 12, 193, 86],
        timeStamp: "08 October 2022 11:17:42.570 AM",
        queueLength: 4,
        cadence: 59,
      ),
      const CadenceTestData(
        data: [44, 0, 150, 0, 54, 114, 10, 12, 150, 90],
        timeStamp: "08 October 2022 11:17:42.578 AM",
        queueLength: 5,
        cadence: 60,
      ),
      const CadenceTestData(
        data: [44, 0, 150, 0, 54, 114, 10, 12, 150, 90],
        timeStamp: "08 October 2022 11:17:45.372 AM",
        queueLength: 5,
        cadence: 60,
      ),
      const CadenceTestData(
        data: [44, 0, 153, 0, 13, 117, 11, 12, 82, 94],
        timeStamp: "08 October 2022 11:17:45.404 AM",
        queueLength: 5,
        cadence: 62,
      ),
      const CadenceTestData(
        data: [44, 0, 153, 0, 13, 117, 11, 12, 82, 94],
        timeStamp: "08 October 2022 11:17:45.409 AM",
        queueLength: 5,
        cadence: 62,
      ),
      const CadenceTestData(
        data: [44, 0, 153, 0, 13, 117, 11, 12, 82, 94],
        timeStamp: "08 October 2022 11:17:45.503 AM",
        queueLength: 5,
        cadence: 62,
      ),
      const CadenceTestData(
        data: [44, 0, 153, 0, 188, 122, 13, 12, 175, 101],
        timeStamp: "08 October 2022 11:17:47.234 AM",
        queueLength: 4,
        cadence: 64,
      ),
      const CadenceTestData(
        data: [44, 0, 168, 0, 198, 125, 14, 12, 82, 105],
        timeStamp: "08 October 2022 11:17:47.291 AM",
        queueLength: 4,
        cadence: 65,
      ),
      const CadenceTestData(
        data: [44, 0, 168, 0, 198, 125, 14, 12, 82, 105],
        timeStamp: "08 October 2022 11:17:47.298 AM",
        queueLength: 4,
        cadence: 65,
      ),
      const CadenceTestData(
        data: [44, 0, 209, 0, 155, 132, 16, 12, 0, 112],
        timeStamp: "08 October 2022 11:17:48.554 AM",
        queueLength: 3,
        cadence: 69,
      ),
      const CadenceTestData(
        data: [44, 0, 209, 0, 155, 132, 16, 12, 0, 112],
        timeStamp: "08 October 2022 11:17:48.930 AM",
        queueLength: 3,
        cadence: 69,
      ),
      const CadenceTestData(
        data: [44, 0, 215, 0, 218, 135, 17, 12, 8, 115],
        timeStamp: "08 October 2022 11:17:49.301 AM",
        queueLength: 4,
        cadence: 71,
      ),
      const CadenceTestData(
        data: [44, 0, 215, 0, 218, 135, 17, 12, 8, 115],
        timeStamp: "08 October 2022 11:17:49.311 AM",
        queueLength: 4,
        cadence: 71,
      ),
      const CadenceTestData(
        data: [44, 0, 215, 0, 218, 135, 17, 12, 8, 115],
        timeStamp: "08 October 2022 11:17:49.318 AM",
        queueLength: 4,
        cadence: 71,
      ),
      const CadenceTestData(
        data: [44, 0, 197, 0, 231, 138, 18, 12, 36, 118],
        timeStamp: "08 October 2022 11:17:49.322 AM",
        queueLength: 4,
        cadence: 74,
      ),
      const CadenceTestData(
        data: [44, 0, 197, 0, 231, 138, 18, 12, 36, 118],
        timeStamp: "08 October 2022 11:17:49.860 AM",
        queueLength: 4,
        cadence: 74,
      ),
      const CadenceTestData(
        data: [44, 0, 206, 0, 30, 142, 19, 12, 70, 121],
        timeStamp: "08 October 2022 11:17:50.229 AM",
        queueLength: 5,
        cadence: 75,
      ),
      const CadenceTestData(
        data: [44, 0, 206, 0, 30, 142, 19, 12, 70, 121],
        timeStamp: "08 October 2022 11:17:50.790 AM",
        queueLength: 5,
        cadence: 75,
      ),
      const CadenceTestData(
        data: [44, 0, 191, 0, 50, 145, 20, 12, 133, 124],
        timeStamp: "08 October 2022 11:17:50.802 AM",
        queueLength: 5,
        cadence: 76,
      ),
      const CadenceTestData(
        data: [44, 0, 191, 0, 50, 145, 20, 12, 133, 124],
        timeStamp: "08 October 2022 11:17:51.742 AM",
        queueLength: 5,
        cadence: 76,
      ),
      const CadenceTestData(
        data: [44, 0, 187, 0, 62, 148, 21, 12, 204, 127],
        timeStamp: "08 October 2022 11:17:52.303 AM",
        queueLength: 6,
        cadence: 75,
      ),
      const CadenceTestData(
        data: [44, 0, 187, 0, 62, 148, 21, 12, 204, 127],
        timeStamp: "08 October 2022 11:17:52.331 AM",
        queueLength: 6,
        cadence: 75,
      ),
      const CadenceTestData(
        data: [44, 0, 187, 0, 62, 148, 21, 12, 204, 127],
        timeStamp: "08 October 2022 11:17:54.179 AM",
        queueLength: 6,
        cadence: 75,
      ),
      const CadenceTestData(
        data: [44, 0, 188, 0, 76, 151, 22, 12, 16, 131],
        timeStamp: "08 October 2022 11:17:54.208 AM",
        queueLength: 5,
        cadence: 74,
      ),
      const CadenceTestData(
        data: [44, 0, 188, 0, 76, 151, 22, 12, 16, 131],
        timeStamp: "08 October 2022 11:17:54.212 AM",
        queueLength: 5,
        cadence: 74,
      ),
      const CadenceTestData(
        data: [44, 0, 189, 0, 104, 154, 23, 12, 95, 134],
        timeStamp: "08 October 2022 11:17:54.215 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 189, 0, 104, 154, 23, 12, 95, 134],
        timeStamp: "08 October 2022 11:17:54.920 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 196, 0, 150, 157, 24, 12, 160, 137],
        timeStamp: "08 October 2022 11:17:54.930 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 196, 0, 150, 157, 24, 12, 160, 137],
        timeStamp: "08 October 2022 11:17:54.935 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 175, 0, 134, 160, 25, 12, 255, 140],
        timeStamp: "08 October 2022 11:17:55.060 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 175, 0, 134, 160, 25, 12, 255, 140],
        timeStamp: "08 October 2022 11:17:55.442 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 193, 0, 184, 163, 26, 12, 84, 144],
        timeStamp: "08 October 2022 11:17:56.244 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 193, 0, 184, 163, 26, 12, 84, 144],
        timeStamp: "08 October 2022 11:17:56.269 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 193, 0, 184, 163, 26, 12, 84, 144],
        timeStamp: "08 October 2022 11:17:56.625 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 199, 166, 27, 12, 170, 147],
        timeStamp: "08 October 2022 11:17:56.996 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 199, 166, 27, 12, 170, 147],
        timeStamp: "08 October 2022 11:17:59.061 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 205, 0, 31, 170, 28, 12, 240, 150],
        timeStamp: "08 October 2022 11:17:59.092 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 205, 0, 31, 170, 28, 12, 240, 150],
        timeStamp: "08 October 2022 11:17:59.096 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 27, 173, 29, 12, 49, 154],
        timeStamp: "08 October 2022 11:17:59.098 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 181, 0, 15, 176, 30, 12, 118, 157],
        timeStamp: "08 October 2022 11:17:59.980 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 181, 0, 15, 176, 30, 12, 118, 157],
        timeStamp: "08 October 2022 11:17:59.998 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 185, 0, 19, 179, 31, 12, 190, 160],
        timeStamp: "08 October 2022 11:18:00.007 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 185, 0, 19, 179, 31, 12, 190, 160],
        timeStamp: "08 October 2022 11:18:00.366 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 185, 0, 19, 179, 31, 12, 190, 160],
        timeStamp: "08 October 2022 11:18:00.735 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 187, 0, 36, 182, 32, 12, 9, 164],
        timeStamp: "08 October 2022 11:18:01.314 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 187, 0, 36, 182, 32, 12, 9, 164],
        timeStamp: "08 October 2022 11:18:01.450 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 180, 0, 27, 185, 33, 12, 89, 167],
        timeStamp: "08 October 2022 11:18:02.437 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 180, 0, 27, 185, 33, 12, 89, 167],
        timeStamp: "08 October 2022 11:18:02.566 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 46, 188, 34, 12, 181, 170],
        timeStamp: "08 October 2022 11:18:02.762 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 46, 188, 34, 12, 181, 170],
        timeStamp: "08 October 2022 11:18:02.777 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 184, 0, 46, 188, 34, 12, 181, 170],
        timeStamp: "08 October 2022 11:18:03.750 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 198, 0, 99, 191, 35, 12, 247, 173],
        timeStamp: "08 October 2022 11:18:03.784 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 198, 0, 99, 191, 35, 12, 247, 173],
        timeStamp: "08 October 2022 11:18:03.877 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 189, 0, 120, 194, 36, 12, 63, 177],
        timeStamp: "08 October 2022 11:18:04.710 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 189, 0, 120, 194, 36, 12, 63, 177],
        timeStamp: "08 October 2022 11:18:05.055 AM",
        queueLength: 5,
        cadence: 72,
      ),
      const CadenceTestData(
        data: [44, 0, 199, 0, 174, 197, 37, 12, 123, 180],
        timeStamp: "08 October 2022 11:18:05.064 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 199, 0, 174, 197, 37, 12, 123, 180],
        timeStamp: "08 October 2022 11:18:05.192 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 199, 0, 174, 197, 37, 12, 123, 180],
        timeStamp: "08 October 2022 11:18:07.488 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 188, 0, 190, 200, 38, 12, 194, 183],
        timeStamp: "08 October 2022 11:18:07.517 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 188, 0, 190, 200, 38, 12, 194, 183],
        timeStamp: "08 October 2022 11:18:07.520 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 205, 0, 5, 204, 39, 12, 248, 186],
        timeStamp: "08 October 2022 11:18:07.812 AM",
        queueLength: 5,
        cadence: 73,
      ),
      const CadenceTestData(
        data: [44, 0, 205, 0, 5, 204, 39, 12, 248, 186],
        timeStamp: "08 October 2022 11:18:07.820 AM",
        queueLength: 5,
        cadence: 73,
      ),
    ]) {
      powerMeterDescriptor.isDataProcessable(testData.data);
      final record = powerMeterDescriptor.wrappedStubRecord(testData.data);
      // debugPrint('const CadenceTestData(data: ${testData.data}, timeStamp: "${testData.timeStamp}", queueLength: ${powerMeter.cadenceData.length}, cadence: ${powerMeter.computeCadence().toInt()},),');
      expect(powerMeter.cadenceData.length, testData.queueLength);
      expect(record!.cadence, testData.cadence);
    }
  });
}
