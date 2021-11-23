import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/tcx/tcx_export.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("TCX is lame: only knows Ride and Run sports :P", () {
    for (final sport in SPORTS) {
      final expected = sport == ActivityType.Ride || sport == ActivityType.Run ? sport : "Other";
      test("$sport -> $expected", () async {
        expect(TCXExport.tcxSport(sport), expected);
      });
    }
  });
}
