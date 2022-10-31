import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/activity.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/hr_based_calories.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'utils.dart';
import 'fitness_equipment_process_record_test.mocks.dart';

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('processRecord recognizes total calorie counting capability', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 400, rnd).forEach((calorieBase) {
      final calorie = calorieBase + 100;
      test('$calorie', () async {
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          firstCalories: false,
        );
        equipment.initPower2SpeedConstants();
        equipment.workoutState = WorkoutState.moving;

        equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          calories: calorie,
        ));

        expect(equipment.deviceHasTotalCalorieReporting, true);
      });
    });
  });

  group('processRecord recognizes total calorie counting capability 2', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((calorie) {
      calorie++;
      test('$calorie', () async {
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final equipment = FitnessEquipment(
          descriptor: descriptor,
          device: MockBluetoothDevice(),
          firstCalories: false,
        );
        equipment.initPower2SpeedConstants();
        equipment.workoutState = WorkoutState.moving;

        equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          calories: 0,
        ));
        equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          calories: calorie,
        ));
        equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          calories: 0,
        ));

        expect(equipment.deviceHasTotalCalorieReporting, true);
      });
    });
  });

  test('processRecord recognizes lack total calorie counting capability', () async {
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(
      descriptor: descriptor,
      device: MockBluetoothDevice(),
      firstCalories: false,
    );
    equipment.initPower2SpeedConstants();
    equipment.workoutState = WorkoutState.moving;

    // calories: null
    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
    ));
    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
    ));
    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
    ));

    expect(equipment.deviceHasTotalCalorieReporting, false);
  });

  test('processRecord recognizes lack total calorie counting capability when idle', () async {
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(
      descriptor: descriptor,
      device: MockBluetoothDevice(),
      firstCalories: false,
    );
    equipment.initPower2SpeedConstants();
    equipment.workoutState = WorkoutState.moving;

    equipment.processRecord(
      RecordWithSport(
        sport: descriptor.defaultSport,
        speed: 8.0,
        calories: 0,
      ),
      true,
    );
    equipment.processRecord(
      RecordWithSport(
        sport: descriptor.defaultSport,
        speed: 8.0,
        calories: 0,
      ),
      true,
    );
    equipment.processRecord(
      RecordWithSport(
        sport: descriptor.defaultSport,
        speed: 8.0,
        calories: 0,
      ),
      true,
    );

    expect(equipment.deviceHasTotalCalorieReporting, false);
  });

  test('processRecord decides total calorie counting capability when not idle', () async {
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final equipment = FitnessEquipment(
      descriptor: descriptor,
      device: MockBluetoothDevice(),
      firstCalories: false,
    );
    equipment.initPower2SpeedConstants();
    equipment.workoutState = WorkoutState.moving;

    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
      calories: 0,
    ));
    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
      calories: 0,
    ));
    equipment.processRecord(RecordWithSport(
      sport: descriptor.defaultSport,
      speed: 8.0,
      calories: 0,
    ));

    expect(equipment.deviceHasTotalCalorieReporting, true);
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
        final oneMinuteAgo = DateTime.now().subtract(const Duration(seconds: seconds));
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final activity = Activity(
          deviceId: mPowerImportDeviceId,
          deviceName: descriptor.modelName,
          hrmId: "",
          start: oneMinuteAgo.millisecondsSinceEpoch,
          startDateTime: oneMinuteAgo,
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneMinuteAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          caloriesPerHour: calPerHour,
        ));

        final expected = (calPerHour / (60 * 60) * seconds * calorieFactor).floor();
        expect(record.calories, closeTo(expected, 1));
      });
    });
  });

  group('processRecord calculates calories from power', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 150, rnd).forEach((pow) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      final power = ((150 + pow) / jToKCal).floor();
      test('$power', () async {
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          power: power,
        ));

        final expected =
            (150 + pow) * powerFactor * calorieFactor * DeviceDescriptor.powerCalorieFactorDefault;
        expect(record.calories, expected.floor());
      });
    });
  });

  group('processRecord calculates power from caloriesPerMinute', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 6.0, rnd).forEach((caloriesPerMinute) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      caloriesPerMinute += 1.0; // Making sure not close to zero
      test('$caloriesPerMinute', () async {
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          caloriesPerMinute: caloriesPerMinute,
        ));

        final expected =
            ((caloriesPerMinute * calorieFactor * 50.0 / 3.0).round() * powerFactor).round();
        expect(record.power, expected);
      });
    });
  });

  group('processRecord calculates power from caloriesPerHour', () {
    final rnd = Random();
    getRandomDoubles(smallRepetition, 1000.0, rnd).forEach((caloriesPerHour) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      caloriesPerHour += 100.0; // Making sure not close to zero
      test('$caloriesPerHour', () async {
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          caloriesPerHour: caloriesPerHour,
        ));

        final expected =
            ((caloriesPerHour * calorieFactor * 5.0 / 18.0).round() * powerFactor).round();
        expect(record.power, expected);
      });
    });
  });

  group('processRecord calculates power from HRM based calories', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 80, rnd).forEach((heartRate) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      heartRate += 100; // Making sure in good range
      test('$heartRate', () async {
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.useHrBasedCalorieCounting = true;
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          heartRate: heartRate,
        ));

        final expectedCaloriesPerMinute = hrBasedCaloriesPerMinute(
                heartRate, equipment.weight, equipment.age, equipment.isMale, equipment.vo2Max) *
            hrCalorieFactor;
        expect(record.caloriesPerMinute, closeTo(expectedCaloriesPerMinute, eps));

        final expectedPower =
            ((expectedCaloriesPerMinute * 50.0 / 3.0).round() * powerFactor).round();
        expect(record.power, expectedPower);
      });
    });
  });

  group('processRecord does not calculate power from HRM based calories when paused', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 80, rnd).forEach((heartRate) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrmCalorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final hrBasedCalories = rnd.nextBool();
      heartRate += 100; // Making sure in good range
      test('$heartRate', () async {
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.useHrBasedCalorieCounting = true;
        equipment.workoutState =
            WorkoutState.moving; // Will transition to justPaused => isNotMoving

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          heartRate: heartRate,
        ));

        final expectedCaloriesPerMinute = hrBasedCaloriesPerMinute(
                heartRate, equipment.weight, equipment.age, equipment.isMale, equipment.vo2Max) *
            hrCalorieFactor;
        expect(record.caloriesPerMinute, closeTo(expectedCaloriesPerMinute, eps));
        expect(record.power, null);
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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstCalories: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          calories: 0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          calories: calories,
        ));

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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstDistance: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.initPower2SpeedConstants();
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          distance: 10.0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstDistance: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, true);
        equipment.initPower2SpeedConstants();
        final adjustedRecord = RecordWithSport(sport: descriptor.defaultSport, distance: distance);
        adjustedRecord.adjustByFactors(powerFactor, calorieFactor, true);
        equipment.lastRecord = RecordWithSport(
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsedMillis: 0,
          distance: min(adjustedRecord.distance!, 10.0),
          speed: 10.0,
          sport: descriptor.defaultSport,
        );
        equipment.workoutState = WorkoutState.moving;

        final record = equipment.processRecord(RecordWithSport(
          sport: descriptor.defaultSport,
          speed: 8.0,
          distance: distance,
        ));

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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstCalories: false,
          firstDistance: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );
        final adjustedRecord = RecordWithSport(
          sport: descriptor.defaultSport,
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsed: 0,
          elapsedMillis: 0,
          distance: distance,
          speed: speed,
          calories: calories,
        );
        adjustedRecord.adjustByFactors(powerFactor, calorieFactor, extendTuning);
        equipment.lastRecord = adjustedRecord;
        equipment.workoutState = WorkoutState.moving;

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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstCalories: false,
          firstDistance: false,
        );
        equipment.setActivity(activity);
        equipment.setFactors(
          powerFactor,
          calorieFactor,
          calorieFactor,
          calorieFactor,
          extendTuning,
        );

        final adjustedRecord = RecordWithSport(
          sport: descriptor.defaultSport,
          timeStamp: oneSecondAgo.millisecondsSinceEpoch,
          elapsed: 0,
          elapsedMillis: 0,
          distance: distance,
          speed: speed,
          calories: calories,
        );
        adjustedRecord.adjustByFactors(powerFactor, calorieFactor, extendTuning);
        equipment.lastRecord = adjustedRecord;
        equipment.workoutState = WorkoutState.moving;

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

  group('processRecord recognizes first* initialization goes as expected', () {
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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstCalories: true,
          firstDistance: true,
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
        expect(record.calories, closeTo(0, eps));
      });
    });
  });

  group('processRecord recognizes first* when start is at mid workout', () {
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
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
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
          firstCalories: true,
          firstDistance: true,
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

        final deltaRecord = RecordWithSport(
          sport: descriptor.defaultSport,
          distance: deltaDistance,
          speed: speed,
          calories: deltaCalories,
        );
        deltaRecord.adjustByFactors(powerFactor, calorieFactor, extendTuning);

        expect(record.distance, closeTo(deltaRecord.distance!, eps));
        expect(record.calories, closeTo(deltaRecord.calories!, 1));
      });
    });
  });
}
