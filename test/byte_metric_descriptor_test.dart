import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/metric_descriptors/byte_metric_descriptor.dart';
import '../lib/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional ByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 1;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      data[lsbLocation] = 255;
      final divider = rnd.nextDouble() * 4;
      final expected = 0.0;

      test("$divider -> $expected", () {
        final desc = ByteMetricDescriptor(lsb: lsbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('ByteMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final len = rnd.nextInt(99) + 1;
      final data = getRandomInts(len, 256, rnd);
      final lsbLocation = rnd.nextInt(len);
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = optional && data[lsbLocation] == 255 ? null : data[lsbLocation] / divider;

      test("($lsbLocation) ${data[lsbLocation]} / $divider -> $expected", () {
        final desc = ByteMetricDescriptor(lsb: lsbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, EPS));
      });
    });
  });
}
