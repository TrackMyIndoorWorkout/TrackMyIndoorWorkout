import 'package:get/get.dart';

import 'device_base.dart';
import 'fitness_equipment.dart';

abstract class SensorBase extends DeviceBase {
  int featureFlag = -1;
  int expectedLength = 0;
  // Adjusting skewed calories
  double calorieFactorDefault = 1.0;
  double calorieFactor = 1.0;
  double powerFactor = 1.0;

  SensorBase(serviceId, characteristicsId, device)
      : super(
          serviceId: serviceId,
          characteristicsId: characteristicsId,
          device: device,
        ) {
    refreshFactors();
  }

  bool canMeasurementProcessed(List<int> data);

  void clearMetrics();

  FitnessEquipment? refreshFactors() {
    if (!Get.isRegistered<FitnessEquipment>()) {
      return null;
    }

    final fitnessEquipment = Get.find<FitnessEquipment>();
    calorieFactor = fitnessEquipment.calorieFactor;
    powerFactor = fitnessEquipment.powerFactor;
  }
}
