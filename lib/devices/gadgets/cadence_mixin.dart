import 'dart:collection';

import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../preferences/log_level.dart';
import '../../preferences/revolution_sliding_window.dart';
import '../../preferences/sensor_data_threshold.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import 'cadence_data.dart';

mixin CadenceMixin {
  static const String mixinTag = "CADENCE_MIXIN";
  static int defaultEventTimeOverflow = 64; // Overflows every 64 seconds
  static int defaultRevolutionOverflow = maxUint16;

  int revolutionSlidingWindow = revolutionSlidingWindowDefault;
  int eventTimeOverflow = defaultEventTimeOverflow;
  int revolutionOverflow = defaultRevolutionOverflow;
  int overflowCounter = 0;

  ListQueue<CadenceData> cadenceData = ListQueue<CadenceData>();
  int logLevel = logLevelDefault;
  int sensorDataThreshold = sensorDataThresholdDefault;

  void initCadence(int eventTimeOverflow, int revolutionOverflow) {
    this.eventTimeOverflow = eventTimeOverflow;
    this.revolutionOverflow = revolutionOverflow;

    if (!testing) {
      final prefService = Get.find<BasePrefService>();
      revolutionSlidingWindow =
          prefService.get<int>(revolutionSlidingWindowTag) ?? revolutionSlidingWindowDefault;
      logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
      sensorDataThreshold =
          prefService.get<int>(sensorDataThresholdTag) ?? sensorDataThresholdDefault;
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
      // Prevent queueing of duplicate or bogus cadence data
      final timeDiff = _getTimeDiff(nonNullTime, cadenceData.last.time);
      final revDiff = _getRevDiff(nonNullRevolutions, cadenceData.last.revolutions);
      if (revDiff < eps) {
        // The revolution count is the same as the recorded
        // values, so there is no reason to record it:
        // Just update last's timestamp with the current time.
        // (Assuming: processing didn't add much time to the recorded time)
        cadenceData.last.timeStamp = DateTime.now();
        if (logLevel >= logLevelInfo) {
          final timeChangeQualifier = timeDiff < eps ? "same" : "new";
          Logging().log(
            logLevel,
            logLevelInfo,
            mixinTag,
            "addCadenceData",
            "Skipping duplicate rev count with $timeChangeQualifier time: revDiff = $revDiff ; timeDiff = $timeDiff",
          );
        }

        return;
      } else {
        if (nonNullRevolutions < cadenceData.last.revolutions) {
          overflowCounter++;
        }
      }
    }

    cadenceData.add(CadenceData(time: nonNullTime, revolutions: nonNullRevolutions));

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
      timeStampDiff =
          cadenceData.last.timeStamp.difference(cadenceData.first.timeStamp).inSeconds -
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
      Logging().log(
        logLevel,
        logLevelInfo,
        mixinTag,
        "computeCadence",
        "cadenceData $cadenceData, $revDiff * 60 / $timeDiff",
      );
    }

    return revDiff * 60 / timeDiff; // rpm (rev/sec * 60 = rev/min)
  }

  void clearCadenceData() {
    cadenceData.clear();
  }
}

class CadenceMixinImpl with CadenceMixin {}
