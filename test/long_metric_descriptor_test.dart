import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/long_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional LongMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    getRandomDoubles(repetition, 1024, rnd).forEach((divider) {
      final len = rnd.nextInt(99) + 6;
      final data = getRandomInts(len, maxUint8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      data[lsbLocation] = maxByte;
      if (larger) {
        data[lsbLocation + 1] = maxByte;
        data[lsbLocation + 2] = maxByte;
      } else {
        data[msbLocation + 1] = maxByte;
        data[msbLocation + 2] = maxByte;
      }
      data[msbLocation] = maxByte;
      final divider = rnd.nextDouble() * 4;
      const expected = 0.0;

      test("$divider -> $expected", () async {
        final desc = LongMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: true);

        expect(desc.getMeasurementValue(data), null);
      });
    });
  });

  group('LongMetricDescriptor calculates measurement as expected', () {
    final rnd = Random();
    for (var lenMinusSix in getRandomInts(repetition, 99, rnd)) {
      final len = lenMinusSix + 6;
      final data = getRandomInts(len, maxUint8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 2 ? (lsbLocation < len - 3 ? rnd.nextBool() : false) : true;
      final midLocation1 = larger ? lsbLocation + 1 : lsbLocation - 1;
      final midLocation2 = larger ? lsbLocation + 2 : lsbLocation - 2;
      final msbLocation = larger ? lsbLocation + 3 : lsbLocation - 3;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == maxByte &&
              data[midLocation1] == maxByte &&
              data[midLocation2] == maxByte &&
              data[msbLocation] == maxByte)
          ? 0
          : (data[lsbLocation] +
                  maxUint8 *
                      (data[midLocation1] +
                          maxUint8 * (data[midLocation2] + maxUint8 * data[msbLocation]))) /
              divider;

      test(
          "($lsbLocation $msbLocation) ${data[lsbLocation]} ${data[msbLocation]} $divider -> $expected",
          () async {
        final desc = LongMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), closeTo(expected, eps));
      });
    }
  });
}
