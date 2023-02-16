import '../../persistence/isar/record.dart';
import '../../utils/constants.dart';
import '../device_descriptors/device_descriptor.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class C2AdditionalStatus1 extends ComplexSensor {
  static const serviceUuid = c2RowingPrimaryServiceUuid;
  static const characteristicUuid = c2RowingAdditionalStatus1Uuid;

  static const expectedDataPacketLength = 17;
  static const speedLsbByteIndex = 5;
  static const strokeRateByteIndex = 5;
  static const heartRateByteIndex = 6;
  static const paceLsbByteIndex = 5;

  MetricDescriptor? speedMetric;
  MetricDescriptor? paceMetric;

  C2AdditionalStatus1(device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = expectedDataPacketLength;

      speedMetric = ShortMetricDescriptor(
        lsb: speedLsbByteIndex,
        msb: speedLsbByteIndex + 1,
        divider: 1000 * DeviceDescriptor.ms2kmh,
      );
      paceMetric = ShortMetricDescriptor(
        lsb: paceLsbByteIndex,
        msb: paceLsbByteIndex + 1,
        divider: 100.0,
      );
    }
  }

  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    processFlag(0);

    return data.length == expectedDataPacketLength;
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport(sport: ActivityType.rowing);
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      speed: getSpeed(data),
      pace: getPace(data),
      cadence: data[strokeRateByteIndex],
      heartRate: data[heartRateByteIndex],
      sport: ActivityType.rowing,
    );
  }

  double? getSpeed(List<int> data) {
    return speedMetric?.getMeasurementValue(data);
  }

  double? getPace(List<int> data) {
    return paceMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    speedMetric = null;
    paceMetric = null;
  }
}
