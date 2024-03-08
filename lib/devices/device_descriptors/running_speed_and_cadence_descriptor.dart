import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../persistence/isar/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_power_meter_sensor.dart';
import '../gadgets/heart_rate_monitor.dart';
import '../gadgets/running_speed_and_cadence_sensor.dart';
import '../gatt/hrm.dart';
import '../gatt/power_meter.dart';
import '../gatt/rsc.dart';
import 'device_descriptor.dart';

class RunningSpeedAndCadenceDescriptor extends DeviceDescriptor {
  ComplexSensor? sensor;

  RunningSpeedAndCadenceDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    required super.deviceCategory,
    super.tag,
    super.flagByteSize = 1,
  }) : super(
          sport: ActivityType.run,
          isMultiSport: false,
          dataServiceId: runningCadenceServiceUuid,
          dataCharacteristicId: runningCadenceMeasurementUuid,
          controlCharacteristicId: "",
          listenOnControl: false,
          hasFeatureFlags: true,
        );

  @override
  bool isDataProcessable(List<int> data) {
    if (sensor == null) {
      return false;
    }

    final isProcessable = sensor!.canMeasurementProcessed(data);
    featuresFlag = sensor!.featureFlag;
    byteCounter = sensor!.expectedLength;

    return isProcessable;
  }

  @override
  void initFlag() {
    super.initFlag();
    sensor?.initFlag();
  }

  @override
  bool isFlagValid(int flag) {
    return flag >= 0;
  }

  @override
  void processFlag(int flag, int dataLength) {
    if (sensor == null) {
      return;
    }

    sensor!.processFlag(flag);
    featuresFlag = sensor!.featureFlag;
    byteCounter = sensor!.expectedLength;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return sensor?.processMeasurement(data);
  }

  @override
  void stopWorkout() {}

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    List<ComplexSensor> additionalSensors = [];
    // TODO: ask the user whether they prefer to pair the HRM to the console or not. We assume yes now.
    final hrmService = services
        .firstWhereOrNull((service) => service.serviceUuid.uuidString() == heartRateServiceUuid);
    if (hrmService != null) {
      final additionalSensor = HeartRateMonitor(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    final powerMeterService = services
        .firstWhereOrNull((service) => service.serviceUuid.uuidString() == cyclingPowerServiceUuid);
    if (powerMeterService != null) {
      final additionalSensor = CyclingPowerMeterSensor(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    return additionalSensors;
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging().log(logLevel, logLevelError, tag, "executeControlOperation", "Not implemented!");
  }

  @override
  void setDevice(BluetoothDevice device, List<BluetoothService> services) {
    if (sensor != null) {
      return;
    }

    final requiredService =
        services.firstWhereOrNull((service) => service.serviceUuid.uuidString() == dataServiceId);
    if (requiredService == null) {
      return;
    }

    sensor = getSensor(device);
    sensor!.services = services;
  }

  @override
  RunningSpeedAndCadenceDescriptor clone() => RunningSpeedAndCadenceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
        deviceCategory: deviceCategory,
      )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return RunningSpeedAndCadenceSensor(device);
  }
}
