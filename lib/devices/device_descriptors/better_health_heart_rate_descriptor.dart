import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import 'data_handler.dart';
import 'heart_rate_descriptor.dart';

class BetterHealthHeartRateDescriptor extends HeartRateSensorDescriptor implements DataHandler {
  BetterHealthHeartRateDescriptor()
    : super(
        vendorName: "Better Health Tracker",
        modelName: "HRM Broadcast",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "BHT HRM",
        fourCC: betterHealthHeartRateFourCC,
        sport: ActivityType.workout,
      );

  @override
  BetterHealthHeartRateDescriptor clone() => BetterHealthHeartRateDescriptor();

  @override
  void stopWorkout() {
    // No-op for BHT
  }

  @override
  Future<void> executeControlOperation(
    BluetoothCharacteristic? controlPoint,
    bool blockSignalStartStop,
    int logLevel,
    int opCode, {
    int? controlInfo,
  }) async {
    // No-op for BHT
  }

  // DataHandler implementation
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
