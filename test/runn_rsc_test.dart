import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/running_cadence_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'runn_rsc_test.mocks.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [0, 145, 1, 187];

@GenerateMocks([BluetoothDevice])
void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Runn RSC constructor tests', () async {
    final treadmill = DeviceFactory.getNpeRunn();

    expect(treadmill.canMeasureHeartRate, false);
    expect(treadmill.defaultSport, ActivityType.run);
    expect(treadmill.fourCC, npeRunnFourCC);
  });

  test('Runn RSC Device interprets flags properly', () async {
    final runnRsc = RunningCadenceSensor(MockBluetoothDevice(), 1.0);

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
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final runnRsc = RunningCadenceSensor(MockBluetoothDevice(), 1.0);

        final record = runnRsc.processMeasurement(testPair.data);

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
