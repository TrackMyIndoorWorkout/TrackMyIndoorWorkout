import '../../persistence/isar/record.dart';
import '../../utils/constants.dart';
import '../device_descriptors/device_descriptor.dart';
import '../gatt/rsc.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class RunningSpeedAndCadenceSensor extends ComplexSensor {
  static const serviceUuid = runningCadenceServiceUuid;
  static const characteristicUuid = runningCadenceMeasurementUuid;

  // Running cadence metrics
  MetricDescriptor? speedMetric;
  MetricDescriptor? cadenceMetric;
  MetricDescriptor? distanceMetric;

  RunningSpeedAndCadenceSensor(device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = 1; // The flag itself + instant speed and cadence
      // UInt16, m/s with 1/256 resolution -> immediately convert it to km/h with the divider
      speedMetric = ShortMetricDescriptor(
          lsb: expectedLength, msb: expectedLength + 1, divider: 256.0 / DeviceDescriptor.ms2kmh);
      expectedLength += 2;
      cadenceMetric = ByteMetricDescriptor(lsb: expectedLength);
      expectedLength += 1;

      // Has Instantaneous stride length? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in stride length
        expectedLength += 2; // 16 bit uint, 1/100 m
      }

      flag ~/= 2;
      // Has total distance? (second bit)
      if (flag % 2 == 1) {
        // UInt32, 1/10 m
        distanceMetric =
            LongMetricDescriptor(lsb: expectedLength, msb: expectedLength + 3, divider: 10.0);
        expectedLength += 4;
      }

      flag ~/= 2;
    }
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rsc_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.length < 3) return false;

    var flag = data[0];
    // Clear out status bits so status change won't cause metric re-creation
    flag &= 3; // 1 + 2
    processFlag(flag);

    return featureFlag >= 0 && data.length == expectedLength;
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport(sport: ActivityType.run);
    }

    return RecordWithSport(
      timeStamp: DateTime.now(),
      distance: getDistance(data),
      speed: getSpeed(data),
      cadence: getCadence(data)?.toInt(),
      sport: ActivityType.run,
    );
  }

  double? getSpeed(List<int> data) {
    return speedMetric?.getMeasurementValue(data);
  }

  double? getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double? getDistance(List<int> data) {
    return distanceMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    speedMetric = null;
    cadenceMetric = null;
    distanceMetric = null;
  }
}
