import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/running_speed_and_cadence_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

// This Technogym Run RSC also has stride length between the cadence and the distance,
// but we discard that
const sampleData = [
  [3, 92, 3, 161, 130, 0, 246, 9, 0, 0],
  [3, 185, 1, 133, 94, 0, 13, 12, 0, 0]
];

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Technogym Run constructor tests', () async {
    final treadmill = DeviceFactory.getTechnogymRun();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.fourCC, technogymRunFourCC);
    expect(treadmill.isMultiSport, false);
  });

  test('Technogym Run RSC Device interprets flags properly', () async {
    final treadmill = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

    final canProcess = treadmill.canMeasurementProcessed(sampleData[0]);

    expect(canProcess, true);
    expect(treadmill.speedMetric, isNotNull);
    expect(treadmill.cadenceMetric, isNotNull);
    expect(treadmill.distanceMetric, isNotNull);
  });

  group('Technogym Run RSC Device interprets RSC data properly', () {
    for (final sample in sampleData) {
      final expected = RecordWithSport(
        distance: (((sample[9] * 256 + sample[8]) * 256 + sample[7]) * 256 + sample[6]) / 10.0,
        elapsed: null,
        calories: null,
        power: null,
        speed: (sample[2] * 256 + sample[1]) / 256.0 * DeviceDescriptor.ms2kmh,
        cadence: sample[3],
        heartRate: null,
        pace: null,
        sport: ActivityType.run,
        caloriesPerHour: null,
        caloriesPerMinute: null,
        strokeCount: null,
      );

      final sum = sample.fold<int>(0, (a, b) => a + b);
      test("$sum", () async {
        final treadmill = RunningSpeedAndCadenceSensor(MockBluetoothDevice());

        final record = treadmill.processMeasurement(sample);

        expect(record.id, Isar.autoIncrement);
        expect(record.id, expected.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, expected.activityId);
        expect(record.distance, expected.distance);
        expect(record.elapsed, expected.elapsed);
        expect(record.calories, expected.calories);
        expect(record.power, expected.power);
        if (record.speed != null) {
          expect(record.speed, closeTo(expected.speed!, eps));
        } else {
          expect(record.speed, null);
        }
        expect(record.cadence, expected.cadence);
        expect(record.heartRate, expected.heartRate);
        expect(record.elapsedMillis, expected.elapsedMillis);
        expect(record.pace, expected.pace);
        expect(record.sport, expected.sport);
        expect(record.caloriesPerHour, expected.caloriesPerHour);
        expect(record.caloriesPerMinute, expected.caloriesPerMinute);
        expect(record.strokeCount, expected.strokeCount);
      });
    }
  });
}
