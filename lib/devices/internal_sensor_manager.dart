import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../devices/gadgets/heart_rate_monitor_internal.dart';
import '../devices/gadgets/cadence_monitor_internal.dart';
import '../preferences/internal_motion_monitor_enabled.dart';
import '../preferences/better_health_enabled.dart';

class InternalSensorManager {
  Future<bool> hasInternalHeartRate() async {
    return DeviceInternalHeartRate.hasHeartRateSensor();
  }

  Future<bool> hasInternalMotionSensors() async {
    final prefService = Get.find<BasePrefService>();
    final enabled =
        prefService.get<bool>(internalMotionMonitorEnabledTag) ??
        internalMotionMonitorEnabledDefault;
    if (!enabled) return false;

    return DeviceInternalMotion.hasMotionSensors();
  }

  Future<bool> hasBetterHealthTracker() async {
    final prefService = Get.find<BasePrefService>();
    return prefService.get<bool>(betterHealthEnabledTag) ?? betterHealthEnabledDefault;
  }
}
