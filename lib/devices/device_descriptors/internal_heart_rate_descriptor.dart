import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import 'data_handler.dart';
import 'heart_rate_descriptor.dart';

class InternalHeartRateDescriptor extends HeartRateSensorDescriptor implements DataHandler {
  InternalHeartRateDescriptor()
    : super(
        vendorName: "Device Internal",
        modelName: "Heart Rate Monitor",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "Heart Rate Monitor",
        fourCC: internalHeartRateMonitorFourCC,
        sport: ActivityType.workout,
      );
  // Heart Rate Sensor is usually not a fitness machine, so isFitnessMachine defaults to false in parent or here.
  // HeartRateSensorDescriptor doesn't explicitly set isFitnessMachine?
  // Let's assume default is false. DeviceDescriptor default is false.

  @override
  InternalHeartRateDescriptor clone() => InternalHeartRateDescriptor();

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

  // DataHandler implementation (no-ops/defaults as internal sensor handles its own data)
  @override
  bool isDataProcessable(List<int> data) {
    return false;
  }

  @override
  bool isFlagValid(int flag) {
    return false;
  }

  @override
  void processFlag(int flag, int dataLength) {
    // No-op
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return null;
  }
}
