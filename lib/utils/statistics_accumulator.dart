import 'dart:math';

import '../export/export_record.dart';
import '../persistence/models/record.dart';
import 'constants.dart';

class StatisticsAccumulator {
  final bool si;
  final String sport;

  bool calculateAvgPower;
  bool calculateMaxPower;
  bool calculateAvgSpeed;
  bool calculateMaxSpeed;
  bool calculateAvgCadence;
  bool calculateMaxCadence;
  bool calculateAvgHeartRate;
  bool calculateMaxHeartRate;

  late double powerSum;
  late int powerCount;
  late double maxPower;
  late double speedSum;
  late int speedCount;
  late double maxSpeed;
  late int heartRateSum;
  late int heartRateCount;
  late int maxHeartRate;
  late int cadenceSum;
  late int cadenceCount;
  late int maxCadence;

  double get avgPower => powerCount > 0 ? powerSum / powerCount : 0;
  double get avgSpeed => speedCount > 0 ? speedSum / speedCount : 0;
  int get avgCadence => cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0;
  int get avgHeartRate => heartRateCount > 0 ? heartRateSum ~/ heartRateCount : 0;

  StatisticsAccumulator({
    required this.si,
    required this.sport,
    this.calculateAvgPower = false,
    this.calculateMaxPower = false,
    this.calculateAvgSpeed = false,
    this.calculateMaxSpeed = false,
    this.calculateAvgCadence = false,
    this.calculateMaxCadence = false,
    this.calculateAvgHeartRate = false,
    this.calculateMaxHeartRate = false,
  }) {
    if (calculateAvgPower) {
      powerSum = 0;
      powerCount = 0;
    }

    if (calculateMaxPower) {
      maxPower = MAX_INIT.toDouble();
    }

    if (calculateAvgSpeed) {
      speedSum = 0;
      speedCount = 0;
    }

    if (calculateMaxSpeed) {
      maxSpeed = sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble();
    }

    if (calculateAvgHeartRate) {
      heartRateSum = 0;
      heartRateCount = 0;
    }

    if (calculateMaxHeartRate) {
      maxHeartRate = MAX_INIT;
    }

    if (calculateAvgCadence) {
      cadenceSum = 0;
      cadenceCount = 0;
    }

    if (calculateMaxCadence) {
      maxCadence = MAX_INIT;
    }
  }

  processExportRecord(ExportRecord exportRecord) {
    if (exportRecord.power != null && exportRecord.power! > 0) {
      if (calculateAvgPower) {
        powerSum += exportRecord.power!;
        powerCount++;
      }

      if (calculateMaxPower) {
        maxPower = max(maxPower, exportRecord.power!);
      }
    }

    if (exportRecord.speed > 0) {
      if (calculateAvgSpeed) {
        speedSum += exportRecord.speed;
        speedCount++;
      }

      if (calculateMaxSpeed) {
        if (sport == ActivityType.Ride) {
          maxSpeed = max(maxSpeed, exportRecord.speed);
        } else {
          maxSpeed = min(maxSpeed, exportRecord.speed);
        }
      }
    }

    if (exportRecord.heartRate != null && exportRecord.heartRate! > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += exportRecord.heartRate!;
        heartRateCount++;
      }

      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, exportRecord.heartRate!);
      }
    }

    if (exportRecord.cadence != null && exportRecord.cadence! > 0) {
      if (calculateAvgCadence) {
        cadenceSum += exportRecord.cadence!;
        cadenceCount++;
      }
      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, exportRecord.cadence!);
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
        maxPower = max(maxPower, record.power!.toDouble());
      }
    }

    if (record.speed != null) {
      final speed = record.speedByUnit(si, sport);
      if (calculateAvgSpeed && record.speed! > 0) {
        speedSum += speed;
        speedCount++;
      }

      if (calculateMaxSpeed) {
        if (sport == ActivityType.Ride) {
          maxSpeed = max(maxSpeed, speed);
        } else {
          maxSpeed = min(maxSpeed, speed);
        }
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
    }

    if (record.cadence != null) {
      if (calculateAvgCadence && record.cadence! > 0) {
        cadenceSum += record.cadence!;
        cadenceCount++;
      }
      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, record.cadence!);
      }
    }
  }
}
