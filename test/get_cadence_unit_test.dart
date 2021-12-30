import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  group("getCadenceUnit is rpm for Running and Riding, spm for everything else ", () {
    for (final sport in sports) {
      final expected = (sport == ActivityType.kayaking ||
              sport == ActivityType.canoeing ||
              sport == ActivityType.rowing ||
              sport == ActivityType.swim ||
              sport == ActivityType.elliptical)
          ? "spm"
          : "rpm";
      test("$sport -> $expected", () {
        expect(getCadenceUnit(sport), expected);
      });
    }
  });
}
