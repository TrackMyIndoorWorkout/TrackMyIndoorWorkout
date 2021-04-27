import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/long_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional LongMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 6;
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      data[lsbLocation] = MAX_BYTE;
      if (larger) {
        data[lsbLocation + 1] = MAX_BYTE;
        data[lsbLocation + 2] = MAX_BYTE;
      } else {
        data[msbLocation + 1] = MAX_BYTE;
        data[msbLocation + 2] = MAX_BYTE;
      }
      data[msbLocation] = MAX_BYTE;
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
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final midLocation1 = larger ? lsbLocation + 1 : lsbLocation - 1;
      final midLocation2 = larger ? lsbLocation + 2 : lsbLocation - 2;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == MAX_BYTE &&
              data[midLocation1] == MAX_BYTE &&
              data[midLocation2] == MAX_BYTE &&
              data[msbLocation] == MAX_BYTE)
          ? 0
          : (data[lsbLocation] +
                  MAX_UINT8 *
                      (data[midLocation1] +
                          MAX_UINT8 * (data[midLocation2] + MAX_UINT8 * data[msbLocation]))) /
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
