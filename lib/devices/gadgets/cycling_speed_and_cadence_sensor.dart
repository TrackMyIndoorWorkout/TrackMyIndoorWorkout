import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'cadence_mixin.dart';
import 'complex_sensor.dart';

class CyclingSpeedAndCadenceSensor extends ComplexSensor with CadenceMixin {
  static const roadBikeWheelCircumference = 2.105; // m
  // Wheel revolution metrics
  // (can correlate to speed if it is a proper speed shifter bike on a trainer
  //  and not a spinning bike (fixed gear/fixie))
  MetricDescriptor? wheelRevolutionMetric;
  MetricDescriptor? wheelRevolutionTime;
  late CadenceMixin wheelCadence;
  // Secondary (Crank cadence) metrics
  MetricDescriptor? crankRevolutionMetric;
  MetricDescriptor? crankRevolutionTime;

  CyclingSpeedAndCadenceSensor(device)
      : super(
          cyclingCadenceServiceUuid,
          cyclingCadenceMeasurementUuid,
          device,
        ) {
    initCadence(10, 64, maxUint16);
    wheelCadence = CadenceMixin();
    wheelCadence.initCadence(10, 64, maxUint32);
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    var flag = data[0];
    if (featureFlag != flag && flag > 0) {
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
      featureFlag = flag;

      return data.length == expectedLength;
    }

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
      distance = wheelCadence.cadenceData.last.revolutions * roadBikeWheelCircumference;
      wheelCadence.processData();
      speed = wheelCadence.computeCadence() * 60 * roadBikeWheelCircumference / 1000.0;
    }

    int? crankCadence;
    if (crankRevolutionMetric != null) {
      addCadenceData(getCrankRevolutionTime(data), getCrankRevolutions(data));
      processData();
      crankCadence = computeCadence();
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      distance: distance,
      speed: speed,
      cadence: crankCadence,
      sport: ActivityType.ride,
    );
  }

  int? getWheelRevolutions(List<int> data) {
    return wheelRevolutionMetric?.getMeasurementValue(data)?.toInt();
  }

  double? getWheelRevolutionTime(List<int> data) {
    return wheelRevolutionTime?.getMeasurementValue(data);
  }

  int? getCrankRevolutions(List<int> data) {
    return crankRevolutionMetric?.getMeasurementValue(data)?.toInt();
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