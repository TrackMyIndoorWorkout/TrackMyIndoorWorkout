import '../../preferences/water_wheel_circumference.dart';
import '../../utils/constants.dart';
import 'cycling_power_meter_sensor.dart';

class PaddlingPowerMeterSensor extends CyclingPowerMeterSensor {
  PaddlingPowerMeterSensor(super.device) {
    sport = ActivityType.kayaking;
    circumferenceTag = waterWheelCircumferenceTag;
    circumferenceDefault = waterWheelCircumferenceDefault;
    readCircumference();
  }
}
