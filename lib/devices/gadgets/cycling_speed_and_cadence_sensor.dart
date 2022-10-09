import '../../persistence/models/record.dart';
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

  CyclingSpeedAndCadenceSensor(device) : super(serviceUuid, characteristicUuid, device) {
    initCadence(10, 64, maxUint16);
    wheelCadence = CadenceMixin();
    wheelCadence.initCadence(10, 64, maxUint32);
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
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
      distance = wheelCadence.cadenceData.last.revolutions * roadBikeWheelCircumference;
      speed = wheelCadence.computeCadence() * 60 * roadBikeWheelCircumference / 1000.0;
    }

    double? crankCadence;
    if (crankRevolutionMetric != null) {
      addCadenceData(getCrankRevolutionTime(data), getCrankRevolutions(data));
      crankCadence = computeCadence();
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      distance: distance,
      speed: speed,
      cadence: crankCadence?.toInt(),
      sport: ActivityType.ride,
    );
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
