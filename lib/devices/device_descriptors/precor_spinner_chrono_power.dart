import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../preferences/log_level.dart';
import '../../utils/logging.dart';
import '../gatt/precor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../device_fourcc.dart';
import 'fixed_layout_device_descriptor.dart';

class PrecorSpinnerChronoPower extends FixedLayoutDeviceDescriptor {
  static const magicNumbers = [83, 89, 22];
  static const magicFlag = 22 * 65536 + 89 * 256 + 83;

  PrecorSpinnerChronoPower()
      : super(
          sport: deviceSportDescriptors[precorSpinnerChronoPowerFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[precorSpinnerChronoPowerFourCC]!.isMultiSport,
          fourCC: precorSpinnerChronoPowerFourCC,
          vendorName: "Precor",
          modelName: "Spinner Chrono Power",
          manufacturerNamePart: "Precor",
          manufacturerFitId: precorFitId,
          model: "1",
          tag: "PSCP",
          dataServiceId: precorServiceUuid,
          dataCharacteristicId: precorMeasurementUuid,
          listenOnControl: false,
          flagByteSize: 3,
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

    const measurementPrefix = magicNumbers;
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }
    return true;
  }

  @override
  bool isFlagValid(int flag) {
    return flag == magicFlag;
  }

  @override
  void stopWorkout() {}

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging.log(logLevel, logLevelError, tag, "executeControlOperation", "Not implemented!");
  }
}
