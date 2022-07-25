import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../track/tracks.dart';
import '../gatt_constants.dart';
import 'data_handler.dart';

abstract class DeviceDescriptor extends DataHandler {
  static const double ms2kmh = 3.6;
  static const double kmh2ms = 1 / ms2kmh;
  static const double oldPowerCalorieFactorDefault = 3.6;
  static const double powerCalorieFactorDefault = 4.0;

  String defaultSport;
  final bool isMultiSport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  final List<String> namePrefixes;
  final String manufacturerPrefix;
  final int manufacturerFitId;
  final String model;
  String dataServiceId;
  String dataCharacteristicId;
  String secondaryCharacteristicId;
  String controlCharacteristicId;
  bool listenOnControl;
  String statusCharacteristicId;
  final bool antPlus;

  bool canMeasureCalories;

  double? slowPace;

  DeviceDescriptor({
    required this.defaultSport,
    required this.isMultiSport,
    required this.fourCC,
    required this.vendorName,
    required this.modelName,
    required this.namePrefixes,
    required this.manufacturerPrefix,
    required this.manufacturerFitId,
    required this.model, // Maybe eradicate?
    this.dataServiceId = "",
    this.dataCharacteristicId = "",
    this.secondaryCharacteristicId = "",
    this.controlCharacteristicId = "",
    this.listenOnControl = true,
    this.statusCharacteristicId = "",
    this.antPlus = false,
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
  double get lengthFactor => getDefaultTrack(defaultSport).lengthFactor;
  bool get isFitnessMachine => dataServiceId == fitnessMachineUuid;

  void stopWorkout();

  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo});
}
