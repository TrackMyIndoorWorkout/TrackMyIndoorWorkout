import 'dart:math';

import '../persistence/models/record.dart';
import '../tcx/tcx_model.dart';

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

  double powerSum;
  int powerCount;
  double maxPower;
  double speedSum;
  int speedCount;
  double maxSpeed;
  int heartRateSum;
  int heartRateCount;
  int maxHeartRate;
  int cadenceSum;
  int cadenceCount;
  int maxCadence;

  double get avgPower => powerCount > 0 ? powerSum / powerCount : 0;
  double get avgSpeed => speedCount > 0 ? speedSum / speedCount : 0;
  int get avgCadence => cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0;
  int get avgHeartRate => heartRateCount > 0 ? heartRateSum ~/ heartRateCount : 0;

  StatisticsAccumulator({
    this.si,
    this.sport,
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
      maxPower = 0;
    }
    if (calculateAvgSpeed) {
      speedSum = 0;
      speedCount = 0;
    }
    if (calculateMaxSpeed) {
      maxSpeed = 0;
    }
    if (calculateAvgHeartRate) {
      heartRateSum = 0;
      heartRateCount = 0;
    }
    if (calculateMaxHeartRate) {
      maxHeartRate = 0;
    }
    if (calculateAvgCadence) {
      cadenceSum = 0;
      cadenceCount = 0;
    }
    if (calculateMaxCadence) {
      maxCadence = 0;
    }
  }

  processTrackPoint(TrackPoint trackPoint) {
    if (trackPoint.power != null) {
      if (calculateAvgPower) {
        powerSum += trackPoint.power;
        powerCount++;
      }
      if (calculateMaxPower) {
        maxPower = max(maxPower, trackPoint.power);
      }
    }
    if (trackPoint.speed != null) {
      if (calculateAvgSpeed) {
        speedSum += trackPoint.speed;
        speedCount++;
      }
      if (calculateMaxSpeed) {
        maxSpeed = max(maxSpeed, trackPoint.speed);
      }
    }
    if (trackPoint.heartRate != null && trackPoint.heartRate > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += trackPoint.heartRate;
        heartRateCount++;
      }
      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, trackPoint.heartRate);
      }
    }
    if (trackPoint.cadence != null && trackPoint.cadence > 0) {
      if (calculateAvgCadence) {
        cadenceSum += trackPoint.cadence;
        cadenceCount++;
      }
      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, trackPoint.cadence);
      }
    }
  }

  processRecord(Record record) {
    if (record.power != null) {
      if (calculateAvgPower) {
        powerSum += record.power;
        powerCount++;
      }
      if (calculateMaxPower) {
        maxPower = max(maxPower, record.power.toDouble());
      }
    }
    if (record.speed != null) {
      final speed = record.speedByUnit(si, sport);
      if (calculateAvgSpeed) {
        speedSum += speed;
        speedCount++;
      }
      if (calculateMaxSpeed) {
        maxSpeed = max(maxSpeed, speed);
      }
    }
    if (record.heartRate != null && record.heartRate > 0) {
      if (calculateAvgHeartRate) {
        heartRateSum += record.heartRate;
        heartRateCount++;
      }
      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, record.heartRate);
      }
    }
    if (record.cadence != null && record.cadence > 0) {
      if (calculateAvgCadence) {
        cadenceSum += record.cadence;
        cadenceCount++;
      }
      if (calculateMaxCadence) {
        maxCadence = max(maxCadence, record.cadence);
      }
    }
  }
}
