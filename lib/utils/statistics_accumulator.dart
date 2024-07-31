import 'dart:math';

import '../export/export_record.dart';
import '../persistence/isar/record.dart';
import '../ui/models/display_record.dart';
import 'constants.dart';
import 'streaming_median_calculator.dart';

class StatisticsAccumulator {
  final bool si;
  final String sport;

  bool calculateAvgPower;
  bool calculateMaxPower;
  bool calculateMinPower;
  bool calculateAvgSpeed;
  bool calculateMaxSpeed;
  bool calculateMinSpeed;
  bool calculateAvgCadence;
  bool calculateMaxCadence;
  bool calculateMinCadence;
  bool calculateAvgHeartRate;
  bool calculateMaxHeartRate;
  bool calculateMinHeartRate;
  bool calculateAvgResistance;
  bool calculateMaxResistance;
  bool calculateMinResistance;
  bool calculateMedian;

  late int powerSum;
  late int powerCount;
  late int maxPower;
  late int minPower;
  late StreamingMedianCalculator<int> powerMedianCalc;
  late double speedSum;
  late int speedCount;
  late double maxSpeed;
  late double minSpeed;
  late StreamingMedianCalculator<double> speedMedianCalc;
  late int heartRateSum;
  late int heartRateCount;
  late int maxHeartRate;
  late int minHeartRate;
  late StreamingMedianCalculator<int> heartRateMedianCalc;
  late int cadenceSum;
  late int cadenceCount;
  late int maxCadence;
  late int minCadence;
  late StreamingMedianCalculator<int> cadenceMedianCalc;
  late int resistanceSum;
  late int resistanceCount;
  late int maxResistance;
  late int minResistance;

  double get avgPower => powerCount > 0 ? powerSum / powerCount : 0.0;
  int get maxPowerDisplay => max(maxPower, 0);
  int get minPowerDisplay => min(minPower, 0);
  int get medianPower => powerMedianCalc.median ?? 0;
  double get avgSpeed => speedCount > 0 ? speedSum / speedCount : 0.0;
  double get maxSpeedDisplay => max(maxSpeed, 0.0);
  double get minSpeedDisplay => min(minSpeed, 0.0);
  double get medianSpeed => speedMedianCalc.median ?? 0.0;
  int get avgCadence => cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0;
  int get maxCadenceDisplay => max(maxCadence, 0);
  int get minCadenceDisplay => min(minCadence, 0);
  int get medianCadence => cadenceMedianCalc.median ?? 0;
  int get avgHeartRate => heartRateCount > 0 ? heartRateSum ~/ heartRateCount : 0;
  int get maxHeartRateDisplay => max(maxHeartRate, 0);
  int get minHeartRateDisplay => min(minHeartRate, 0);
  int get medianHeartRate => heartRateMedianCalc.median ?? 0;
  int get avgResistance => resistanceCount > 0 ? resistanceSum ~/ resistanceCount : 0;
  int get maxResistanceDisplay => max(maxResistance, 0);
  int get minResistanceDisplay => min(minResistance, 0);

  StatisticsAccumulator({
    required this.si,
    required this.sport,
    this.calculateAvgPower = false,
    this.calculateMaxPower = false,
    this.calculateMinPower = false,
    this.calculateAvgSpeed = false,
    this.calculateMaxSpeed = false,
    this.calculateMinSpeed = false,
    this.calculateAvgCadence = false,
    this.calculateMaxCadence = false,
    this.calculateMinCadence = false,
    this.calculateAvgHeartRate = false,
    this.calculateMaxHeartRate = false,
    this.calculateMinHeartRate = false,
    this.calculateAvgResistance = false,
    this.calculateMaxResistance = false,
    this.calculateMinResistance = false,
    this.calculateMedian = false,
  }) {
    reset();
  }

