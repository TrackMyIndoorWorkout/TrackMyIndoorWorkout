import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../device_map.dart';
import '../gadgets/cadence_mixin.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/six_byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class SchwinnX70 extends FixedLayoutDeviceDescriptor with CadenceMixin {
  MetricDescriptor? resistanceMetric;

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
    // TODO: convert from revolution to cadence
    // TODO: convert power form calories
    final elapsed = getTime(data);
    final elapsedMillis = ((elapsed ?? 0.0) * 1000.0).toInt();
    final record = RecordWithSport(
      distance: getDistance(data),
      elapsed: elapsed?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: getSpeed(data),
      cadence: computeCadence(),
      // heartRate: getHeartRate(data)?.toInt(),
      sport: defaultSport,
    )..elapsedMillis = elapsedMillis;

    return record;
  }
}
