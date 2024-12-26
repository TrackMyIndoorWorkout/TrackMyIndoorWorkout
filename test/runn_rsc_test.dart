import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/npe_runn_treadmill.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/running_speed_and_cadence_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [0, 145, 1, 187];

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Runn RSC constructor tests', () async {
    final treadmill = NpeRunnTreadmill();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.fourCC, npeRunnFourCC);
    expect(treadmill.isMultiSport, false);
  });

  test('Runn RSC Device interprets flags properly', () async {
    final runnRsc = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

    final canProcess = runnRsc.canMeasurementProcessed(sampleData);

    expect(canProcess, true);
    expect(runnRsc.speedMetric, isNotNull);
    expect(runnRsc.cadenceMetric, isNotNull);
    expect(runnRsc.distanceMetric, null);
  });

  group('Runn RSC Device interprets RSC data properly', () {
    for (final testPair in [
      TestPair(
        data: sampleData,
        record: RecordWithSport(
          distance: null,
          elapsed: null,
          calories: null,
          power: null,
          speed: (sampleData[2] * 256 + sampleData[1]) / 256.0 * DeviceDescriptor.ms2kmh,
          cadence: sampleData[3],
          heartRate: null,
          pace: null,
          sport: ActivityType.run,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: null,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final runnRsc = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

        final record = runnRsc.processMeasurement(testPair.data);

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
}
