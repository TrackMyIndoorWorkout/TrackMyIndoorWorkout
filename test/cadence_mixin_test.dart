import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/cadence_mixin.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';

import 'utils.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Cadence Mixin returns 0 when empty', () async {
    final cadenceMixin = CadenceMixin();

    expect(cadenceMixin.cadenceData.isEmpty, true);
    expect(cadenceMixin.computeCadence(), 0);
  });

  group('Cadence Mixin clearCadenceData clears cadence data', () {
    final rnd = Random();
    for (var lenMinusTwo in getRandomInts(smallRepetition, 20, rnd)) {
      final len = lenMinusTwo + 2;
      final deltaTimes = getRandomDoubles(len, 1.5, rnd);
      final deltaRevolutions = getRandomInts(len, 100, rnd);
      test("len $len, ", () async {
        final cadenceMixin = CadenceMixin();
        for (final i in List<int>.generate(len, (i) => i, growable: false)) {
          cadenceMixin.addCadenceData(deltaTimes[i], deltaRevolutions[i]);
        }

        cadenceMixin.clearCadenceData();
        expect(cadenceMixin.cadenceData.isEmpty, true);
        expect(cadenceMixin.computeCadence(), 0);
      });
    }
  });

  group('Cadence Mixin computeCadence computes cadence data properly', () {
    final rnd = Random();
    for (var lenMinusOne in getRandomInts(smallRepetition, 10, rnd)) {
      final len = lenMinusOne + 1;
      final deltaTimes = getRandomDoubles(len, 1.5, rnd);
      final deltaRevolutions = getRandomInts(len, 2, rnd);
      final timeSum = deltaTimes.sum;
      final revolutionSum = deltaRevolutions.sum;
      test(
          "len $len, 0. (${deltaTimes.first}, ${deltaRevolutions.first}) $len. ($timeSum, $revolutionSum)",
          () async {
        final cadenceMixin = CadenceMixin();
        var cumulativeTime = 0.0;
        var cumulativeRevolution = 0;
        for (final i in List<int>.generate(len, (i) => i, growable: false)) {
          cumulativeTime += deltaTimes[i];
          cumulativeRevolution += deltaRevolutions[i];
          cadenceMixin.addCadenceData(cumulativeTime, cumulativeRevolution);
        }

        expect(cadenceMixin.cadenceData.length, len);
        final cadence = cadenceMixin.computeCadence();
        if (len == 1) {
          expect(cadence, 0);
        } else {
          expect(cadence,
              (revolutionSum - deltaRevolutions.first) * 60 ~/ (timeSum - deltaTimes.first));
        }
      });
    }
  });
}
