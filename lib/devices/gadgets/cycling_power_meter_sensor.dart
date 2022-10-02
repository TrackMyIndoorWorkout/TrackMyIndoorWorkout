import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/long_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'cadence_mixin.dart';
import 'complex_sensor.dart';

class CyclingPowerMeterSensor extends ComplexSensor with CadenceMixin {
  static const serviceUuid = cyclingPowerServiceUuid;
  static const characteristicUuid = cyclingPowerMeasurementUuid;
  static const roadBikeWheelCircumference = 2.105; // m

  MetricDescriptor? powerMetric;
  // Wheel revolution metrics
  // (can correlate to speed if it is a proper speed shifter bike on a trainer
  //  and not a spinning bike (fixed gear/fixie))
  MetricDescriptor? wheelRevolutionMetric;
  MetricDescriptor? wheelRevolutionTime;
  late CadenceMixin wheelCadence;
  // Secondary (Crank cadence) metrics
  MetricDescriptor? crankRevolutionMetric;
  MetricDescriptor? crankRevolutionTime;
  MetricDescriptor? caloriesMetric;

  CyclingPowerMeterSensor(device) : super(serviceUuid, characteristicUuid, device) {
    initCadence(10, 64, maxUint16);
    wheelCadence = CadenceMixin();
    wheelCadence.initCadence(10, 32, maxUint32);
  }

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag > 0) {
      expectedLength = 2; // The flag itself + sint16 mandatory power
      // SInt16, Watts
      powerMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
      expectedLength += 2;

      // Has Pedal Power Balance?
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 1; // uint8
      }
      flag ~/= 4; // We also skip the  Pedal Power Balance Reference flag bit

      // Has Accumulated Torque?
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 2; // uint16
      }
      flag ~/= 4; // We also skip the Accumulated Torque Source flag bit

      // Has wheel revolution?
      if (flag % 2 == 1) {
        wheelRevolutionMetric = LongMetricDescriptor(lsb: expectedLength, msb: expectedLength + 3);
        expectedLength += 4; // 32 bit revolution
        wheelRevolutionTime =
            ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: 2048.0);
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
      // Has Extreme Force Magnitudes
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 4; // 2 * sint16
      }

      flag ~/= 2;
      // Has Extreme Torque Magnitudes
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 4; // 2 * sint16
      }

      flag ~/= 2;
      // Has Extreme Angles
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 3; // 2 * uint12
      }

      flag ~/= 2;
      // Has Top Dead Spot Angle
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 2; // uint16
      }

      flag ~/= 2;
      // Has Bottom Dead Spot Angle
      if (flag % 2 == 1) {
        // Skip it
        expectedLength += 2; // uint16
      }

      flag ~/= 2;
      // Has Accumulated Energy
      if (flag % 2 == 1) {
        caloriesMetric = ShortMetricDescriptor(
            lsb: expectedLength, msb: expectedLength + 1, divider: 1 / jToCal);
        expectedLength += 2; // uint16
      }

      flag ~/= 2;
      // Offset Compensation Indicator ???
      featureFlag = flag;
    }
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cycling_power_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    var flag = data[0] + maxUint8 * data[1];
    processFlag(flag);

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
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: speed,
      cadence: crankCadence,
      sport: ActivityType.ride,
    );
  }

  double? getCalories(List<int> data) {
    return caloriesMetric?.getMeasurementValue(data);
  }

  double? getPower(List<int> data) {
    return powerMetric?.getMeasurementValue(data);
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
    caloriesMetric = null;
    powerMetric = null;
    wheelRevolutionMetric = null;
    wheelRevolutionTime = null;
    wheelCadence.clearCadenceData();
    crankRevolutionMetric = null;
    crankRevolutionTime = null;
    clearCadenceData();
  }
}
