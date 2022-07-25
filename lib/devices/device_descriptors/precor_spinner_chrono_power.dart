import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import '../device_fourcc.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class PrecorSpinnerChronoPower extends FixedLayoutDeviceDescriptor {
  PrecorSpinnerChronoPower()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: precorSpinnerChronoPowerFourCC,
          vendorName: "Precor",
          modelName: "Spinner Chrono Power",
          namePrefixes: ["CHRONO"],
          manufacturerPrefix: "Precor",
          manufacturerFitId: precorFitId,
          model: "1",
          dataServiceId: precorServiceUuid,
          dataCharacteristicId: precorMeasurementUuid,
          heartRateByteIndex: 5,
          timeMetric: ShortMetricDescriptor(lsb: 3, msb: 4),
          caloriesMetric: ShortMetricDescriptor(lsb: 13, msb: 14),
          speedMetric: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100.0),
          powerMetric: ShortMetricDescriptor(lsb: 17, msb: 18),
          cadenceMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10.0),
          distanceMetric: ThreeByteMetricDescriptor(lsb: 10, msb: 12),
        );

  @override
  PrecorSpinnerChronoPower clone() => PrecorSpinnerChronoPower();

  @override
  bool isDataProcessable(List<int> data) {
    if (data.length != 19) return false;

    const measurementPrefix = [83, 89, 22];
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }
    return true;
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
      "PSCP",
      "executeControlOperation",
      "Not implemented!",
    );
    debugPrint("PSCP executeControlOperation Not implemented!");
  }
}
