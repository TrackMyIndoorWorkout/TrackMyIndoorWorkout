import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/three_byte_metric_descriptor.dart';
import 'utils.dart';

void main() {
  group('optional ThreeByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 5;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 1 ? (lsbLocation < len - 2 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      data[lsbLocation] = 255;
      data[(lsbLocation + msbLocation) ~/ 2] = 255;
      data[msbLocation] = 255;
      final divider = rnd.nextDouble() * 4;
      final expected = 0.0;

      test("$divider -> $expected", () {
        final desc = ThreeByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('ThreeByteMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final len = rnd.nextInt(99) + 5;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 1 ? (lsbLocation < len - 2 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      final midLocation = (lsbLocation + msbLocation) ~/ 2;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == 255 &&
              data[midLocation] == 255 &&
              data[msbLocation] == 255)
          ? 0
          : (data[lsbLocation] + 256 * (data[midLocation] + 256 * data[msbLocation])) / divider;

      test(
          "(${data[lsbLocation]} + ${data[midLocation]} + ${data[msbLocation]}) / $divider -> $expected",
          () {
        final desc = ThreeByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, 1e-6));
      });
    });
  });
}
