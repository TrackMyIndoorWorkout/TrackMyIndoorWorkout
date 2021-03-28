import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  group("speedTitle is pace for everything else than Ride", () {
    SPORTS.forEach((sport) {
      final expected = sport == ActivityType.Ride ? "Speed" : "Pace";
      test("$sport -> $expected", () {
        expect(speedTitle(sport), expected);
      });
    });
  });
}
