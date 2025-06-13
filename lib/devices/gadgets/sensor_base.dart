import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_base.dart';

abstract class SensorBase extends DeviceBase {
  int featureFlag = -1;
  int expectedLength = 0;
  // Adjusting skewed calories

  SensorBase(String serviceId, String characteristicId, BluetoothDevice device)
    : super(serviceId: serviceId, characteristicId: characteristicId, device: device);

  void initFlag() {
    featureFlag = -1;
    expectedLength = 0;
  }

  void processFlag(int flag);

  bool canMeasurementProcessed(List<int> data);

  void clearMetrics();
}
