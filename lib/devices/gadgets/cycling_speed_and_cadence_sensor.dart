import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../gatt/csc.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'cadence_mixin.dart';
import 'flywheel_sensor_base.dart';

class CyclingSpeedAndCadenceSensor extends FlywheelSensorBase with CadenceMixin {
  static const serviceUuid = cyclingCadenceServiceUuid;
  static const characteristicUuid = cyclingCadenceMeasurementUuid;

  // Wheel revolution metrics
  // (can correlate to speed if it is a proper speed shifter bike on a trainer
  //  and not a spinning bike (fixed gear/fixie))
  MetricDescriptor? wheelRevolutionMetric;
  MetricDescriptor? wheelRevolutionTime;
  late CadenceMixin wheelCadence;
  // Secondary (Crank cadence) metrics
  MetricDescriptor? crankRevolutionMetric;
  MetricDescriptor? crankRevolutionTime;

  CyclingSpeedAndCadenceSensor(BluetoothDevice device)
    : super(serviceUuid, characteristicUuid, device) {
    initCadence(64, maxUint16);
    wheelCadence = CadenceMixinImpl();
    wheelCadence.initCadence(64, maxUint32);
    readCircumference();
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      readCircumference();
      clearMetrics();
      featureFlag = flag;
      expectedLength = 1; // The flag itself
      // Has wheel revolution?
      if (flag % 2 == 1) {
        wheelRevolutionMetric = LongMetricDescriptor(lsb: expectedLength, msb: expectedLength + 3);
        expectedLength += 4; // 32 bit revolution
        wheelRevolutionTime = ShortMetricDescriptor(
          lsb: expectedLength,
          msb: expectedLength + 1,
          divider: 1024.0,
        );
        expectedLength += 2; // 16 bit time
      }

      flag ~/= 2;
      // Has crank revolution?
      if (flag % 2 == 1) {
        crankRevolutionMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit revolution
        crankRevolutionTime = ShortMetricDescriptor(
          lsb: expectedLength,
          msb: expectedLength + 1,
          divider: 1024.0,
        );
        expectedLength += 2; // 16 bit time
      }

      flag ~/= 2;
    }
  }

  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    processFlag(data[0]);

    return featureFlag >= 0 && data.length == expectedLength;
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport(sport: sport);
    }

    double? distance;
    double? speed;
    if (wheelRevolutionMetric != null) {
      wheelCadence.addCadenceData(getWheelRevolutionTime(data), getWheelRevolutions(data));
      distance =
          (wheelCadence.overflowCounter * wheelCadence.revolutionOverflow +
              wheelCadence.cadenceData.last.revolutions) *
          circumference;
      // https://endless-sphere.com/forums/viewtopic.php?t=16114
      // 26" wheel approx cadence at 80mph => 1024.0
      // Unit: rpm * 60 = rph (rotations / minute * 60 = rotations / hour)
      //       rph * m / 1000 = rph * km = kmh
      speed = min(wheelCadence.computeCadence(), 1024.0) * 60.0 * circumference / 1000.0;
    }

    double? crankCadence;
    if (crankRevolutionMetric != null) {
      addCadenceData(getCrankRevolutionTime(data), getCrankRevolutions(data));
      crankCadence = min(computeCadence(), maxByte * 2.0);
    }

    return RecordWithSport(
      timeStamp: DateTime.now(),
      distance: distance,
      speed: speed,
      cadence: crankCadence?.toInt(),
      preciseCadence: crankCadence,
      strokeCount: getCrankRevolutions(data),
      sport: sport,
    );
  }

  @override
  void trimQueues() {
    trimQueue();
    wheelCadence.trimQueue();
  }

  double? getWheelRevolutions(List<int> data) {
    return wheelRevolutionMetric?.getMeasurementValue(data);
  }

  double? getWheelRevolutionTime(List<int> data) {
    return wheelRevolutionTime?.getMeasurementValue(data);
  }

  double? getCrankRevolutions(List<int> data) {
    return crankRevolutionMetric?.getMeasurementValue(data);
  }

  double? getCrankRevolutionTime(List<int> data) {
    return crankRevolutionTime?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    wheelRevolutionMetric = null;
    wheelRevolutionTime = null;
    wheelCadence.clearCadenceData();
    crankRevolutionMetric = null;
    crankRevolutionTime = null;
    clearCadenceData();
  }
}
