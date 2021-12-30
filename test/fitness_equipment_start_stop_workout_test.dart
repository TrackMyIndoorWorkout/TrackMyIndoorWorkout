import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/models/activity.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';
import 'fitness_equipment_process_record_test.mocks.dart';

@GenerateMocks([BluetoothDevice])
void main() {
  test('startWorkout blanks out leftover lastRecord', () async {
    final rnd = Random();
    await initPrefServiceForTest();
    final descriptor = deviceMap["SIC4"]!;
    final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
    equipment.lastRecord = RecordWithSport.getRandom(descriptor.defaultSport, rnd);

    equipment.startWorkout();

    expect(equipment.lastRecord.distance, closeTo(0.0, eps));
    expect(equipment.lastRecord.elapsed, 0);
    expect(equipment.lastRecord.calories, 0);
    expect(equipment.lastRecord.power, 0);
    expect(equipment.lastRecord.speed, closeTo(0.0, eps));
    expect(equipment.lastRecord.cadence, 0);
    expect(equipment.lastRecord.heartRate, 0);
    expect(equipment.lastRecord.elapsedMillis, 0);
    expect(equipment.lastRecord.sport, descriptor.defaultSport);
    expect(equipment.lastRecord.pace, null);
    expect(equipment.lastRecord.strokeCount, null);
    expect(equipment.lastRecord.caloriesPerHour, null);
    expect(equipment.lastRecord.caloriesPerMinute, null);

    expect(equipment.residueCalories, closeTo(0.0, eps));
    expect(equipment.lastPositiveCalories, closeTo(0.0, eps));
  });

  group('stopWorkout blanks out calorie helper variables', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((calories) {
      test('$calories', () async {
        await initPrefServiceForTest();
        final hrBasedCalories = rnd.nextBool();
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = deviceMap["SIC4"]!;
        final activity = Activity(
          deviceId: mPowerImportDeviceId,
          deviceName: descriptor.modelName,
          hrmId: "",
          start: oneSecondAgo.millisecondsSinceEpoch,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
          powerFactor: 1.0,
          calorieFactor: 1.0,
          hrCalorieFactor: 1.0,
          hrmCalorieFactor: 1.0,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord =
            Record(timeStamp: oneSecondAgo.millisecondsSinceEpoch, elapsedMillis: 0, calories: 0);
        equipment
            .processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: calories));

        expect(equipment.lastPositiveCalories, closeTo(calories, eps));

        equipment.stopWorkout();

        expect(equipment.residueCalories, closeTo(0.0, eps));
        expect(equipment.lastPositiveCalories, closeTo(0.0, eps));
      });
    });
  });
}
