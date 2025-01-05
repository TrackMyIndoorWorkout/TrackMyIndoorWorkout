import 'package:flutter/cupertino.dart';

import '../../preferences/wheel_circumference.dart';
import '../../utils/constants.dart';
import 'complex_sensor.dart';

abstract class FlywheelSensorBase extends ComplexSensor {
  String sport = ActivityType.ride;

  double circumference = wheelCircumferenceDefault / 1000;
  String circumferenceTag = wheelCircumferenceTag;
  int circumferenceDefault = wheelCircumferenceDefault;

  FlywheelSensorBase(super.serviceUuid, super.characteristicUuid, super.device) {
    readCircumference();
  }

  void readCircumference() {
    circumference = (prefService.get<int>(circumferenceTag) ?? circumferenceDefault) / 1000;
    debugPrint("circumference: $circumference");
  }
}
