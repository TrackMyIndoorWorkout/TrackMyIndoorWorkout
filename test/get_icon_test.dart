import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getIcon for Riding:", () async {
    expect(getIcon(ActivityType.Ride), Icons.directions_bike);
  });

  test("getIcon for Running:", () async {
    expect(getIcon(ActivityType.Run), Icons.directions_run);
  });

  test("getIcon for Kayaking:", () async {
    expect(getIcon(ActivityType.Kayaking), Icons.kayaking);
  });

  test("getIcon for Canoeing:", () async {
    expect(getIcon(ActivityType.Canoeing), Icons.rowing);
  });

  test("getIcon for Rowing:", () async {
    expect(getIcon(ActivityType.Rowing), Icons.rowing);
  });

  test("getIcon for Swimming:", () async {
    expect(getIcon(ActivityType.Swim), Icons.waves);
  });

  test("getIcon for Elliptical:", () async {
    expect(getIcon(ActivityType.Elliptical), Icons.downhill_skiing);
  });

  test("getIcon for StairStepper:", () async {
    expect(getIcon(ActivityType.StairStepper), Icons.stairs);
  });

  test("getIcon for other (Crossfit):", () async {
    expect(getIcon(ActivityType.Crossfit), Icons.directions_bike);
  });
}
