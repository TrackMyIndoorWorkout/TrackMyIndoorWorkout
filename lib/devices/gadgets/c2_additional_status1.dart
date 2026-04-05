import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../device_descriptors/device_descriptor.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class C2AdditionalStatus1 extends ComplexSensor {
  static const serviceUuid = c2ErgPrimaryServiceUuid;
  static const characteristicUuid = c2ErgAdditionalStatus1Uuid;

  static const expectedDataPacketLength = 17;
  static const speedLsbByteIndex = 3;
  static const strokeRateByteIndex = 5;
  static const heartRateByteIndex = 6;
  static const paceLsbByteIndex = 7;

  MetricDescriptor? speedMetric;
  MetricDescriptor? paceMetric;

  C2AdditionalStatus1(BluetoothDevice device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = expectedDataPacketLength;

      speedMetric = ShortMetricDescriptor(
        lsb: speedLsbByteIndex,
        msb: speedLsbByteIndex + 1,
        divider: 1000 * DeviceDescriptor.kmh2ms,
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

    final hr = data[heartRateByteIndex];
    return RecordWithSport(
      timeStamp: DateTime.now(),
      speed: getSpeed(data),
      pace: getPace(data),
      cadence: data[strokeRateByteIndex],
      heartRate: hr < 255 && hr > 0 ? hr : null,
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
