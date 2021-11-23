import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  final speeds = [
    0.0,
    0.2,
    0.3,
    0.5,
    1.0,
    1.2,
    1.3,
    1.5,
    2.0,
    5.0,
    10.0,
    12.0,
    15.0,
    20.0,
  ];
  group("speedByUnitCore for metric system and riding:", () {
    for (final speed in speeds) {
      for (final sport in SPORTS) {
        final expected = speed;
        test("$speed ($sport) -> $expected", () async {
          expect(speedByUnitCore(speed, true), expected);
        });
      }
    }
  });

  group("speedByUnitCore for imperial system and riding:", () {
    for (final speed in speeds) {
      for (final sport in SPORTS) {
        final expected = speed * KM2MI;
        test("$speed ($sport) -> $expected", () async {
          expect(speedByUnitCore(speed, false), expected);
        });
      }
    }
  });
}
