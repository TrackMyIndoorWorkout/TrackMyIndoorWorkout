import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getSpeedUnit for riding:", () async {
    expect(getSpeedUnit(true, ActivityType.Ride), "kmh");
    expect(getSpeedUnit(false, ActivityType.Ride), "mph");
  });

  test("getSpeedUnit for running:", () async {
    expect(getSpeedUnit(true, ActivityType.Run), "min /km");
    expect(getSpeedUnit(false, ActivityType.Run), "min /mi");
  });

  group("getSpeedUnit for paddle sports:", () {
    for (final sport in [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing]) {
      const expected = "min /500";
      test("$sport -> $expected", () async {
        expect(getSpeedUnit(true, sport), expected);
        expect(getSpeedUnit(false, sport), expected);
      });
    }
  });

  test("getSpeedUnit for swimming:", () async {
    const expected = "min /100";
    expect(getSpeedUnit(true, ActivityType.Swim), expected);
    expect(getSpeedUnit(false, ActivityType.Swim), expected);
  });

  test("getSpeedUnit for other (Elliptical):", () async {
    expect(getSpeedUnit(true, ActivityType.Elliptical), "min /km");
    expect(getSpeedUnit(false, ActivityType.Elliptical), "min /mi");
  });
}
