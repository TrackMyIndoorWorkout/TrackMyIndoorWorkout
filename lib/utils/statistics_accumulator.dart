import 'dart:math';

import '../export/export_record.dart';
import '../persistence/models/record.dart';
import 'constants.dart';

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

  late int powerSum;
  late int powerCount;
  late int maxPower;
  late int minPower;
  late double speedSum;
  late int speedCount;
  late double maxSpeed;
  late double minSpeed;
  late int heartRateSum;
  late int heartRateCount;
  late int maxHeartRate;
  late int minHeartRate;
  late int cadenceSum;
  late int cadenceCount;
  late int maxCadence;
  late int minCadence;

  double get avgPower => powerCount > 0 ? powerSum / powerCount : 0.0;
  double get avgSpeed => speedCount > 0 ? speedSum / speedCount : 0.0;
  int get avgCadence => cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0;
  int get avgHeartRate => heartRateCount > 0 ? heartRateSum ~/ heartRateCount : 0;

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
  }) {
    powerSum = 0;
    powerCount = 0;
    maxPower = maxInit;
    minPower = minInit;
    speedSum = 0.0;
    speedCount = 0;
    maxSpeed = maxInit.toDouble();
    minSpeed = minInit.toDouble();
    heartRateSum = 0;
    heartRateCount = 0;
    maxHeartRate = maxInit;
    minHeartRate = minInit;
    cadenceSum = 0;
    cadenceCount = 0;
    maxCadence = maxInit;
    minCadence = minInit;
  }

  processExportRecord(ExportRecord exportRecord) {
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
    }
  }

  processRecord(Record record) {
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
    }
  }
}
