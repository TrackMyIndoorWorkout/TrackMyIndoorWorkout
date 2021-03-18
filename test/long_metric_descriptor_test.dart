import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/metric_descriptors/long_metric_descriptor.dart';
import '../lib/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional LongMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 6;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      data[lsbLocation] = 255;
      if (larger) {
        data[lsbLocation + 1] = 255;
        data[lsbLocation + 2] = 255;
      } else {
        data[msbLocation + 1] = 255;
        data[msbLocation + 2] = 255;
      }
      data[msbLocation] = 255;
      final divider = rnd.nextDouble() * 4;
      final expected = 0.0;

      test("$divider -> $expected", () {
        final desc = LongMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('LongMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final len = rnd.nextInt(99) + 6;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final midLocation1 = larger ? lsbLocation + 1 : lsbLocation - 1;
      final midLocation2 = larger ? lsbLocation + 2 : lsbLocation - 2;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == 255 &&
              data[midLocation1] == 255 &&
              data[midLocation2] == 255 &&
              data[msbLocation] == 255)
          ? 0
          : (data[lsbLocation] +
                  256 *
                      (data[midLocation1] + 256 * (data[midLocation2] + 256 * data[msbLocation]))) /
              divider;

      test(
          "($lsbLocation $msbLocation) ${data[lsbLocation]} ${data[msbLocation]} $divider -> $expected",
          () {
        final desc = LongMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, EPS));
      });
    });
  });
}
