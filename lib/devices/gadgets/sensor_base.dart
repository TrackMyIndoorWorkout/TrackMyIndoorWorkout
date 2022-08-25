import 'device_base.dart';

abstract class SensorBase extends DeviceBase {
  int featureFlag = -1;
  int expectedLength = 0;
  // Adjusting skewed calories

  SensorBase(serviceId, characteristicId, device)
      : super(
          serviceId: serviceId,
          characteristicId: characteristicId,
          device: device,
        );

  bool canMeasurementProcessed(List<int> data);

  void clearMetrics();
}
