import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import 'data_handler.dart';
import 'device_descriptor.dart';

class InternalSensorDescriptor extends DeviceDescriptor {
  InternalSensorDescriptor()
    : super(
        sport: ActivityType.workout,
        isMultiSport: true,
        fourCC: internalMotionSensorFourCC,
        vendorName: "Device Internal",
        modelName: "Motion Sensor",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "Motion Sensor",
        deviceCategory: DeviceCategory.primarySensor,
        canMeasureCalories: false,
        doNotReadManufacturerName: true,
      );

  @override
  void stopWorkout() {
    // No-op for internal sensor
  }

  @override
  Future<void> executeControlOperation(
    BluetoothCharacteristic? controlPoint,
    bool blockSignalStartStop,
    int logLevel,
    int opCode, {
    int? controlInfo,
  }) async {
    // No-op for internal sensor
  }

  @override
  DataHandler clone() {
    return InternalSensorDescriptor();
  }

  @override
  bool isDataProcessable(List<int> data) {
    return false;
  }

  @override
  bool isFlagValid(int flag) {
    return false;
  }

  @override
  void processFlag(int flag, int dataLength) {}

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return null;
  }
}