  void reset() {
    powerSum = 0;
    powerCount = 0;
    maxPower = maxInit;
    minPower = minInit;
    powerMedianCalc = StreamingMedianCalculator<int>();
    speedSum = 0.0;
    speedCount = 0;
    maxSpeed = maxInit.toDouble();
    minSpeed = minInit.toDouble();
    speedMedianCalc = StreamingMedianCalculator<double>();
    heartRateSum = 0;
    heartRateCount = 0;
    maxHeartRate = maxInit;
    minHeartRate = minInit;
    heartRateMedianCalc = StreamingMedianCalculator<int>();
    cadenceSum = 0;
    cadenceCount = 0;
    maxCadence = maxInit;
    minCadence = minInit;
    cadenceMedianCalc = StreamingMedianCalculator<int>();
    resistanceSum = 0;
    resistanceCount = 0;
    maxResistance = maxInit;
    minResistance = minInit;
  }

  void processExportRecord(ExportRecord exportRecord) {
    if ((exportRecord.record.power ?? 0) > 0) {
      if (calculateAvgPower) {
        powerSum += exportRecord.record.power!;
        powerCount++;
      }

      if (calculateMaxPower) {
        maxPower = max(maxPower, exportRecord.record.power!);
      }

      if (calculateMinPower) {
        minPower = min(minPower, exportRecord.record.power!);
      }

      if (calculateMedian) {
        powerMedianCalc.processElement(exportRecord.record.power!);
      }
    }

    if ((exportRecord.record.speed ?? 0.0) > eps) {
      if (calculateAvgSpeed) {
        speedSum += exportRecord.record.speed!;
        speedCount++;
      }

      if (calculateMaxSpeed) {
        maxSpeed = max(maxSpeed, exportRecord.record.speed!);
      }

      if (calculateMinSpeed) {
        minSpeed = min(minSpeed, exportRecord.record.speed!);
      }

      if (calculateMedian) {
        speedMedianCalc.processElement(exportRecord.record.speed!);
      }
    }

    if ((exportRecord.record.heartRate ?? 0) > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += exportRecord.record.heartRate!;
        heartRateCount++;
      }

      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, exportRecord.record.heartRate!);
      }

      if (calculateMinHeartRate) {
        minHeartRate = min(minHeartRate, exportRecord.record.heartRate!);
      }

      if (calculateMedian) {
        heartRateMedianCalc.processElement(exportRecord.record.heartRate!);
      }
    }

    if ((exportRecord.record.cadence ?? 0) > 0) {
      if (calculateAvgCadence) {
        cadenceSum += exportRecord.record.cadence!;
        cadenceCount++;
      }

      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, exportRecord.record.cadence!);
      }

      if (calculateMinCadence) {
        minCadence = min(minCadence, exportRecord.record.cadence!);
      }

      if (calculateMedian) {
        cadenceMedianCalc.processElement(exportRecord.record.cadence!);
      }
    }

    if ((exportRecord.record.resistance ?? 0) > 0) {
      if (calculateAvgResistance) {
        resistanceSum += exportRecord.record.resistance!;
        resistanceCount++;
      }

      if (calculateMaxResistance) {
        maxResistance = max(maxResistance, exportRecord.record.resistance!);
      }

      if (calculateMinResistance) {
        minResistance = min(minResistance, exportRecord.record.resistance!);
      }
    }
  }

  void processDisplayRecord(DisplayRecord displayRecord) {
    if ((displayRecord.power ?? 0) > 0) {
      if (calculateAvgPower) {
        powerSum += displayRecord.power!;
        powerCount++;
      }

      if (calculateMaxPower) {
        maxPower = max(maxPower, displayRecord.power!);
      }

      if (calculateMinPower) {
        minPower = min(minPower, displayRecord.power!);
      }

      if (calculateMedian) {
        powerMedianCalc.processElement(displayRecord.power!);
      }
    }

    if ((displayRecord.speed ?? 0.0) > eps) {
      if (calculateAvgSpeed) {
        speedSum += displayRecord.speed!;
        speedCount++;
      }

      if (calculateMaxSpeed) {
        maxSpeed = max(maxSpeed, displayRecord.speed!);
      }

      if (calculateMinSpeed) {
        minSpeed = min(minSpeed, displayRecord.speed!);
      }

      if (calculateMedian) {
        speedMedianCalc.processElement(displayRecord.speed!);
      }
    }

    if ((displayRecord.heartRate ?? 0) > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += displayRecord.heartRate!;
        heartRateCount++;
      }

      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, displayRecord.heartRate!);
      }

      if (calculateMinHeartRate) {
        minHeartRate = min(minHeartRate, displayRecord.heartRate!);
      }

      if (calculateMedian) {
        heartRateMedianCalc.processElement(displayRecord.heartRate!);
      }
    }

    if ((displayRecord.cadence ?? 0) > 0) {
      if (calculateAvgCadence) {
        cadenceSum += displayRecord.cadence!;
        cadenceCount++;
      }

      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, displayRecord.cadence!);
      }

      if (calculateMinCadence) {
        minCadence = min(minCadence, displayRecord.cadence!);
      }

      if (calculateMedian) {
        cadenceMedianCalc.processElement(displayRecord.cadence!);
      }
    }

    if ((displayRecord.resistance ?? 0) > 0) {
      if (calculateAvgResistance) {
        resistanceSum += displayRecord.resistance!;
        resistanceCount++;
      }

      if (calculateMaxResistance) {
        maxResistance = max(maxResistance, displayRecord.resistance!);
      }

      if (calculateMinResistance) {
        minResistance = min(minResistance, displayRecord.resistance!);
      }
    }
  }

  void processRecord(Record record) {
    if (record.power != null) {
      if (calculateAvgPower && record.power! > 0) {
        powerSum += record.power!;
        powerCount++;
      }

      if (calculateMaxPower) {
        maxPower = max(maxPower, record.power!);
      }

      if (calculateMinPower) {
        minPower = min(minPower, record.power!);
      }

      if (calculateMedian) {
        powerMedianCalc.processElement(record.power!);
      }
    }

    if (record.speed != null) {
      if (calculateAvgSpeed && record.speed! > 0) {
        speedSum += record.speed!;
        speedCount++;
      }

      if (calculateMaxSpeed) {
        maxSpeed = max(maxSpeed, record.speed!);
      }

      if (calculateMinSpeed) {
        minSpeed = min(minSpeed, record.speed!);
      }

      if (calculateMedian) {
        speedMedianCalc.processElement(record.speed!);
      }
    }

    if (record.heartRate != null && record.heartRate! > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += record.heartRate!;
        heartRateCount++;
      }

      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, record.heartRate!);
      }

      if (calculateMinHeartRate) {
        minHeartRate = min(minHeartRate, record.heartRate!);
      }

      if (calculateMedian) {
        heartRateMedianCalc.processElement(record.heartRate!);
      }
    }

    if (record.cadence != null) {
      if (calculateAvgCadence && record.cadence! > 0) {
        cadenceSum += record.cadence!;
        cadenceCount++;
      }

      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, record.cadence!);
      }

      if (calculateMinCadence) {
        minCadence = min(minCadence, record.cadence!);
      }

      if (calculateMedian) {
        cadenceMedianCalc.processElement(record.cadence!);
      }
    }

    if (record.resistance != null) {
      if (calculateAvgResistance && record.resistance! > 0) {
        resistanceSum += record.resistance!;
        resistanceCount++;
      }

      if (calculateMaxResistance) {
        maxResistance = max(maxResistance, record.resistance!);
      }

      if (calculateMinResistance) {
        minResistance = min(minResistance, record.resistance!);
      }
    }
  }

  DisplayRecord averageDisplayRecord(DateTime? timestamp) {
    return DisplayRecord.forValues(
      sport,
      timestamp,
      avgPower > eps ? avgPower.round() : null,
      avgSpeed > 0 ? avgSpeed : null,
      avgCadence > 0 ? avgCadence : null,
      avgHeartRate > 0 ? avgHeartRate : null,
      avgResistance > 0 ? avgResistance : null,
    );
  }

  DisplayRecord maximumDisplayRecord(DateTime? timestamp) {
    return DisplayRecord.forValues(
      sport,
      timestamp,
      maxPower > 0 ? maxPower : null,
      maxSpeed > 0 ? maxSpeed : null,
      maxCadence > 0 ? maxCadence : null,
      maxHeartRate > 0 ? maxHeartRate : null,
      maxResistance > 0 ? maxResistance : null,
    );
  }
}
