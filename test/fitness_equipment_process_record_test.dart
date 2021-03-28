import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:preferences/preference_service.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/models/activity.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';
import 'fitness_equipment_process_record_test.mocks.dart';

@GenerateMocks([BluetoothDevice])
void main() {
  group('processRecord recognizes total calorie counting capability', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 400, rnd).forEach((calorieBase) {
      final calorie = calorieBase + 100;
      test('$calorie', () async {
        await PrefService.init(prefix: 'pref_');
        final equipment =
            FitnessEquipment(descriptor: deviceMap["SIC4"], device: MockBluetoothDevice());

        equipment.processRecord(Record(calories: calorie));

        expect(equipment.hasTotalCalorieCounting, true);
      });
    });
  });

  group('processRecord recognizes total calorie counting capability 2', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 500, rnd).forEach((calorie) {
      test('$calorie', () async {
        await PrefService.init(prefix: 'pref_');
        final equipment =
            FitnessEquipment(descriptor: deviceMap["SIC4"], device: MockBluetoothDevice());

        equipment.processRecord(Record(calories: 0));
        equipment.processRecord(Record(calories: calorie));
        equipment.processRecord(Record(calories: 0));

        expect(equipment.hasTotalCalorieCounting, true);
      });
    });
  });

  group('processRecord recognizes lack total calorie counting capability', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 500, rnd).forEach((calorie) {
      test('$calorie', () async {
        await PrefService.init(prefix: 'pref_');
        final equipment =
            FitnessEquipment(descriptor: deviceMap["SIC4"], device: MockBluetoothDevice());

        equipment.processRecord(Record(calories: 0));
        equipment.processRecord(Record(calories: 0));
        equipment.processRecord(Record(calories: 0));

        expect(equipment.hasTotalCalorieCounting, false);
      });
    });
  });

  group('processRecord calculates calories from caloriesPerHour', () {
    final rnd = Random();
    getRandomDoubles(SMALL_REPETITION, 3, rnd).forEach((value) {
      final calPerHour = (1.0 + value) * (60 * 60);
      test('$calPerHour', () async {
        await PrefService.init(prefix: 'pref_');
        final oneSecondAgo = DateTime.now().subtract(Duration(seconds: 1));
        final descriptor = deviceMap["SIC4"];
        final activity = Activity(
          deviceId: "",
          deviceName: descriptor.modelName,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord =
            Record(timeStamp: oneSecondAgo.millisecondsSinceEpoch, elapsedMillis: 0, calories: 0);

        final record = equipment.processRecord(Record(caloriesPerHour: calPerHour));

        final expected = (calPerHour / (60 * 60)).floor();
        expect(record.calories, expected);
      });
    });
  });

  group('processRecord calculates calories from power', () {
    final rnd = Random();
    getRandomDoubles(SMALL_REPETITION, 150, rnd).forEach((pow) {
      final descriptor = deviceMap["SIC4"];
      final power = ((150 + pow) / DeviceDescriptor.J2KCAL / descriptor.calorieFactor).floor();
      test('$power', () async {
        await PrefService.init(prefix: 'pref_');
        final oneSecondAgo = DateTime.now().subtract(Duration(seconds: 1));
        final activity = Activity(
          deviceId: "",
          deviceName: descriptor.modelName,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord =
            Record(timeStamp: oneSecondAgo.millisecondsSinceEpoch, elapsedMillis: 0, calories: 0);

        final record = equipment.processRecord(Record(power: power));

        expect(record.calories, (150 + pow).floor());
      });
    });
  });

  group('processRecord does not override calories when explicitly reported available', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 300, rnd).forEach((calories) {
      test('$calories', () async {
        await PrefService.init(prefix: 'pref_');
        final oneSecondAgo = DateTime.now().subtract(Duration(seconds: 1));
        final descriptor = deviceMap["SIC4"];
        final activity = Activity(
          deviceId: "",
          deviceName: descriptor.modelName,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord =
            Record(timeStamp: oneSecondAgo.millisecondsSinceEpoch, elapsedMillis: 0, calories: 0);

        final record = equipment.processRecord(Record(calories: calories));

        expect(record.calories, calories);
      });
    });
  });

  group('processRecord calculates distance from speed', () {
    final rnd = Random();
    getRandomDoubles(SMALL_REPETITION, 10, rnd).forEach((speed) {
      test('$speed', () async {
        await PrefService.init(prefix: 'pref_');
        final oneSecondAgo = DateTime.now().subtract(Duration(seconds: 1));
        final descriptor = deviceMap["SIC4"];
        final activity = Activity(
          deviceId: "",
          deviceName: descriptor.modelName,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord =
            Record(timeStamp: oneSecondAgo.millisecondsSinceEpoch, elapsedMillis: 0, distance: 10);

        final record = equipment.processRecord(Record(speed: speed));

        expect(record.distance, closeTo(10 + speed * DeviceDescriptor.KMH2MS, EPS));
      });
    });
  });

  group('processRecord does not override distance when explicitly reported available', () {
    final rnd = Random();
    getRandomDoubles(SMALL_REPETITION, 1000, rnd).forEach((distance) {
      test('$distance', () async {
        await PrefService.init(prefix: 'pref_');
        final oneSecondAgo = DateTime.now().subtract(Duration(seconds: 1));
        final descriptor = deviceMap["SIC4"];
        final activity = Activity(
          deviceId: "",
          deviceName: descriptor.modelName,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
        );
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());
        equipment.setActivity(activity);
        equipment.lastRecord = Record(
            timeStamp: oneSecondAgo.millisecondsSinceEpoch,
            elapsedMillis: 0,
            distance: 10,
            speed: 10);

        final record = equipment.processRecord(Record(distance: distance));

        expect(record.distance, distance);
      });
    });
  });
}
