import 'dart:collection';

import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../persistence/models/record.dart';
import '../../preferences/stroke_rate_smoothing.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'fitness_machine_descriptor.dart';

class RowerDeviceDescriptor extends FitnessMachineDescriptor {
  MetricDescriptor? strokeRateMetric;
  MetricDescriptor? strokeCountMetric;
  MetricDescriptor? paceMetric;

  int _strokeRateWindowSize = strokeRateSmoothingDefault;
  final ListQueue<int> _strokeRates = ListQueue<int>();
  int _strokeRateSum = 0;

  RowerDeviceDescriptor({
    required defaultSport,
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
    dataServiceId = fitnessMachineUuid,
    dataCharacteristicId = rowerDeviceUuid,
    heartRateByteIndex,
    isMultiSport = true,
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
          heartRateByteIndex: heartRateByteIndex,
        );

  @override
  RowerDeviceDescriptor clone() => RowerDeviceDescriptor(
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
        heartRateByteIndex: heartRateByteIndex,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rower_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    final prefService = Get.find<BasePrefService>();
    if (defaultSport == ActivityType.rowing) {
      _strokeRateWindowSize = 0;
    } else {
      _strokeRateWindowSize =
          prefService.get<int>(strokeRateSmoothingIntTag) ?? strokeRateSmoothingDefault;
    }

    // KayakPro Compact
    // 44 0010 1100 (stroke rate, stroke count), total distance, instant pace, instant power
    //  9 0000 1001 expanded energy, (heart rate), elapsed time
    // negated first bit!
    flag = processStrokeRateFlag(flag, true);
    flag = skipFlag(flag, size: 1); // Average Stroke Rate
    flag = processTotalDistanceFlag(flag);
    flag = processPaceFlag(flag);
    flag = skipFlag(flag); // Average Pace
    flag = processPowerFlag(flag);
    flag = skipFlag(flag); // Average Power
    flag = skipFlag(flag); // Resistance Level
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time

    // #320 The Reserved flag is set
    hasFutureReservedBytes = flag > 0;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
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
      strokeRate = _strokeRates.isNotEmpty ? (_strokeRateSum / _strokeRates.length).round() : 0;
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

    return advanceFlag(flag);
  }

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, seconds with 1 resolution
      paceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int? getStrokeRate(List<int> data) {
    return strokeRateMetric?.getMeasurementValue(data)?.toInt();
  }

  double? getPace(List<int> data) {
    return paceMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    super.clearMetrics();
    strokeRateMetric = null;
    paceMetric = null;
  }
}
