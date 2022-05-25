import 'dart:math';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../../utils/power_speed_mixin.dart';
import '../device_fourcc.dart';
import '../gadgets/cadence_mixin.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/six_byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class SchwinnX70 extends FixedLayoutDeviceDescriptor with CadenceMixin, PowerSpeedMixin {
  MetricDescriptor? resistanceMetric;
  // From https://github.com/ursoft/connectivity-samples/blob/main/BluetoothLeGatt/Application/src/main/java/com/example/android/bluetoothlegatt/BluetoothLeService.java
  static const List<double> resistancePowerFactor = [
    0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, // 11-13
    0.75, 0.91, 1.07, // 14-16
    1.23, 1.39, 1.55, // 17-19
    1.72, 1.88, 2.04, // 20-22
    2.20, 2.36, 2.52 // 23-25
  ];
  int lastTime = -1;
  int? lastCalories;
  RecordWithSport? lastRecord;

  SchwinnX70()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: schwinnX70BikeFourCC,
          vendorName: "Schwinn",
          modelName: "SCHWINN 170/270",
          namePrefixes: ["SCHWINN 170", "SCHWINN 270", "SCHWINN 570"],
          manufacturerPrefix: "Nautilus", // "SCHWINN 170/270"
          manufacturerFitId: nautilusFitId,
          model: "",
          dataServiceId: schwinnX70ServiceUuid,
          dataCharacteristicId: schwinnX70MeasurementUuid,
          canMeasureHeartRate: false,
          timeMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 1024.0),
          caloriesMetric: SixByteMetricDescriptor(lsb: 10, msb: 15, divider: 256.0),
          cadenceMetric: ThreeByteMetricDescriptor(lsb: 4, msb: 6, divider: 1.0),
        ) {
    resistanceMetric = ByteMetricDescriptor(lsb: 16);
    initCadence(10, 64, maxUint24);
    initPower2SpeedConstants();
    lastTime = -1;
    lastCalories;
  }

  @override
  SchwinnX70 clone() => SchwinnX70();

  @override
  bool isDataProcessable(List<int> data) {
    if (data.length != 17) return false;

    const measurementPrefix = [17, 32, 0];
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }

    return true;
  }

  @override
  void stopWorkout() {
    clearCadenceData();
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final elapsed = getTime(data);
    final elapsedMillis = ((elapsed ?? 0.0) * 1000.0).toInt();
    final calories = getCalories(data)?.toInt();
    addCadenceData(elapsed, getCadence(data)?.toInt());

    if (lastTime < 0) {
      lastTime = elapsedMillis;
      lastCalories = calories;
      return RecordWithSport.getZero(defaultSport);
    }

    if (elapsedMillis == lastTime) {
      return lastRecord ?? RecordWithSport.getZero(defaultSport);
    }

    final resistance = max((resistanceMetric?.getMeasurementValue(data)?.toInt() ?? 1) - 1, 0);
    final deltaCalories = (calories ?? 0) - (lastCalories ?? 0);
    var deltaTime = elapsedMillis - lastTime;
    if (deltaTime < 0) {
      deltaTime += 64000;
    }

    // Custom way from
    // https://github.com/ursoft/connectivity-samples/blob/main/BluetoothLeGatt/Application/src/main/java/com/example/android/bluetoothlegatt/BluetoothLeService.java
    final power =
        (deltaCalories * 1000.0 / deltaTime * 0.42 * resistancePowerFactor[resistance]).toInt();
    final speed = velocityForPower(power);
    final record = RecordWithSport(
      distance: null,
      elapsed: elapsed?.toInt(),
      calories: calories != null ? calories ~/ 8192 : null,
      power: power,
      speed: speed,
      cadence: computeCadence(),
      heartRate: 0,
      sport: defaultSport,
    )..elapsedMillis = elapsedMillis;
    lastRecord = record;

    return record;
  }
}
