import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../persistence/models/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_power_meter_sensor.dart';
import '../gadgets/heart_rate_monitor.dart';
import '../gatt_constants.dart';
import 'device_descriptor.dart';

class CyclingPowerMeterDescriptor extends DeviceDescriptor {
  CyclingPowerMeterSensor? sensor;

  CyclingPowerMeterDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
  }) : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerPrefix: manufacturerPrefix,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: cyclingPowerServiceUuid,
          dataCharacteristicId: cyclingPowerMeasurementUuid,
          controlCharacteristicId: "",
          listenOnControl: false,
          hasFeatureFlags: true,
        );

  @override
  CyclingPowerMeterDescriptor clone() => CyclingPowerMeterDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        namePrefixes: namePrefixes,
        manufacturerPrefix: manufacturerPrefix,
        manufacturerFitId: manufacturerFitId,
        model: model,
      );

  @override
  bool isDataProcessable(List<int> data) {
    if (sensor == null) {
      return false;
    }

    return sensor!.canMeasurementProcessed(data);
  }

  @override
  void initFlag() {
    super.initFlag();
    sensor?.clearMetrics();
  }

  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    sensor?.processFlag(flag);
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return sensor?.processMeasurement(data);
  }

  @override
  void stopWorkout() {}

  @override
  ComplexSensor? getExtraSensor(BluetoothDevice device, List<BluetoothService> services) {
    // TODO: ask the user if they prefer they pair to the console. We assume now yes.
    final requiredService =
        services.firstWhereOrNull((service) => service.uuid.uuidString() == heartRateServiceUuid);
    if (requiredService == null) {
      return null;
    }

    final extraSensor = HeartRateMonitor(device);
    extraSensor.services = services;
    return extraSensor;
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging.log(
      logLevel,
      logLevelError,
      "Cycling Power Device",
      "executeControlOperation",
      "Not implemented!",
    );
    debugPrint("Cycling Power Device executeControlOperation Not implemented!");
  }

  @override
  void setDevice(BluetoothDevice device, List<BluetoothService> services) {
    final requiredService = services.firstWhereOrNull(
        (service) => service.uuid.uuidString() == CyclingPowerMeterSensor.serviceUuid);
    if (requiredService == null) {
      return;
    }

    final sensor = CyclingPowerMeterSensor(device);
    sensor.services = services;
  }
}
