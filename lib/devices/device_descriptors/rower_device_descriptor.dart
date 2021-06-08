import 'dart:collection';

import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'fitness_machine_descriptor.dart';

class RowerDeviceDescriptor extends FitnessMachineDescriptor {
  ByteMetricDescriptor? strokeRateMetric;
  ShortMetricDescriptor? strokeCountMetric;
  ShortMetricDescriptor? paceMetric;

  late int _strokeRateWindowSize;
  late ListQueue<int> _strokeRates;
  late int _strokeRateSum;

  RowerDeviceDescriptor({
    required defaultSport,
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefix,
    manufacturer,
    manufacturerFitId,
    model,
    dataServiceId = FITNESS_MACHINE_ID,
    dataCharacteristicId = ROWER_DEVICE_ID,
    canMeasureHeartRate = true,
    heartRateByteIndex,
    calorieFactorDefault = 1.0,
    isMultiSport = true,
  }) : super(
          defaultSport: defaultSport,
          isMultiSport: isMultiSport,
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
        ) {
    _strokeRateWindowSize = STROKE_RATE_SMOOTHING_DEFAULT_INT;
    _strokeRates = ListQueue<int>();
    _strokeRateSum = 0;
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rower_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    _strokeRateWindowSize = getStringIntegerPreference(
      STROKE_RATE_SMOOTHING_TAG,
      STROKE_RATE_SMOOTHING_DEFAULT,
      STROKE_RATE_SMOOTHING_DEFAULT_INT,
      null,
    );

    // KayakPro Compact: two flag bytes
    // 44 00101100 (stroke rate, stroke count), total distance, instant pace, instant power
    //  9 00001001 expanded energy, (heart rate), elapsed time
    // negated first bit!
    flag = processStrokeRateFlag(flag, true);
    flag = processAverageStrokeRateFlag(flag);
    flag = processTotalDistanceFlag(flag);
    flag = processPaceFlag(flag); // Instant
    flag = processPaceFlag(flag); // Average (fallback)
    flag = processPowerFlag(flag); // Instant
    flag = processPowerFlag(flag); // Average (fallback)
    flag = processResistanceLevelFlag(flag);
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = processMetabolicEquivalentFlag(flag);
    flag = processElapsedTimeFlag(flag);
    flag = processRemainingTimeFlag(flag);
  }

  @override
  RecordWithSport stubRecord(List<int> data) {
    super.stubRecord(data);

    final pace = getPace(data);

    var strokeRate = getStrokeRate(data);
    if ((strokeRate == null || strokeRate == 0) &&
        (pace == null || pace == 0 || (slowPace != null && pace > slowPace!))) {
      clearStrokeRates();
    }
    if (_strokeRateWindowSize > 1 && strokeRate != null) {
      _strokeRates.add(strokeRate);
      _strokeRateSum += strokeRate;
      if (_strokeRates.length > _strokeRateWindowSize) {
        _strokeRateSum -= _strokeRates.first;
        _strokeRates.removeFirst();
      }
      strokeRate = _strokeRates.length > 0 ? (_strokeRateSum / _strokeRates.length).round() : 0;
    }

    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: getSpeed(data),
      cadence: strokeRate,
      heartRate: getHeartRate(data)?.toInt(),
      pace: pace,
      sport: defaultSport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
    );
  }

  void clearStrokeRates() {
    _strokeRates.clear();
    _strokeRateSum = 0;
  }

  @override
  void stopWorkout() {
    clearStrokeRates();
  }

  int processStrokeRateFlag(int flag, bool negated) {
    if (flag % 2 == (negated ? 0 : 1)) {
      // UByte with 0.5 resolution
      strokeRateMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 2.0);
      byteCounter++;
      strokeCountMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processAverageStrokeRateFlag(int flag) {
    if (flag % 2 == 1) {
      if (strokeRateMetric != null) {
        // UByte with 0.5 resolution
        strokeRateMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 2.0);
      }
      byteCounter++;
    }
    flag ~/= 2;
    return flag;
  }

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, seconds with 1 resolution
      if (paceMetric == null) {
        paceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int? getStrokeRate(List<int> data) {
    return strokeRateMetric?.getMeasurementValue(data)?.toInt();
  }

  double? getPace(List<int> data) {
    var pace = paceMetric?.getMeasurementValue(data);
    if (pace == null || !extendTuning) {
      return pace;
    }
    return pace / powerFactor;
  }

  @override
  void clearMetrics() {
    super.clearMetrics();
    strokeRateMetric = null;
    paceMetric = null;
  }
}
