import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../preferences/log_level.dart';
import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import '../device_fourcc.dart';
import 'device_descriptor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  static const double extraCalorieFactor = 3.9;

  SchwinnACPerformancePlus()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: schwinnACPerfPlusFourCC,
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          namePrefixes: ["Schwinn AC Perf+"],
          manufacturerPrefix: "Schwinn",
          manufacturerFitId: stravaFitId,
          model: "Schwinn AC Perf+",
          antPlus: true,
          canMeasureCalories: true, // #258 avoid over inflation
        );

  @override
  SchwinnACPerformancePlus clone() => SchwinnACPerformancePlus();

  @override
  bool isDataProcessable(List<int> data) {
    return false;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final prefService = Get.find<BasePrefService>();
    final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    Logging.log(
      logLevel,
      logLevelError,
      "Schwinn AC Perf+",
      "stubRecord",
      "Not implemented!",
    );
    debugPrint("Schwinn AC Perf+ stubRecord Not implemented!");
    return null;
  }

  @override
  void stopWorkout() {
    final prefService = Get.find<BasePrefService>();
    final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    Logging.log(
      logLevel,
      logLevelError,
      "Schwinn AC Perf+",
      "stopWorkout",
      "Not implemented!",
    );
    debugPrint("Schwinn AC Perf+ stopWorkout Not implemented!");
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging.log(
      logLevel,
      logLevelError,
      "Schwinn AC Perf+",
      "executeControlOperation",
      "Not implemented!",
    );
    debugPrint("Schwinn AC Perf+ executeControlOperation Not implemented!");
  }
}
