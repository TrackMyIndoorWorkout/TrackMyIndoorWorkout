import '../gatt/wahoo_fitness_equipment.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';

abstract class WahooFitnessEquipmentDescriptor extends DeviceDescriptor {
  WahooFitnessEquipmentDescriptor({
    required sport,
    required isMultiSport,
    required fourCC,
    required vendorName,
    required modelName,
    manufacturerNamePart,
    manufacturerFitId,
    model,
    flagByteSize = 2, // Variable: 1-5
    heartRateByteIndex,
    canMeasureCalories = true,
  }) : super(
          sport: sport,
          isMultiSport: isMultiSport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          manufacturerNamePart: manufacturerNamePart,
          manufacturerFitId: manufacturerFitId,
          model: model,
          deviceCategory: DeviceCategory.smartDevice,
          dataServiceId: wahooFitnessEquipmentServiceUuid,
          dataCharacteristicId: wahooFitnessEquipmentMeasurementUuid,
          statusCharacteristicId: wahooFitnessEquipmentStateUuid,
          flagByteSize: flagByteSize,
          heartRateByteIndex: heartRateByteIndex,
          canMeasureCalories: canMeasureCalories,
        );

  @override
  bool isDataProcessable(List<int> data) {
    if (byteCounter <= flagByteSize) {
      preProcessFlag(data);
    }

    final dataLength = data.length;
    return byteCounter >= flagByteSize &&
        (!hasFutureReservedBytes && dataLength == byteCounter ||
            hasFutureReservedBytes && dataLength >= byteCounter);
  }

  @override
  bool isFlagValid(int flag) {
    return flag >= 0;
  }

  int advanceFlag(int flag) {
    flag ~/= 2;
    return flag;
  }

  int skipFlag(int flag, {int size = 2}) {
    if (flag % 2 == 1) {
      byteCounter += size;
    }

    return advanceFlag(flag);
  }

  int processSpeedFlag(int flag) {
    // Negated first bit!!!
    if (flag % 2 == 0) {
      // UInt16, km/h with 0.01 resolution
      speedMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 100.0);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int processCadenceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, revolutions / minute with 0.5 resolution
      cadenceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 2.0);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int processTotalDistanceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt24, meters
      distanceMetric = ThreeByteMetricDescriptor(lsb: byteCounter, msb: byteCounter + 2);
      byteCounter += 3;
    }

    return advanceFlag(flag);
  }

  int processPowerFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16, Watts
      powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int processExpandedEnergyFlag(int flag, {bool partial = false}) {
    if (flag % 2 == 1) {
      // Total Energy: UInt16
      caloriesMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Energy / hour UInt16
      byteCounter += 2;
      if (!partial) {
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
    }

    return advanceFlag(flag);
  }

  int processHeartRateFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8
      heartRateByteIndex = byteCounter;
      byteCounter++;
    }

    return advanceFlag(flag);
  }

  int processElapsedTimeFlag(int flag) {
    if (flag % 2 == 1) {
      timeMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int processStepMetricsFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, step / minute
      cadenceMetric ??= ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
      // UInt16 average step rate
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }
}
