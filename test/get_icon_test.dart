import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getIcon for riding:", () async {
    expect(getIcon(ActivityType.Ride), Icons.directions_bike);
  });

  test("getIcon for running:", () async {
    expect(getIcon(ActivityType.Run), Icons.directions_run);
  });

  group("getIcon for paddle sports:", () {
    [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing].forEach((sport) {
      test("$sport -> $Icons.rowing", () {
        expect(getIcon(sport), Icons.rowing);
      });
    });
  });

  test("getIcon for swimming:", () async {
    expect(getIcon(ActivityType.Swim), Icons.waves);
  });

  test("getIcon for other (Elliptical):", () async {
    expect(getIcon(ActivityType.Elliptical), Icons.directions_bike);
  });
}
