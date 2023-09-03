import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/six_byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional SixByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    for (var divider in getRandomDoubles(repetition, 1024, rnd)) {
      final len = rnd.nextInt(99) + 10;
      final data = getRandomInts(len, maxUint8, rnd);
      final larger = rnd.nextBool();
      final lsbLocation = rnd.nextInt(len - 5) + (larger ? 0 : 5);
      final msbLocation = larger ? lsbLocation + 5 : lsbLocation - 5;
      final dir = larger ? 1 : -1;
      data[lsbLocation] = maxByte;
      data[lsbLocation + dir] = maxByte;
      data[lsbLocation + 2 * dir] = maxByte;
      data[msbLocation - 2 * dir] = maxByte;
      data[msbLocation - dir] = maxByte;
      data[msbLocation] = maxByte;
      divider = rnd.nextDouble() * 4;
      const expected = 0.0;

      test("$divider -> $expected", () async {
        final desc = SixByteMetricDescriptor(
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
      final lsbLocation = rnd.nextInt(len - 3) + (larger ? 0 : 3);
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      final dir = larger ? 1 : -1;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == maxByte &&
              data[lsbLocation + dir] == maxByte &&
              data[lsbLocation + 2 * dir] == maxByte &&
              data[msbLocation - 2 * dir] == maxByte &&
              data[msbLocation - dir] == maxByte &&
              data[msbLocation] == maxByte)
          ? 0
          : (data[lsbLocation] +
                  maxUint8 *
                      (data[lsbLocation + dir] +
                          maxUint8 *
                              (data[lsbLocation + 2 * dir] +
                                  maxUint8 *
                                      (data[msbLocation - 2 * dir] +
                                          maxUint8 *
                                              (data[msbLocation - dir] +
                                                  maxUint8 * data[msbLocation]))))) /
              divider;

      test(
          "(${data[lsbLocation]}, ${data[lsbLocation + dir]}, ${data[lsbLocation + 2 * dir]}, ${data[msbLocation - 2 * dir]}, ${data[msbLocation - dir]}, ${data[msbLocation]}) / $divider -> $expected",
          () async {
        final desc = SixByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), closeTo(expected, eps));
      });
    }
  });
}
