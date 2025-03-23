import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/short_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  group('optional ShortMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(repetition, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 2;
      final data = getRandomInts(len, maxUint8, rnd);
      final larger = rnd.nextBool();
      final lsbLocation = rnd.nextInt(len - 1) + (larger ? 0 : 1);
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      data[lsbLocation] = maxByte;
      data[msbLocation] = maxByte;
      final divider = rnd.nextDouble() * 4;
      const expected = 0.0;

      test("$divider -> $expected", () async {
        final desc = ShortMetricDescriptor(
          lsb: lsbLocation,
          msb: msbLocation,
          divider: divider,
          optional: true,
        );

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('ShortMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    for (var lenMinusTwo in getRandomInts(repetition, 99, rnd)) {
      final len = lenMinusTwo + 2;
      final data = getRandomInts(len, maxUint8, rnd);
      final larger = rnd.nextBool();
      final lsbLocation = rnd.nextInt(len - 1) + (larger ? 0 : 1);
      final msbLocation = larger ? lsbLocation + 1 : lsbLocation - 1;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected =
          (optional && data[lsbLocation] == maxByte && data[msbLocation] == maxByte)
              ? 0
              : (data[lsbLocation] + data[msbLocation] * maxUint8) / divider;

      test("(${data[lsbLocation]} + ${data[msbLocation]}) / $divider -> $expected", () async {
        final desc = ShortMetricDescriptor(
          lsb: lsbLocation,
          msb: msbLocation,
          divider: divider,
          optional: optional,
        );

        expect(desc.getMeasurementValue(data), closeTo(expected, eps));
      });
    }
  });
}
