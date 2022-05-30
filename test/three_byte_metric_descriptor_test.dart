import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/three_byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional ThreeByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    for (var divider in getRandomDoubles(repetition, 1024, rnd)) {
      final len = rnd.nextInt(99) + 5;
      final data = getRandomInts(len, maxUint8, rnd);
      final larger = rnd.nextBool();
      final lsbLocation = rnd.nextInt(len - 2) + (larger ? 0 : 2);
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      data[lsbLocation] = maxByte;
      data[(lsbLocation + msbLocation) ~/ 2] = maxByte;
      data[msbLocation] = maxByte;
      divider = rnd.nextDouble() * 4;
      const expected = 0.0;

      test("$divider -> $expected", () async {
        final desc = ThreeByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    }
  });

  group('ThreeByteMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    for (var lenMinusFive in getRandomInts(repetition, 99, rnd)) {
      final len = lenMinusFive + 5;
      final data = getRandomInts(len, maxUint8, rnd);
      final larger = rnd.nextBool();
      final lsbLocation = rnd.nextInt(len - 2) + (larger ? 0 : 2);
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      final midLocation = (lsbLocation + msbLocation) ~/ 2;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == maxByte &&
              data[midLocation] == maxByte &&
              data[msbLocation] == maxByte)
          ? 0
          : (data[lsbLocation] + maxUint8 * (data[midLocation] + maxUint8 * data[msbLocation])) /
              divider;

      test(
          "(${data[lsbLocation]}, ${data[midLocation]}, ${data[msbLocation]}) / $divider -> $expected",
          () async {
        final desc = ThreeByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), closeTo(expected, eps));
      });
    }
  });
}
