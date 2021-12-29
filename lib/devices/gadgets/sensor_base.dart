import 'device_base.dart';

abstract class SensorBase extends DeviceBase {
  int featureFlag = -1;
  int expectedLength = 0;
  // Adjusting skewed calories

  SensorBase(serviceId, characteristicsId, device)
      : super(
          serviceId: serviceId,
          characteristicsId: characteristicsId,
          device: device,
        );

  bool canMeasurementProcessed(List<int> data);

  void clearMetrics();
}
