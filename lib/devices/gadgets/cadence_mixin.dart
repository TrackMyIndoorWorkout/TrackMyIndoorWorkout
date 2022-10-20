import 'dart:collection';

import '../../utils/constants.dart';
import 'cadence_data.dart';

class CadenceMixin {
  static int defaultRevolutionSlidingWindow = 10; // Seconds
  static int defaultEventTimeOverflow = 64; // Overflows every 64 seconds
  static int defaultRevolutionOverflow = maxUint16;

  int revolutionSlidingWindow = defaultRevolutionSlidingWindow;
  int eventTimeOverflow = defaultEventTimeOverflow;
  int revolutionOverflow = defaultRevolutionOverflow;

  ListQueue<CadenceData> cadenceData = ListQueue<CadenceData>();

  initCadence([revolutionSlidingWindow, eventTimeOverflow, revolutionOverflow]) {
    this.revolutionSlidingWindow = revolutionSlidingWindow;
    this.eventTimeOverflow = eventTimeOverflow;
    this.revolutionOverflow = revolutionOverflow;
  }

  double _getDiffCore(double last, double first, int overflow) {
    var diff = last - first;
    // Check overflow
    if (diff < 0) {
      diff += overflow;
    }

    return diff;
  }

  double _getTimeDiff(double last, double first) {
    return _getDiffCore(last, first, eventTimeOverflow);
  }

  double _getRevDiff(double last, double first) {
    return _getDiffCore(last, first, revolutionOverflow);
  }

  void addCadenceData(double? time, double? revolutions) {
    final nonNullTime = time ?? 0.0;
    final nonNullRevolutions = revolutions ?? 0;
    if (cadenceData.isNotEmpty) {
      // Prevent duplicate recording
      final timeDiff = _getTimeDiff(cadenceData.last.time, nonNullTime);
      final revDiff = _getRevDiff(cadenceData.last.revolutions, nonNullRevolutions);
      if (timeDiff < eps && revDiff < eps) {
        return;
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
    while (timeDiff > revolutionSlidingWindow && cadenceData.length > 2) {
      cadenceData.removeFirst();
      timeDiff = _getTimeDiff(cadenceData.last.time, cadenceData.first.time);
    }
  }

  double computeCadence() {
    if (cadenceData.length <= 1) {
      return 0;
    }

    var firstData = cadenceData.first;
    var lastData = cadenceData.last;
    final timeDiff = _getTimeDiff(lastData.time, firstData.time);
    final revDiff = _getRevDiff(lastData.revolutions, firstData.revolutions);
    return timeDiff < eps ? 0.0 : revDiff * 60 / timeDiff;
  }

  void clearCadenceData() {
    cadenceData.clear();
  }
}
