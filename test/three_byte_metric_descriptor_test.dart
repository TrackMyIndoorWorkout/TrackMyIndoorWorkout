import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/three_byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group('optional ThreeByteMetricDescriptor returns null if the value is max', () {
    final rnd = Random();
    for (var divider in getRandomDoubles(REPETITION, 1024, rnd)) {
      final len = rnd.nextInt(99) + 5;
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 1 ? (lsbLocation < len - 2 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      data[lsbLocation] = MAX_BYTE;
      data[(lsbLocation + msbLocation) ~/ 2] = MAX_BYTE;
      data[msbLocation] = MAX_BYTE;
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
    for (final input in 1.to(REPETITION)) {
      final len = rnd.nextInt(99) + 5;
      final data = getRandomInts(len, MAX_UINT8, rnd);
      final lsbLocation = rnd.nextInt(len);
      final larger = lsbLocation > 1 ? (lsbLocation < len - 2 ? rnd.nextBool() : false) : true;
      final msbLocation = larger ? lsbLocation + 2 : lsbLocation - 2;
      final midLocation = (lsbLocation + msbLocation) ~/ 2;
      final divider = rnd.nextDouble() * 1024;
      final optional = rnd.nextBool();
      final expected = (optional &&
              data[lsbLocation] == MAX_BYTE &&
              data[midLocation] == MAX_BYTE &&
              data[msbLocation] == MAX_BYTE)
          ? 0
          : (data[lsbLocation] + MAX_UINT8 * (data[midLocation] + MAX_UINT8 * data[msbLocation])) /
              divider;

      test(
          "(${data[lsbLocation]} + ${data[midLocation]} + ${data[msbLocation]}) / $divider -> $expected",
          () async {
        final desc = ThreeByteMetricDescriptor(
            lsb: lsbLocation, msb: msbLocation, divider: divider, optional: optional);

        expect(desc.getMeasurementValue(data), closeTo(expected, EPS));
      });
    }
  });
}
