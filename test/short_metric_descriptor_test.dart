import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/short_metric_descriptor.dart';
import 'utils.dart';

void main() {
  group('optional ShortMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 2;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 0 ? (lsbLocation < len - 1 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      data[lsbLocation] = 255;
      data[msbLocation] = 255;
      final divider = rnd.nextDouble() * 4;
      final expected = 0.0;

      test("$divider -> $expected", () {
        final desc = ShortMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('ShortMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final len = rnd.nextInt(99) + 2;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 0 ? (lsbLocation < len - 1 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional && data[lsbLocation] == 255 && data[msbLocation] == 255)
          ? 0
          : (data[lsbLocation] + data[msbLocation] * 256) / divider;

      test(
          "($lsbLocation $msbLocation) ${data[lsbLocation]} ${data[msbLocation]} / $divider -> $expected",
          () {
        final desc = ShortMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, 1e-6));
      });
    });
  });
}
