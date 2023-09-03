import 'dart:collection';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/logging.dart';
import 'cadence_data.dart';

class CadenceMixin {
  static const String mixinTag = "CADENCE_MIXIN";
  static int defaultRevolutionSlidingWindow = 10; // Seconds
  static int defaultEventTimeOverflow = 64; // Overflows every 64 seconds
  static int defaultRevolutionOverflow = maxUint16;

  int revolutionSlidingWindow = defaultRevolutionSlidingWindow;
  int eventTimeOverflow = defaultEventTimeOverflow;
  int revolutionOverflow = defaultRevolutionOverflow;
  int overflowCounter = 0;

  ListQueue<CadenceData> cadenceData = ListQueue<CadenceData>();
  int logLevel = logLevelDefault;

  initCadence([revolutionSlidingWindow, eventTimeOverflow, revolutionOverflow]) {
    this.revolutionSlidingWindow = revolutionSlidingWindow;
    this.eventTimeOverflow = eventTimeOverflow;
    this.revolutionOverflow = revolutionOverflow;

    if (!testing) {
      final prefService = Get.find<BasePrefService>();
      logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    }
  }

  double _getDiffCore(double later, double earlier, int overflow) {
    var diff = later - earlier;
    // Check overflow
    if (diff < 0) {
      diff += overflow;
    }

    return diff;
  }

  double _getTimeDiff(double later, double earlier) {
    return _getDiffCore(later, earlier, eventTimeOverflow);
  }

  double _getRevDiff(double later, double earlier) {
    return _getDiffCore(later, earlier, revolutionOverflow);
  }

  void addCadenceData(double? time, double? revolutions) {
    final nonNullTime = time ?? 0.0;
    final nonNullRevolutions = revolutions ?? 0;
    if (cadenceData.isNotEmpty) {
      // Prevent duplicate recording
      final timeDiff = _getTimeDiff(nonNullTime, cadenceData.last.time);
      final revDiff = _getRevDiff(nonNullRevolutions, cadenceData.last.revolutions);
      if (timeDiff < eps && revDiff < eps) {
        // Update the duplicate's timestamp
        cadenceData.last.timeStamp = DateTime.now();
        return;
      } else {
        if (nonNullRevolutions < cadenceData.last.revolutions) {
          overflowCounter++;
        }
      }
    }

    cadenceData.add(CadenceData(
      time: nonNullTime,
      revolutions: nonNullRevolutions,
    ));

    trimQueue();
  }

  void trimQueue() {
    if (cadenceData.length <= 1) {
      return;
    }

    var timeDiff = _getTimeDiff(cadenceData.last.time, cadenceData.first.time);
    var timeStampDiff =
        cadenceData.last.timeStamp.difference(cadenceData.first.timeStamp).inSeconds -
            sensorDataThreshold / 1000.0;
    while (cadenceData.length > 1 &&
        (timeDiff > revolutionSlidingWindow || timeStampDiff > revolutionSlidingWindow)) {
      cadenceData.removeFirst();
      timeDiff = _getTimeDiff(cadenceData.last.time, cadenceData.first.time);
      timeStampDiff = cadenceData.last.timeStamp.difference(cadenceData.first.timeStamp).inSeconds -
          sensorDataThreshold / 1000.0;
    }
  }

  double computeCadence() {
    if (cadenceData.length <= 1) {
      return 0;
    }

    var firstData = cadenceData.first;
    var lastData = cadenceData.last;
    final timeDiff = _getTimeDiff(lastData.time, firstData.time);
    if (timeDiff < eps) {
      return 0.0;
    }

    final revDiff = _getRevDiff(lastData.revolutions, firstData.revolutions);
    if (logLevel >= logLevelInfo) {
      Logging().log(logLevel, logLevelInfo, mixinTag, "computeCadence",
          "cadenceData $cadenceData, $revDiff * 60 / $timeDiff");
    }

    return revDiff * 60 / timeDiff; // rpm (rev/sec * 60 = rev/min)
  }

  void clearCadenceData() {
    cadenceData.clear();
  }
}
