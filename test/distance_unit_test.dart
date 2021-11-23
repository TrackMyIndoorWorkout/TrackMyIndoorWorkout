import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

class TestPair {
  final bool si;
  final bool highRes;
  final String unit;

  const TestPair({required this.si, required this.highRes, required this.unit});
}

void main() {
  group('AdvertisementDigest infers sport as expected from MachineType', () {
    for (final testPair in [
      const TestPair(si: true, highRes: false, unit: "km"),
      const TestPair(si: true, highRes: true, unit: "m"),
      const TestPair(si: false, highRes: false, unit: "mi"),
      const TestPair(si: false, highRes: true, unit: "yd"),
    ]) {
      test("SI ${testPair.si}, res ${testPair.highRes} -> ${testPair.unit}", () async {
        expect(distanceUnit(testPair.si, testPair.highRes), testPair.unit);
      });
    }
  });
}
