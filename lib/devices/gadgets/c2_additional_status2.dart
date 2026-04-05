import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class C2AdditionalStatus2 extends ComplexSensor {
  static const serviceUuid = c2ErgPrimaryServiceUuid;
  static const characteristicUuid = c2ErgAdditionalStatus2Uuid;

  static const expectedDataPacketLength = 20;
  static const caloriesLsbByteIndex = 6;

  MetricDescriptor? caloriesMetric;

  C2AdditionalStatus2(BluetoothDevice device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = expectedDataPacketLength;

      caloriesMetric = ShortMetricDescriptor(
        lsb: caloriesLsbByteIndex,
        msb: caloriesLsbByteIndex + 1,
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
      timeStamp: DateTime.now(),
      calories: getCalories(data)?.toInt(),
      sport: ActivityType.rowing,
    );
  }

  double? getCalories(List<int> data) {
    return caloriesMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    caloriesMetric = null;
  }
}
