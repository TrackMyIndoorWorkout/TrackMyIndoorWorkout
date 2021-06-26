import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'fitness_machine_descriptor.dart';

class TreadmillDeviceDescriptor extends FitnessMachineDescriptor {
  ByteMetricDescriptor? paceMetric;

  TreadmillDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefix,
    manufacturer,
    manufacturerFitId,
    model,
    dataServiceId = FITNESS_MACHINE_ID,
    dataCharacteristicId = TREADMILL_ID,
    canMeasureHeartRate = false,
    heartRateByteIndex,
    calorieFactorDefault = 1.0,
  }) : super(
          defaultSport: ActivityType.Run,
          isMultiSport: false,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefix: namePrefix,
          manufacturer: manufacturer,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
          calorieFactorDefault: calorieFactorDefault,
        );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    // negated first bit!
    flag = processSpeedFlag(flag, true); // Instant
    flag = processSpeedFlag(flag, false); // Average (fallback)
    flag = processTotalDistanceFlag(flag);
    flag = processInclinationFlag(flag); // skip Inclination and Ramp Angle
    flag = processElevationGainFlag(flag); // skip + and - Elevation Gain
    flag = processPaceFlag(flag); // Instant
    flag = processPaceFlag(flag); // Average (fallback)
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = processMetabolicEquivalentFlag(flag);
    flag = processElapsedTimeFlag(flag);
    flag = processRemainingTimeFlag(flag);
    flag = processForceAndPowerFlag(flag);
  }

  @override
  RecordWithSport stubRecord(List<int> data) {
    super.stubRecord(data);

    double? speed = getSpeed(data);
    double? pace = getPace(data); // km / minute
    if (speed == null) {
      speed = (pace ?? 0.0) * 60.0; // km / h
    }

    if (pace != null && pace > 0) {
      pace = 1 / pace; // now minutes / km
    }

    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: speed,
      heartRate: getHeartRate(data)?.toInt(),
      pace: pace,
      sport: defaultSport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
    );
  }

  @override
  void stopWorkout() {}

  int processInclinationFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16 Inclination, SInt16 Ramp Angle Setting
      byteCounter += 4;
    }
    flag ~/= 2;
    return flag;
  }

  int processElevationGainFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16 Positive Elevation Gain, UInt16 Negative Elevation Gain
      byteCounter += 4;
    }
    flag ~/= 2;
    return flag;
  }

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, km/min with 0.1 resolution
      if (paceMetric == null) {
        paceMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 10.0);
      }
      byteCounter += 1;
    }
    flag ~/= 2;
    return flag;
  }

  int processForceAndPowerFlag(int flag) {
    if (flag % 2 == 1) {
      byteCounter += 2; // Skip force on belt: SInt16, Newton
      if (powerMetric == null) {
        // SInt16, Watts
        powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  double? getPace(List<int> data) {
    var pace = paceMetric?.getMeasurementValue(data);
    if (pace == null || !extendTuning) {
      return pace;
    }
    // Run pace is not really a pace (speed reciprocal) but it's km/min
    // So we multiply unlike Rowing/Kayaking/Swimming division
    return pace * powerFactor;
  }

  @override
  void clearMetrics() {
    super.clearMetrics();
    paceMetric = null;
  }
}
