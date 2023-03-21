import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../gadgets/complex_sensor.dart';
import '../gatt/ftms.dart';
import 'data_handler.dart';

enum DeviceCategory {
  smartDevice,
  antPlusDevice,
  primarySensor,
  secondarySensor,
}

abstract class DeviceDescriptor extends DataHandler {
  static const double ms2kmh = 3.6;
  static const double kmh2ms = 1 / ms2kmh;
  static const double oldPowerCalorieFactorDefault = 3.6;
  static const double powerCalorieFactorDefault = 4.0;

  String sport;
  final bool isMultiSport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  final String manufacturerNamePart;
  final int manufacturerFitId;
  final String model;
  DeviceCategory deviceCategory;
  final bool isPolling;
  String dataServiceId;
  String dataCharacteristicId;
  String controlCharacteristicId;
  bool listenOnControl;
  String statusCharacteristicId;

  bool canMeasureCalories;

  double? slowPace;

  DeviceDescriptor({
    required this.sport,
    required this.isMultiSport,
    required this.fourCC,
    required this.vendorName,
    required this.modelName,
    required this.manufacturerNamePart,
    required this.manufacturerFitId,
    required this.model, // Maybe eradicate?
    required this.deviceCategory,
    this.isPolling = false,
    this.dataServiceId = "",
    this.dataCharacteristicId = "",
    this.controlCharacteristicId = "",
    this.listenOnControl = true,
    this.statusCharacteristicId = "",
    this.canMeasureCalories = true,
    hasFeatureFlags = true,
    flagByteSize = 2,
    heartRateByteIndex,
    timeMetric,
    caloriesMetric,
    speedMetric,
    powerMetric,
    cadenceMetric,
    distanceMetric,
  }) : super(
          hasFeatureFlags: hasFeatureFlags,
          flagByteSize: flagByteSize,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  String get fullName => '$vendorName $modelName';
  bool get isFitnessMachine => dataServiceId == fitnessMachineUuid;

  void stopWorkout();

  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo});

  ComplexSensor? getSensor(BluetoothDevice device) {
    return null;
  }

  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    return [];
  }

  void setDevice(BluetoothDevice device, List<BluetoothService> services) {}

  void trimQueues() {}

  Future<void> pollMeasurement(BluetoothCharacteristic controlPoint, int logLevel) async {}
}
