import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';

abstract class FitnessMachineDescriptor extends DeviceDescriptor {
  FitnessMachineDescriptor({
    required defaultSport,
    required isMultiSport,
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
    dataServiceId,
    dataCharacteristicId,
    flagByteSize = 2,
    canMeasureHeartRate = true,
    heartRateByteIndex,
    canMeasureCalories = true,
  }) : super(
          defaultSport: defaultSport,
          isMultiSport: isMultiSport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerPrefix: manufacturerPrefix,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          flagByteSize: flagByteSize,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
          canMeasureCalories: canMeasureCalories,
        );

  @override
  bool canDataProcessed(List<int> data) {
    final dataLength = data.length;
    if (byteCounter <= 0) {
      preProcessFlag(data);
    }

    return byteCounter > 2 ? dataLength == byteCounter : dataLength > 2;
  }

  int processSpeedFlag(int flag, bool negated) {
    if (flag % 2 == (negated ? 0 : 1)) {
      // UInt16, km/h with 0.01 resolution
      speedMetric ??= ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 100.0);
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processCadenceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, revolutions / minute with 0.5 resolution
      cadenceMetric ??= ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 2.0);
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processTotalDistanceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt24, meters
      distanceMetric = ThreeByteMetricDescriptor(lsb: byteCounter, msb: byteCounter + 2);
      byteCounter += 3;
    }

    flag ~/= 2;
    return flag;
  }

  int processResistanceLevelFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16 (resolution of 1 for bikes, 0.1 for cross trainer)
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processPowerFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16, Watts
      powerMetric ??= ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processExpandedEnergyFlag(int flag) {
    if (flag % 2 == 1) {
      // Total Energy: UInt16
      caloriesMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Energy / hour UInt16
      byteCounter += 2;
      caloriesPerHourMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Energy / minute UInt8
      byteCounter += 2;
      caloriesPerMinuteMetric = ByteMetricDescriptor(
        lsb: byteCounter,
        optional: true,
      );
      byteCounter++;
    }

    flag ~/= 2;
    return flag;
  }

  int processHeartRateFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8
      heartRateByteIndex = byteCounter;
      byteCounter++;
    }

    flag ~/= 2;
    return flag;
  }

  int processMetabolicEquivalentFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8
      byteCounter++;
    }

    flag ~/= 2;
    return flag;
  }

  int processElapsedTimeFlag(int flag) {
    if (flag % 2 == 1) {
      timeMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processRemainingTimeFlag(int flag) {
    if (flag % 2 == 1) {
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processStepMetricsFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, step / minute
      cadenceMetric ??= ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
      // UInt16 average step rate
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processStrideCountFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, 0.1 resolution
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processElevationGainMetricsFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16 positive elevation gain
      byteCounter += 2;
      // UInt16 negative elevation gain
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }

  int processInclinationAndRampAngleFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16 inclination: percent w 0.1 resolution
      byteCounter += 2;
      // SInt16 ramp angle: degree w 0.1 resolution
      byteCounter += 2;
    }

    flag ~/= 2;
    return flag;
  }
}
