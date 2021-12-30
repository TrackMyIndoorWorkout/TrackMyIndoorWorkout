import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional ByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    for (var rep in getRandomDoubles(repetition, 1024, rnd)) {
      final len = rnd.nextInt(99) + 1;
      final data = getRandomInts(len, maxUint8, rnd);
      final lsbLocation = rnd.nextInt(len);
      data[lsbLocation] = maxUint8 - 1;
      final divider = rnd.nextDouble() * 4;
      const expected = 0.0;

      test("$rep.: $divider -> $expected", () async {
        final desc = ByteMetricDescriptor(lsb: lsbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    }
  });

  group('ByteMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    for (var rep in 1.to(repetition)) {
      final len = rnd.nextInt(99) + 1;
      final data = getRandomInts(len, maxUint8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected =
          optional && data[lsbLocation] == maxUint8 - 1 ? null : data[lsbLocation] / divider;

      test("$rep.: ($lsbLocation) ${data[lsbLocation]} / $divider -> $expected", () async {
        final desc = ByteMetricDescriptor(lsb: lsbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), expected == null ? null : closeTo(expected, eps));
      });
    }
  });
}
