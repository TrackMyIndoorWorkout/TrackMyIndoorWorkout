import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getIcon for Riding:", () async {
    expect(getIcon(ActivityType.ride), Icons.directions_bike);
  });

  test("getIcon for Running:", () async {
    expect(getIcon(ActivityType.run), Icons.directions_run);
  });

  test("getIcon for Kayaking:", () async {
    expect(getIcon(ActivityType.kayaking), Icons.kayaking);
  });

  test("getIcon for Canoeing:", () async {
    expect(getIcon(ActivityType.canoeing), Icons.rowing);
  });

  test("getIcon for Rowing:", () async {
    expect(getIcon(ActivityType.rowing), Icons.rowing);
  });

  test("getIcon for Swimming:", () async {
    expect(getIcon(ActivityType.swim), Icons.waves);
  });

  test("getIcon for Elliptical:", () async {
    expect(getIcon(ActivityType.elliptical), Icons.downhill_skiing);
  });

  test("getIcon for StairStepper:", () async {
    expect(getIcon(ActivityType.stairStepper), Icons.stairs);
  });

  test("getIcon for other (Crossfit):", () async {
    expect(getIcon(ActivityType.crossfit), Icons.directions_bike);
  });
}
