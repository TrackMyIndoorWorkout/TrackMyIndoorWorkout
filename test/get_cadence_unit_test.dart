import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  group("getCadenceUnit is rpm for Running and Riding, spm for everything else ", () {
    SPORTS.forEach((sport) {
      final expected = (sport == ActivityType.Kayaking ||
              sport == ActivityType.Canoeing ||
              sport == ActivityType.Rowing ||
              sport == ActivityType.Swim ||
              sport == ActivityType.Elliptical)
          ? "spm"
          : "rpm";
      test("$sport -> $expected", () {
        expect(getCadenceUnit(sport), expected);
      });
    });
  });
}
