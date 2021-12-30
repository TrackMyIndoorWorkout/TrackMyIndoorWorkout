import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
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
    getRandomInts(smallRepetition, 400, rnd).forEach((calorieBase) {
      final calorie = calorieBase + 100;
      test('$calorie', () async {
        await initPrefServiceForTest();
        final descriptor = deviceMap["SIC4"]!;
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );

        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: calorie));

        expect(equipment.hasTotalCalorieCounting, true);
      });
    });
  });

  group('processRecord recognizes total calorie counting capability 2', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((calorie) {
      calorie++;
      test('$calorie', () async {
        await initPrefServiceForTest();
        final descriptor = deviceMap["SIC4"]!;
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );

        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: 0));
        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: calorie));
        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: 0));

        expect(equipment.hasTotalCalorieCounting, true);
      });
    });
  });

  group('processRecord recognizes lack total calorie counting capability', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((calorie) {
      test('$calorie', () async {
        await initPrefServiceForTest();
        final descriptor = deviceMap["SIC4"]!;
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );

        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: 0));
        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: 0));
        equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: 0));

        expect(equipment.hasTotalCalorieCounting, false);
      });
    });
  });

  group('processRecord calculates calories from caloriesPerHour', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 3, rnd).forEach((value) {
      final calPerHour = (1.0 + value) * (60 * 60);
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      const seconds = 60;
      test('$calPerHour $powerFactor $calorieFactor', () async {
        await initPrefServiceForTest();
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: seconds));
        final descriptor = deviceMap["SIC4"]!;
        final activity = Activity(
          deviceId: mPowerImportDeviceId,
          deviceName: descriptor.modelName,
          hrmId: "",
          start: oneSecondAgo.millisecondsSinceEpoch,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: hrCalorieFactor,
          hrmCalorieFactor: hrmCalorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = Record(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
        );

        final record = equipment.processRecord(
            RecordWithSport(sport: descriptor.defaultSport, caloriesPerHour: calPerHour));

        final expected = (calPerHour / (60 * 60) * seconds * calorieFactor).floor();
        expect(record.calories, expected);
      });
    });
  });

  group('processRecord calculates calories from power', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 150, rnd).forEach((pow) {
      final descriptor = deviceMap["SIC4"]!;
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final power = ((150 + pow) / jToKCal).floor();
      test('$power', () async {
        await initPrefServiceForTest();
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final activity = Activity(
          deviceId: mPowerImportDeviceId,
          deviceName: descriptor.modelName,
          hrmId: "",
          start: oneSecondAgo.millisecondsSinceEpoch,
          startDateTime: oneSecondAgo,
          fourCC: descriptor.fourCC,
          sport: descriptor.defaultSport,
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: hrCalorieFactor,
          hrmCalorieFactor: hrmCalorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = Record(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
        );

        final record =
            equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, power: power));

        expect(
            record.calories,
            ((150 + pow) * powerFactor * calorieFactor * DeviceDescriptor.powerCalorieFactorDefault)
                .floor());
      });
    });
  });

  group('processRecord does not override calories when explicitly reported available', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((calories) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      test('$calories', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: hrCalorieFactor,
          hrmCalorieFactor: hrmCalorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = Record(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
        );

        final record = equipment
            .processRecord(RecordWithSport(sport: descriptor.defaultSport, calories: calories));

        expect(record.calories, (calories * calorieFactor).round());
      });
    });
  });

  group('processRecord calculates distance from speed', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 20, rnd).forEach((speed) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      test('$speed', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: hrCalorieFactor,
          hrmCalorieFactor: hrmCalorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = Record(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          distance: 10,
        );

        final record =
            equipment.processRecord(RecordWithSport(sport: descriptor.defaultSport, speed: speed));

        expect(record.distance,
            closeTo(10 + speed * DeviceDescriptor.kmh2ms * powerFactor, displayEps));
      });
    });
  });

  group('processRecord does not override distance when explicitly reported available', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 1000, rnd).forEach((distance) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      test('$distance', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: hrCalorieFactor,
          hrmCalorieFactor: hrmCalorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        final adjustedRecord = descriptor.adjustRecord(
          RecordWithSport(
            sport: descriptor.defaultSport,
            distance: distance,
          ),
          powerFactor,
          calorieFactor,
          true,
        );
        equipment.lastRecord = Record(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          distance: min(adjustedRecord.distance!, 10),
          speed: 10,
        );

        final record = equipment
            .processRecord(RecordWithSport(sport: descriptor.defaultSport, distance: distance));

        expect(record.distance, closeTo(distance * powerFactor, displayEps));
      });
    });
  });

  group('processRecord cannot decrease cumulative variables', () {
    final rnd = Random();
    getRandomDoubles(repetition, 10000, rnd).forEach((distance) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final extendTuning = rnd.nextBool();
      final speed = rnd.nextDouble() * 20.0;
      final calories = (rnd.nextDouble() * 1000.0).round();

      test('$distance $calories $speed', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: calorieFactor,
          hrmCalorieFactor: calorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );
        equipment.lastRecord = descriptor.adjustRecord(
          RecordWithSport(
            sport: descriptor.defaultSport,
            timeStamp: oneSecondAgo.millisecondsSinceEpoch,
            elapsed: 0,
            elapsedMillis: 0,
            distance: distance,
            speed: speed,
            calories: calories,
          ),
          powerFactor,
          calorieFactor,
          extendTuning,
        );

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          distance: distance,
          speed: speed,
          calories: calories,
        ));

        expect(record.distance, greaterThanOrEqualTo(equipment.lastRecord.distance!));
        expect(record.elapsed, greaterThanOrEqualTo(equipment.lastRecord.elapsed!));
        expect(record.calories, greaterThanOrEqualTo(equipment.lastRecord.calories!));
      });
    });
  });

  group('processRecord cannot decrease cumulative variable protection', () {
    final rnd = Random();
    getRandomDoubles(repetition, 10000, rnd).forEach((distance) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final extendTuning = rnd.nextBool();
      final speed = rnd.nextDouble() * 20.0;
      final calories = (rnd.nextDouble() * 1000.0).round();

      test('$distance $calories $speed', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: calorieFactor,
          hrmCalorieFactor: calorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );
        equipment.lastRecord = descriptor.adjustRecord(
          RecordWithSport(
            sport: descriptor.defaultSport,
            timeStamp: oneSecondAgo.millisecondsSinceEpoch,
            elapsed: 0,
            elapsedMillis: 0,
            distance: distance,
            speed: speed,
            calories: calories,
          ),
          powerFactor,
          calorieFactor,
          extendTuning,
        );

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          distance: distance / 2,
          speed: speed / 2,
          calories: (calories / 2).round(),
        ));

        expect(record.distance, greaterThanOrEqualTo(equipment.lastRecord.distance!));
        expect(record.elapsed, greaterThanOrEqualTo(equipment.lastRecord.elapsed!));
        expect(record.calories, greaterThanOrEqualTo(equipment.lastRecord.calories!));
      });
    });
  });

  group('processRecord recognizes startingValues initialization goes as expected', () {
    final rnd = Random();
    getRandomDoubles(repetition, 10000, rnd).forEach((distance) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final extendTuning = rnd.nextBool();
      final speed = rnd.nextDouble() * 20.0;
      final elapsedMillis = (rnd.nextDouble() * 1000000.0 + 10000).round();
      final elapsed = (elapsedMillis / 1000).round();
      distance += 1000;
      final calories = (rnd.nextDouble() * 1000.0).round() + 100;

      test('$distance $calories $speed', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: calorieFactor,
          hrmCalorieFactor: calorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: true,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsed: elapsed,
          elapsedMillis: elapsedMillis,
          distance: distance,
          speed: speed,
          calories: calories,
        ));

        expect(record.distance, closeTo(0, eps));
        expect(record.elapsed, closeTo(0, eps));
        expect(record.calories, closeTo(0, eps));
      });
    });
  });

  group('processRecord recognizes startingValues when start is at mid workout', () {
    final rnd = Random();
    getRandomDoubles(repetition, 10000, rnd).forEach((distance) {
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final extendTuning = rnd.nextBool();
      final speed = rnd.nextDouble() * 20.0;
      final elapsedMillis = (rnd.nextDouble() * 1000000.0 + 10000).round();
      final elapsed = (elapsedMillis / 1000).round();
      distance += 1000;
      final calories = (rnd.nextDouble() * 1000.0).round() + 100;
      final deltaCalories = (rnd.nextDouble() * 10.0).round() + 1;
      final deltaDistance = rnd.nextDouble() * 20.0 + 5.0;

      test('$distance $calories $speed', () async {
        await initPrefServiceForTest();
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
          powerFactor: powerFactor,
          calorieFactor: calorieFactor,
          hrCalorieFactor: calorieFactor,
          hrmCalorieFactor: calorieFactor,
          hrBasedCalories: hrBasedCalories,
          timeZone: "America/Los_Angeles",
        );
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          startingValues: true,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );

        // Prime the startingValues logic
        equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsed: elapsed,
          elapsedMillis: elapsedMillis,
          distance: distance,
          speed: speed,
          calories: calories,
        ));

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          elapsed: elapsed + 1,
          elapsedMillis: elapsedMillis + 1000,
          distance: distance + deltaDistance,
          speed: speed,
          calories: calories + deltaCalories,
        ));

        final deltaRecord = descriptor.adjustRecord(
          RecordWithSport(
            sport: descriptor.defaultSport,
            distance: deltaDistance,
            speed: speed,
            calories: deltaCalories,
          ),
          powerFactor,
          calorieFactor,
          extendTuning,
        );

        expect(record.distance, closeTo(deltaRecord.distance!, eps));
        expect(record.elapsed, closeTo(1, eps));
        expect(record.calories, closeTo(deltaRecord.calories!, 1));
      });
    });
  });
}
