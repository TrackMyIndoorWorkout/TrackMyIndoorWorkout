import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/short_metric_descriptor.dart';
import 'utils.dart';

void main() {
  group('ShortMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final len = rnd.nextInt(99) + 2;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 0 ? (lsbLocation < len - 1 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      final divider = rnd.nextDouble() * 4;
      final expected = (data[lsbLocation] + data[msbLocation] * 256) / divider;

      test(
          "($lsbLocation $msbLocation) ${data[lsbLocation]} ${data[msbLocation]} $divider -> $expected",
          () {
        final desc = ShortMetricDescriptor(lsb: lsbLocation, msb: msbLocation, divider: divider);

        expect(desc.getMeasurementValue(data), expected);
      });
    });
  });
}
