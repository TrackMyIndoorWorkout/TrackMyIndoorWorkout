import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../utils/bluetooth.dart';
import '../../utils/logging.dart';
import '../gatt/ftms.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';

abstract class FitnessMachineDescriptor extends DeviceDescriptor {
  FitnessMachineDescriptor({
    required super.sport,
    required super.isMultiSport,
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    super.dataServiceId,
    super.dataCharacteristicId,
    super.flagByteSize,
    super.heartRateByteIndex,
    super.canMeasureCalories = true,
  }) : super(
          deviceCategory: DeviceCategory.smartDevice,
          tag: "FTMS",
          controlCharacteristicId: fitnessMachineControlPointUuid,
          statusCharacteristicId: fitnessMachineStatusUuid,
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

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    if (!(await isBluetoothOn())) {
      return;
    }

    if (controlPoint == null || blockSignalStartStop) {
      return;
    }

    List<int> requestInfo = [opCode];
    if (controlInfo != null) {
      requestInfo.add(controlInfo);
    }

    try {
      await controlPoint.write(requestInfo);
      // Response could be picked up in the subscription listener
    } on Exception catch (e, stack) {
      Logging().logException(
          logLevel, "FTMS", "executeControlOperation", "controlPoint.write", e, stack);
    }
  }
}
