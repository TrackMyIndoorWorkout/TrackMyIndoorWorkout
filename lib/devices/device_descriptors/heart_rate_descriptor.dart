import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../device_fourcc.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/heart_rate_monitor.dart';
import '../gatt/hrm.dart';
import 'device_descriptor.dart';

class HeartRateSensorDescriptor extends DeviceDescriptor {
  late HeartRateMonitor? sensor;

  HeartRateSensorDescriptor({
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    super.tag,
  }) : super(
         fourCC: heartRateMonitorFourCC,
         sport: ActivityType.ride,
         isMultiSport: false,
         deviceCategory: DeviceCategory.primarySensor,
         dataServiceId: heartRateServiceUuid,
         dataCharacteristicId: heartRateMeasurementUuid,
         controlCharacteristicId: "",
         listenOnControl: false,
         hasFeatureFlags: true,
         flagByteSize: 1,
       ) {
    sensor = null;
  }

  @override
  HeartRateSensorDescriptor clone() => HeartRateSensorDescriptor(
    vendorName: vendorName,
    modelName: modelName,
    manufacturerNamePart: manufacturerNamePart,
    manufacturerFitId: manufacturerFitId,
    model: model,
  )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return HeartRateMonitor(device);
  }

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
    BluetoothDevice device,
    List<BluetoothService> services,
  ) {
    return [];
  }

  @override
  Future<void> executeControlOperation(
    BluetoothCharacteristic? controlPoint,
    bool blockSignalStartStop,
    int logLevel,
    int opCode, {
    int? controlInfo,
  }) async {
    Logging().log(logLevel, logLevelError, tag, "executeControlOperation", "Not implemented!");
  }

  @override
  void setDevice(BluetoothDevice device, List<BluetoothService> services) {
    if (sensor != null) {
      return;
    }

    final requiredService = services.firstWhereOrNull(
      (service) => service.serviceUuid.uuidString() == dataServiceId,
    );
    if (requiredService == null) {
      return;
    }

    sensor = getSensor(device) as HeartRateMonitor;
    sensor!.services = services;
  }
}
