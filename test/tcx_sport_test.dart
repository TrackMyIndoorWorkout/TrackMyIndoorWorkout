import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  group("TCX is lame: only knows Ride and Run sports :P", () {
    SPORTS.forEach((sport) {
      final expected = sport == ActivityType.Ride || sport == ActivityType.Run ? sport : "Other";
      test("$sport -> $expected", () {
        expect(tcxSport(sport), expected);
      });
    });
  });
}
