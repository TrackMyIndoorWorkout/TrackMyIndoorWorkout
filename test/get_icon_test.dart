import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getIcon for Riding:", () async {
    expect(getSportIcon(ActivityType.ride), Icons.directions_bike);
  });

  test("getIcon for Running:", () async {
    expect(getSportIcon(ActivityType.run), Icons.directions_run);
  });

  test("getIcon for Kayaking:", () async {
    expect(getSportIcon(ActivityType.kayaking), Icons.kayaking);
  });

  test("getIcon for Canoeing:", () async {
    expect(getSportIcon(ActivityType.canoeing), Icons.rowing);
  });

  test("getIcon for Rowing:", () async {
    expect(getSportIcon(ActivityType.rowing), Icons.rowing);
  });

  test("getIcon for Swimming:", () async {
    expect(getSportIcon(ActivityType.swim), Icons.waves);
  });

  test("getIcon for Elliptical:", () async {
    expect(getSportIcon(ActivityType.elliptical), Icons.downhill_skiing);
  });

  test("getIcon for StairStepper:", () async {
    expect(getSportIcon(ActivityType.stairStepper), Icons.stairs);
  });

  test("getIcon for other (Crossfit):", () async {
    expect(getSportIcon(ActivityType.crossfit), Icons.help);
  });
}
