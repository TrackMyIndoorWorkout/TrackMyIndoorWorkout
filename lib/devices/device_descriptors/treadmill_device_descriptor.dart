import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/isar/record.dart';
import '../../utils/guid_ex.dart';
import '../device_fourcc.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/running_speed_and_cadence_sensor.dart';
import '../gatt/ftms.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'fitness_machine_descriptor.dart';

class TreadmillDeviceDescriptor extends FitnessMachineDescriptor {
  MetricDescriptor? paceMetric;

  TreadmillDeviceDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    super.heartRateByteIndex,
    super.doNotReadManufacturerName,
  }) : super(
          sport: deviceSportDescriptors[genericFTMSTreadmillFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[genericFTMSTreadmillFourCC]!.isMultiSport,
          dataServiceId: fitnessMachineUuid,
          dataCharacteristicId: treadmillUuid,
        );

  @override
  TreadmillDeviceDescriptor clone() => TreadmillDeviceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
        heartRateByteIndex: heartRateByteIndex,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    // negated first bit!
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag, size: 4); // Inclination and Ramp Angle
    flag = skipFlag(flag, size: 4); // Positive and Negative Elevation Gain
    flag = processPaceFlag(flag);
    flag = skipFlag(flag, size: 1); // Average Pace
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time
    flag = processForceAndPowerFlag(flag);

    // #320 The Reserved flag is set
    hasFutureReservedBytes = flag > 0;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    double? speed = getSpeed(data);
    double? pace = getPace(data); // km / minute
    // Run pace is not really a pace (speed reciprocal) but it's km/min
    if (pace != null && pace > 0) {
      speed ??= pace * 60.0; // km/min -> km / h
      pace = 1 / pace; // now minutes / km
    }

    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: speed,
      heartRate: getHeartRate(data),
      pace: pace,
      sport: sport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
      resistance: getResistance(data)?.toInt(),
    );
  }

  @override
  void stopWorkout() {}

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    final rscService = services.firstWhereOrNull(
        (service) => service.serviceUuid.uuidString() == RunningSpeedAndCadenceSensor.serviceUuid);
    if (rscService == null) {
      return [];
    }

    final additionalSensor = RunningSpeedAndCadenceSensor(device);
    additionalSensor.services = services;
    return [additionalSensor];
  }

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8, km/min with 0.1 resolution
      paceMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 10.0);
      byteCounter++;
    }

    return advanceFlag(flag);
  }

  int processForceAndPowerFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16, Newton
      resistanceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
      // SInt16, Watts
      powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  double? getPace(List<int> data) {
    // Run pace is not really a pace (speed reciprocal) but it's km/min
    return paceMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    super.clearMetrics();
    paceMetric = null;
  }
}
