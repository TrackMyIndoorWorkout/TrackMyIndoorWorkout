import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/isar/record.dart';
import '../../utils/bluetooth.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../../utils/power_speed_mixin.dart';
import '../device_fourcc.dart';
import '../gadgets/cadence_mixin.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/schwinn_x70_hr_sensor.dart';
import '../gatt/ftms.dart';
import '../gatt/schwinn_x70.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/six_byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class SchwinnX70 extends FixedLayoutDeviceDescriptor with CadenceMixin, PowerSpeedMixin {
  static const magicNumbers = [17, 32, 0];
  static const magicFlag = 32 * 256 + 17;

  MetricDescriptor? resistanceMetric;
  // From https://github.com/ursoft/connectivity-samples/blob/main/BluetoothLeGatt/Application/src/main/java/com/example/android/bluetoothlegatt/BluetoothLeService.java
  static const List<double> resistancePowerFactor = [
    0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, // 1-13
    0.75, 0.91, 1.07, // 14-16
    1.23, 1.39, 1.55, // 17-19
    1.72, 1.88, 2.04, // 20-22
    2.20, 2.36, 2.52 // 23-25
  ];
  late double lastTime;
  late double lastCalories;
  late double lastPower;
  late DateTime lastRxTime;
  RecordWithSport? lastRecord;

  SchwinnX70()
      : super(
          sport: deviceSportDescriptors[schwinnX70BikeFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[schwinnX70BikeFourCC]!.isMultiSport,
          fourCC: schwinnX70BikeFourCC,
          vendorName: "Schwinn",
          modelName: "SCHWINN 170/270",
          manufacturerNamePart: "Nautilus", // "SCHWINN 170/270"
          manufacturerFitId: nautilusFitId,
          model: "",
          tag: "SCH_X70",
          dataServiceId: schwinnX70ServiceUuid,
          dataCharacteristicId: schwinnX70MeasurementUuid,
          controlCharacteristicId: schwinnX70ControlUuid,
          listenOnControl: false,
          timeMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 1.0),
          caloriesMetric: SixByteMetricDescriptor(lsb: 10, msb: 15, divider: 1.0),
          cadenceMetric: ThreeByteMetricDescriptor(lsb: 4, msb: 6, divider: 1.0),
        ) {
    resistanceMetric = ByteMetricDescriptor(lsb: 16);
    initCadence(5, 64, maxUint24);
    initPower2SpeedConstants();
    lastTime = -1.0;
    lastCalories = -1.0;
    lastPower = -1.0;
    lastRxTime = DateTime.now();
  }

  @override
  SchwinnX70 clone() => SchwinnX70();

  @override
  bool isDataProcessable(List<int> data) {
    if (data.length != 17) return false;

    const measurementPrefix = magicNumbers;
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }

    return true;
  }

  @override
  bool isFlagValid(int flag) {
    return flag == magicFlag;
  }

  @override
  void stopWorkout() {
    clearCadenceData();
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final time = getTime(data);
    final calories = getCalories(data);
    final rxTime = DateTime.now();
    final duration = rxTime.difference(lastRxTime);
    lastRxTime = rxTime;
    if (lastTime < 0 || duration.inSeconds > 63) {
      lastTime = time!;
      lastCalories = calories!;
      lastPower = 0.0;
      lastRecord = null;
      return RecordWithSport(sport: sport);
    } else if (time == lastTime) {
      return lastRecord ?? RecordWithSport(sport: sport);
    }

    addCadenceData(time! / 1024, getCadence(data));
    final resistance = max((resistanceMetric?.getMeasurementValue(data)?.toInt() ?? 1) - 1, 0);
    final deltaCalories = max(calories! - lastCalories, 0);
    lastCalories = calories;
    var deltaTime = time - lastTime;
    lastTime = time;
    if (deltaTime < 0) {
      deltaTime += 65536;
    }

    // Custom way from
    // https://github.com/ursoft/connectivity-samples/blob/main/BluetoothLeGatt/Application/src/main/java/com/example/android/bluetoothlegatt/BluetoothLeService.java
    final power = (deltaCalories / deltaTime * 0.42 * resistancePowerFactor[resistance]);

    if (lastPower == -1.0 || (lastPower - power).abs() < 400.0) {
      lastPower = power;
    } else {
      lastPower += (power - lastPower) / 2.0;
    }

    if (lastPower < 0) {
      lastPower = 1.0;
    }

    final integerPower = lastPower.toInt();
    final speed = velocityForPowerCardano(integerPower) * DeviceDescriptor.ms2kmh;
    final record = RecordWithSport(
      distance: null,
      elapsed: testing ? time ~/ 1024 : null,
      calories: calories ~/ 2097152,
      power: integerPower,
      speed: speed,
      cadence: min(computeCadence().toInt(), maxByte),
      heartRate: null,
      sport: sport,
    );
    if (testing) {
      record.elapsedMillis = time ~/ 1.024;
    }

    lastRecord = record;

    return record;
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    if (!(await isBluetoothOn())) {
      return;
    }

    if (controlPoint == null || blockSignalStartStop) {
      return;
    }

    if (opCode == startOrResumeControl /* requestControl */ || opCode == stopOrPauseControl) {
      return;
    }

    if (opCode == requestControl /* startOrResumeControl */) {
      List<int> startHrStreamCommand = [
        0x05 /* length */,
        0x03 /* seq-с ceiling */,
        0xD9 /* crc = sum to 0 */,
        0x00,
        0x1F /* command */
      ];

      try {
        await controlPoint.write(startHrStreamCommand);
      } on Exception catch (e, stack) {
        Logging()
            .logException(logLevel, tag, "executeControlOperation", "controlPoint.write", e, stack);
      }
    }
  }

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    final requiredService = services.firstWhereOrNull(
        (service) => service.serviceUuid.uuidString() == SchwinnX70HrSensor.serviceUuid);
    if (requiredService == null) {
      return [];
    }

    final requiredCharacteristic = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == SchwinnX70HrSensor.characteristicUuid);
    if (requiredCharacteristic == null) {
      return [];
    }

    final additionalSensor = SchwinnX70HrSensor(device);
    additionalSensor.services = services;
    return [additionalSensor];
  }

  @override
  void trimQueues() {
    trimQueue();
  }
}
