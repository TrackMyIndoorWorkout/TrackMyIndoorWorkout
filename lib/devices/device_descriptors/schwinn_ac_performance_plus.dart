import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../preferences/log_level.dart';
import '../../persistence/isar/record.dart';
import '../../utils/logging.dart';
import '../device_fourcc.dart';
import 'device_descriptor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  static const double extraCalorieFactor = 3.9;

  SchwinnACPerformancePlus()
      : super(
          sport: deviceSportDescriptors[schwinnACPerfPlusFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[schwinnACPerfPlusFourCC]!.isMultiSport,
          fourCC: schwinnACPerfPlusFourCC,
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          manufacturerNamePart: "Schwinn",
          manufacturerFitId: stravaFitId,
          model: "Schwinn AC Perf+",
          deviceCategory: DeviceCategory.antPlusDevice,
          tag: "SCHWINN_AC_PERF+",
          canMeasureCalories: true, // #258 avoid over inflation
        );

  @override
  SchwinnACPerformancePlus clone() => SchwinnACPerformancePlus();

  @override
  bool isDataProcessable(List<int> data) {
    return false;
  }

  @override
  bool isFlagValid(int flag) {
    return false;
  }

  @override
  void processFlag(int flag) {
    final prefService = Get.find<BasePrefService>();
    final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    Logging().log(logLevel, logLevelError, tag, "processFlag", "Not implemented!");
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final prefService = Get.find<BasePrefService>();
    final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    Logging().log(logLevel, logLevelError, tag, "stubRecord", "Not implemented!");
    return null;
  }

  @override
  void stopWorkout() {
    final prefService = Get.find<BasePrefService>();
    final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    Logging().log(logLevel, logLevelError, tag, "stopWorkout", "Not implemented!");
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging().log(logLevel, logLevelError, tag, "executeControlOperation", "Not implemented!");
  }
}
