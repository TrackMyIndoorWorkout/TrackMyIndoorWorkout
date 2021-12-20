import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  test("getSpeedUnit for riding:", () async {
    expect(getSpeedUnit(true, ActivityType.ride), "kmh");
    expect(getSpeedUnit(false, ActivityType.ride), "mph");
  });

  test("getSpeedUnit for running:", () async {
    expect(getSpeedUnit(true, ActivityType.run), "min /km");
    expect(getSpeedUnit(false, ActivityType.run), "min /mi");
  });

  group("getSpeedUnit for paddle sports:", () {
    for (final sport in [ActivityType.kayaking, ActivityType.canoeing, ActivityType.rowing]) {
      const expected = "min /500";
      test("$sport -> $expected", () async {
        expect(getSpeedUnit(true, sport), expected);
        expect(getSpeedUnit(false, sport), expected);
      });
    }
  });

  test("getSpeedUnit for swimming:", () async {
    const expected = "min /100";
    expect(getSpeedUnit(true, ActivityType.swim), expected);
    expect(getSpeedUnit(false, ActivityType.swim), expected);
  });

  test("getSpeedUnit for other (Elliptical):", () async {
    expect(getSpeedUnit(true, ActivityType.elliptical), "min /km");
    expect(getSpeedUnit(false, ActivityType.elliptical), "min /mi");
  });
}
