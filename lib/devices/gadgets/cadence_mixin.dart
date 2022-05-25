import 'dart:collection';

import '../../utils/constants.dart';
import 'cadence_data.dart';

class CadenceMixin {
  int revolutionSlidingWindow = 10; // Seconds
  int eventTimeOverflow = 64; // Overflows every 64 seconds
  int revolutionOverflow = maxUint16;

  ListQueue<CadenceData> cadenceData = ListQueue<CadenceData>();

  initCadence([revolutionSlidingWindow, eventTimeOverflow, revolutionOverflow]) {
    this.revolutionSlidingWindow = revolutionSlidingWindow;
    this.eventTimeOverflow = eventTimeOverflow;
    this.revolutionOverflow = revolutionOverflow;
  }

  void addCadenceData(double? time, int? revolutions) {
    final nonNullTime = time ?? 0.0;
    final nonNullRevolutions = revolutions ?? 0;
    if (cadenceData.isNotEmpty) {
      // Prevent duplicate recording
      final last = cadenceData.last;
      if ((last.time - nonNullTime).abs() < eps && last.revolutions == nonNullRevolutions) {
        return;
      }
    }

    cadenceData.add(CadenceData(
      time: nonNullTime,
      revolutions: nonNullRevolutions,
    ));

    processData();
  }

  void processData() {
    if (cadenceData.length <= 1) {
      return;
    }

    var firstData = cadenceData.first;
    var lastData = cadenceData.last;
    var revDiff = lastData.revolutions - firstData.revolutions;
    // Check overflow
    if (revDiff < 0) {
      revDiff += revolutionOverflow;
    }

    var secondsDiff = lastData.time - firstData.time;
    // Check overflow
    if (secondsDiff < 0) {
      secondsDiff += eventTimeOverflow;
    }

    while (secondsDiff > revolutionSlidingWindow && cadenceData.length > 2) {
      cadenceData.removeFirst();
      secondsDiff = cadenceData.last.time - cadenceData.first.time;
      // Check overflow
      if (secondsDiff < 0) {
        secondsDiff += eventTimeOverflow;
      }
    }
  }

  int computeCadence() {
    if (cadenceData.length <= 1) {
      return 0;
    }

    final firstData = cadenceData.first;
    final lastData = cadenceData.last;
    if ((lastData.time - firstData.time).abs() < displayEps) {
      return 0;
    }

    var secondsDiff = lastData.time - firstData.time;
    // Check overflow
    if (secondsDiff < 0) {
      secondsDiff += eventTimeOverflow;
    }

    return (lastData.revolutions - firstData.revolutions) * 60 ~/ secondsDiff;
  }

  void clearCadenceData() {
    cadenceData.clear();
  }
}
