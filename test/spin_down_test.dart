import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/ui/parts/spin_down.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

main() {
  group('getWeightFromBytes is inverse of getWeightBytes', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 200, rnd).forEach((weight) {
      weight += 50;
      final si = rnd.nextBool();
      if (si) {
        weight = (weight * lbToKg).round();
      }

      test('$weight ${si ? "kg" : "lbs"}', () async {
        final weightBytes = SpinDownBottomSheetState.getWeightBytes(weight, si);
        final weight2 =
            SpinDownBottomSheetState.getWeightFromBytes(weightBytes.item1, weightBytes.item2, si);

        expect(weight2, closeTo(weight, 1.0));
      });
    });
  });

  group('getWeightBytes result as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 200, rnd).forEach((weight) {
      weight += 50;
      final si = rnd.nextBool();
      if (si) {
        weight = (weight * lbToKg).round();
      }

      test('$weight ${si ? "kg" : "lbs"}', () async {
        final weightBytes = SpinDownBottomSheetState.getWeightBytes(weight, si);
        final weightMultiplied = (weight * 200 * (si ? 1.0 : lbToKg)).round();

        expect(weightBytes.item1, weightMultiplied % 256);
        expect(weightBytes.item2, weightMultiplied ~/ 256);
      });
    });
  });

  group('getWeightFromBytes result as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, maxUint8, rnd).forEach((lsb) {
      final msb = rnd.nextInt(maxUint8);
      final si = rnd.nextBool();
      test('$lsb $msb $si', () async {
        int expectedWeight = (lsb + maxUint8 * msb) * (si ? 1.0 : kgToLb) ~/ 200;

        final weight = SpinDownBottomSheetState.getWeightFromBytes(lsb, msb, si);

        expect(weight, expectedWeight);
      });
    });
  });
}
