import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/short_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional ShortMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 2;
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 0 ? (lsbLocation < len - 1 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      data[lsbLocation] = MAX_BYTE;
      data[msbLocation] = MAX_BYTE;
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
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 0 ? (lsbLocation < len - 1 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional && data[lsbLocation] == MAX_BYTE && data[msbLocation] == MAX_BYTE)
          ? 0
          : (data[lsbLocation] + data[msbLocation] * MAX_UINT8) / divider;

      test("(${data[lsbLocation]} + ${data[msbLocation]}) / $divider -> $expected", () {
        final desc = ShortMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, EPS));
      });
    });
  });
}
