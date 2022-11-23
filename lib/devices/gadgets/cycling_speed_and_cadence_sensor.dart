import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../persistence/models/record.dart';
import '../../preferences/wheel_circumference.dart';
import '../../utils/constants.dart';
import '../gatt/csc.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'cadence_mixin.dart';
import 'complex_sensor.dart';

class CyclingSpeedAndCadenceSensor extends ComplexSensor with CadenceMixin {
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

  double _wheelCircumference = wheelCircumferenceDefault / 1000;

  CyclingSpeedAndCadenceSensor(device) : super(serviceUuid, characteristicUuid, device) {
    initCadence(4, 64, maxUint16);
    wheelCadence = CadenceMixin();
    wheelCadence.initCadence(4, 64, maxUint32);
    final prefService = Get.find<BasePrefService>();
    _wheelCircumference =
        (prefService.get<int>(wheelCircumferenceTag) ?? wheelCircumferenceDefault) / 1000;
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      final prefService = Get.find<BasePrefService>();
      _wheelCircumference =
          (prefService.get<int>(wheelCircumferenceTag) ?? wheelCircumferenceDefault) / 1000;
      clearMetrics();
      featureFlag = flag;
      expectedLength = 1; // The flag itself
      // Has wheel revolution?
      if (flag % 2 == 1) {
        wheelRevolutionMetric = LongMetricDescriptor(lsb: expectedLength, msb: expectedLength + 3);
        expectedLength += 4; // 32 bit revolution
        wheelRevolutionTime =
            ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: 1024.0);
        expectedLength += 2; // 16 bit time
      }

      flag ~/= 2;
      // Has crank revolution?
      if (flag % 2 == 1) {
        crankRevolutionMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit revolution
        crankRevolutionTime =
            ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: 1024.0);
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
      return RecordWithSport(sport: ActivityType.ride);
    }

    double? distance;
    double? speed;
    if (wheelRevolutionMetric != null) {
      wheelCadence.addCadenceData(getWheelRevolutionTime(data), getWheelRevolutions(data));
      distance = wheelCadence.cadenceData.last.revolutions * _wheelCircumference;
      // https://endless-sphere.com/forums/viewtopic.php?t=16114
      // 26" wheel approx cadence at 80mph => 1024.0
      speed = min(wheelCadence.computeCadence(), 1024.0) * 60.0 * _wheelCircumference / 1000.0;
    }

    int? crankCadence;
    if (crankRevolutionMetric != null) {
      addCadenceData(getCrankRevolutionTime(data), getCrankRevolutions(data));
      crankCadence = min(computeCadence().toInt(), maxByte);
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      distance: distance,
      speed: speed,
      cadence: crankCadence?.toInt(),
      sport: ActivityType.ride,
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
