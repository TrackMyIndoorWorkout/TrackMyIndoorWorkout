import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/isar/activity.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'utils.dart';
import 'fitness_equipment_start_stop_workout_test.mocks.dart';

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('startWorkout blanks out leftover lastRecord', () async {
    final rnd = Random();
    await initPrefServiceForTest();
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
    equipment.lastRecord = RecordWithSport.getRandom(descriptor.sport, rnd);

    equipment.startWorkout();

    expect(equipment.lastRecord.distance, closeTo(0.0, eps));
    expect(equipment.lastRecord.elapsed, 0);
    expect(equipment.lastRecord.calories, 0);
    expect(equipment.lastRecord.power, 0);
    expect(equipment.lastRecord.speed, closeTo(0.0, eps));
    expect(equipment.lastRecord.cadence, 0);
    expect(equipment.lastRecord.heartRate, 0);
    expect(equipment.lastRecord.elapsedMillis, 0);
    expect(equipment.lastRecord.sport, descriptor.sport);
    expect(equipment.lastRecord.pace, null);
    expect(equipment.lastRecord.strokeCount, null);
    expect(equipment.lastRecord.caloriesPerHour, null);
    expect(equipment.lastRecord.caloriesPerMinute, null);

    expect(equipment.residueCalories, closeTo(0.0, eps));
    expect(equipment.lastPositiveCalories, closeTo(0.0, eps));
  });

  test('startWorkout does not blank out continuationRecord', () async {
    final rnd = Random();
    await initPrefServiceForTest();
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
    equipment.continuationRecord = RecordWithSport.getRandom(descriptor.sport, rnd)
      ..distance = rnd.nextDouble() + 100
      ..elapsed = rnd.nextInt(1000) + 60
      ..calories = rnd.nextInt(1000) + 10;

    equipment.startWorkout();

    expect(equipment.continuationRecord.distance! > 0.0, true);
    expect(equipment.continuationRecord.elapsed! > 0, true);
    expect(equipment.continuationRecord.calories! > 0, true);
  });

  group('stopWorkout blanks out calorie helper variables', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((caloriesRnd) {
      final calories = caloriesRnd + 1;
      test('$calories', () async {
        final hrBasedCalories = rnd.nextBool();
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final activity = Activity(
          deviceId: mPowerImportDeviceId,
          deviceName: descriptor.modelName,
          hrmId: "",
          start: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.sport,
          powerFactor: 1.0,
          calorieFactor: 1.0,
          hrCalorieFactor: 1.0,
          hrmCalorieFactor: 1.0,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.sport,
        );
        equipment.initPower2SpeedConstants();
        equipment.workoutState = WorkoutState.moving;
        equipment.processRecord(RecordWithSport(
          sport: descriptor.sport,
          speed: 8.0,
          calories: calories,
        ));

        expect(equipment.lastPositiveCalories, closeTo(calories, eps));

        equipment.stopWorkout();

        expect(equipment.residueCalories, closeTo(0.0, eps));
        expect(equipment.lastPositiveCalories, closeTo(0.0, eps));
      });
    });
  });

  test('keySelector returns badKey for empty data bytes', () async {
    await initPrefServiceForTest();
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

    final key = equipment.keySelector([]);

    expect(key, FitnessEquipment.badKey);
  });

  test('keySelector returns 0 for Stages SB20 speed only data bytes', () async {
    await initPrefServiceForTest();
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

    final key = equipment.keySelector([0, 0, 96, 10]);

    expect(key, 0);
  });

  group('keySelector interprets feature bytes little endian', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 256, rnd).forEach((lsb) {
      final msb = rnd.nextInt(256);
      test('[$lsb $msb]', () async {
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final key = equipment.keySelector([lsb, msb]);

        expect(key, lsb + 256 * msb);
      });
    });
  });

  group('keySelector handles single byte flag devices', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 256, rnd).forEach((lsb) {
      final msb = rnd.nextInt(256);
      test('[$lsb $msb]', () async {
        final descriptor = DeviceFactory.getCSCBasedBike();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final key = equipment.keySelector([lsb, msb]);

        expect(key, lsb);
      });
    });
  });

  group('keySelector handles triple byte flag devices', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 256, rnd).forEach((lsb) {
      final ssb = rnd.nextInt(256);
      final msb = rnd.nextInt(256);
      test('[$lsb $ssb $msb]', () async {
        final descriptor = DeviceFactory.getGenericFTMSCrossTrainer();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final key = equipment.keySelector([lsb, ssb, msb]);

        expect(key, lsb + 256 * ssb + 65536 * msb);
      });
    });
  });
}
