import '../devices/gadgets/heart_rate_monitor_internal.dart';
import '../devices/gadgets/cadence_monitor_internal.dart';

class InternalSensorManager {
  Future<bool> hasInternalHeartRate() async {
    return DeviceInternalHeartRate.hasHeartRateSensor();
  }

  Future<bool> hasInternalMotionSensors() async {
    return DeviceInternalMotion.hasMotionSensors();
  }
}
