import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../persistence/isar/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/heart_rate_monitor.dart';
import '../gatt/hrm.dart';
import 'device_descriptor.dart';

abstract class CyclingSensorDescriptor extends DeviceDescriptor {
  final String serviceUuid;
  final String characteristicUuid;
  ComplexSensor? sensor;

  CyclingSensorDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    required super.deviceCategory,
    super.tag,
    required this.serviceUuid,
    required this.characteristicUuid,
    super.flagByteSize,
  }) : super(
          sport: ActivityType.ride,
          isMultiSport: false,
          dataServiceId: serviceUuid,
          dataCharacteristicId: characteristicUuid,
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
  void processFlag(int flag) {
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
    // TODO: ask the user whether they prefer to pair the HRM to the console or not. We assume yes now.
    final requiredService = services
        .firstWhereOrNull((service) => service.serviceUuid.uuidString() == heartRateServiceUuid);
    if (requiredService == null) {
      return [];
    }

    final additionalSensor = HeartRateMonitor(device);
    additionalSensor.services = services;
    return [additionalSensor];
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
        services.firstWhereOrNull((service) => service.serviceUuid.uuidString() == serviceUuid);
    if (requiredService == null) {
      return;
    }

    sensor = getSensor(device);
    sensor!.services = services;
  }
}
