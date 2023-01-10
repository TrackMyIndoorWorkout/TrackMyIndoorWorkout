import '../../preferences/water_wheel_circumference.dart';
import '../../utils/constants.dart';
import '../gadgets/cycling_speed_and_cadence_sensor.dart';

class PaddlingSpeedAndCadenceSensor extends CyclingSpeedAndCadenceSensor {
  PaddlingSpeedAndCadenceSensor(device) : super(device) {
    sport = ActivityType.kayaking;
    circumferenceTag = waterWheelCircumferenceTag;
    circumferenceDefault = waterWheelCircumferenceDefault;
    readCircumference();
  }
}
