import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class C2AdditionalStrokeData extends ComplexSensor {
  static const serviceUuid = c2ErgPrimaryServiceUuid;
  static const characteristicUuid = c2ErgAdditionalStrokeDataUuid;

  static const expectedDataPacketLength = 15;
  static const powerLsbByteIndex = 3;

  MetricDescriptor? powerMetric;

  C2AdditionalStrokeData(BluetoothDevice device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = expectedDataPacketLength;

      powerMetric = ShortMetricDescriptor(lsb: powerLsbByteIndex, msb: powerLsbByteIndex + 1);
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
      power: getPower(data)?.toInt(),
      sport: ActivityType.rowing,
    );
  }

  double? getPower(List<int> data) {
    return powerMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    powerMetric = null;
  }
}
