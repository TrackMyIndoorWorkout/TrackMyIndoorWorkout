import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../device_fourcc.dart';
import 'fixed_layout_device_descriptor.dart';

class Concept2Rower extends FixedLayoutDeviceDescriptor {
  static const expectedDataPacketLength = 19;
  static const distanceLsbByteIndex = 3;

  Concept2Rower()
      : super(
          defaultSport: ActivityType.rowing,
          isMultiSport: false,
          fourCC: concept2RowerFourCC,
          vendorName: "Concept2",
          modelName: "PM5",
          namePrefixes: ["PM5"],
          manufacturerPrefix: "Concept2",
          manufacturerFitId: concept2FitId,
          model: "PM5",
          dataServiceId: c2RowingPrimaryServiceUuid,
          dataCharacteristicId: c2RowingGeneralStatusUuid,
          listenOnControl: false,
          flagByteSize: 1,
          distanceMetric: ThreeByteMetricDescriptor(
            lsb: distanceLsbByteIndex,
            msb: distanceLsbByteIndex + 2,
            divider: 10,
          ),
        );

  @override
  Concept2Rower clone() => Concept2Rower();

  @override
  bool isDataProcessable(List<int> data) {
    return data.length == expectedDataPacketLength;
  }

  @override
  bool isFlagValid(int flag) {
    return true;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return RecordWithSport(
      distance: getDistance(data),
      sport: ActivityType.rowing,
    );
  }

  @override
  void stopWorkout() {}

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging.log(
      logLevel,
      logLevelError,
      "Concept2",
      "executeControlOperation",
      "Not implemented!",
    );
    debugPrint("Concept2 executeControlOperation Not implemented!");
  }
}
