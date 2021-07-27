import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

class TestPair {
  final bool si;
  final bool highRes;
  final String unit;

  TestPair({required this.si, required this.highRes, required this.unit});
}

void main() {
  group('AdvertisementDigest infers sport as expected from MachineType', () {
    [
      TestPair(si: true, highRes: false, unit: "km"),
      TestPair(si: true, highRes: true, unit: "m"),
      TestPair(si: false, highRes: false, unit: "mi"),
      TestPair(si: false, highRes: true, unit: "yd"),
    ].forEach((testPair) {
      test("SI ${testPair.si}, res ${testPair.highRes} -> ${testPair.unit}", () async {
        expect(distanceUnit(testPair.si, testPair.highRes), testPair.unit);
      });
    });
  });
}
