import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/running_speed_and_cadence_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'technogym_myrun_rsc_test.mocks.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

const sampleData = [2, 185, 0, 51, 138, 2, 0, 0];

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Technogym MyRun RSC constructor tests', () async {
    final treadmill = DeviceFactory.getGenericFTMSTreadmill();

    expect(treadmill.defaultSport, ActivityType.run);
    expect(treadmill.fourCC, genericFTMSTreadmillFourCC);
    expect(treadmill.isMultiSport, false);
  });

  test('Technogym MyRun RSC Device interprets flags properly', () async {
    final treadmill = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

    final canProcess = treadmill.canMeasurementProcessed(sampleData);

    expect(canProcess, true);
    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, isNotNull);
    expect(treadmill.distanceMetric, isNotNull);
  });

  group('Technogym MyRun RSC Device interprets RSC data properly', () {
    for (final testPair in [
      TestPair(
        data: sampleData,
        record: RecordWithSport(
          distance: (((sampleData[7] * 256 + sampleData[6]) * 256 + sampleData[5]) * 256 +
                  sampleData[4]) /
              10.0,
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
        final treadmill = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

        final record = treadmill.processMeasurement(testPair.data);

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
