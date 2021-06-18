import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../device_descriptors/device_descriptor.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class RunningCadenceSensor extends ComplexSensor {
  // Running cadence metrics
  ShortMetricDescriptor? speedMetric;
  ByteMetricDescriptor? cadenceMetric;
  LongMetricDescriptor? distanceMetric;
  late double powerFactor;
  late bool extendTuning;
  late Random _random;

  RunningCadenceSensor(device, double powerFactor) : super(RUNNING_CADENCE_SERVICE_ID, RUNNING_CADENCE_MEASUREMENT_ID, device) {
    final prefService = Get.find<BasePrefService>();
    extendTuning = prefService.get<bool>(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
    _random = Random();
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rsc_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.length < 3) return false;

    var flag = data[0];
    // Clear out status bits so status change won't cause metric re-creation
    flag &= 3; // 1 + 2
    if (featureFlag != flag && flag >= 0) {
      var expectedLength = 1; // The flag itself + instant speed and cadence
      // UInt16, m/s with 1/256 resolution -> immediately convert it to km/h with the divider
      speedMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: 256.0 / DeviceDescriptor.MS2KMH);
      expectedLength += 2;
      cadenceMetric = ByteMetricDescriptor(lsb: expectedLength);
      expectedLength += 1;

      // Has Instantaneous stride length? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in strode length
        expectedLength += 2; // 16 bit uint, 1/100 m
      }
      flag ~/= 2;
      // Has total distance? (second bit)
      if (flag % 2 == 1) {
        // UInt32, 1/10 m
        distanceMetric = LongMetricDescriptor(lsb: expectedLength, msb: expectedLength + 3, divider: 10.0);
        expectedLength += 4;
      } else {
        return false;
      }
      featureFlag = flag;

      return data.length == expectedLength;
    }

    return flag > 0;
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) return RecordWithSport.getBlank(ActivityType.Run, uxDebug, _random);

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      distance: getDistance(data),
      speed: getSpeed(data),
      cadence: getCadence(data)?.toInt(),
      sport: ActivityType.Run,
    );
  }

  double? getSpeed(List<int> data) {
    var speed = speedMetric?.getMeasurementValue(data);
    if (speed == null || !extendTuning) {
      return speed;
    }
    return speed * powerFactor;
  }

  double? getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double? getDistance(List<int> data) {
    var distance = distanceMetric?.getMeasurementValue(data);
    if (distance == null || !extendTuning) {
      return distance;
    }
    return distance * powerFactor;
  }

  @override
  void clearMetrics() {
    speedMetric = null;
    cadenceMetric = null;
    distanceMetric = null;
  }
}
