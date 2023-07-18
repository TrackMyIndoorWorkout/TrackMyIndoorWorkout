import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/cadence_mixin.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/delays.dart';

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
    expect(cadenceMixin.computeCadence().toInt(), 0);
  });

  group('Cadence Mixin clearCadenceData clears cadence data', () {
    final rnd = Random();
    for (var lenMinusTwo in getRandomInts(smallRepetition, 20, rnd)) {
      final len = lenMinusTwo + 2;
      final deltaTimes = getRandomDoubles(len, 1.5, rnd);
      final deltaRevolutions = getRandomDoubles(len, 100.0, rnd);
      test("len $len, ", () async {
        final cadenceMixin = CadenceMixin();
        for (final i in List<int>.generate(len, (i) => i, growable: false)) {
          cadenceMixin.addCadenceData(deltaTimes[i], deltaRevolutions[i]);
        }

        cadenceMixin.clearCadenceData();
        expect(cadenceMixin.cadenceData.isEmpty, true);
        expect(cadenceMixin.computeCadence().toInt(), 0);
      });
    }
  });

  group('Cadence Mixin computeCadence computes cadence data properly', () {
    final rnd = Random();
    for (var lenMinusOne in getRandomInts(smallRepetition, 10, rnd)) {
      final len = lenMinusOne + 1;
      final deltaTimes = getRandomDoubles(len, 1.5, rnd);
      final deltaRevolutions = getRandomDoubles(len, 2.0, rnd);
      final timeSum = deltaTimes.sum;
      final revolutionSum = deltaRevolutions.sum;
      test(
          "len $len, 0. (${deltaTimes.first}, ${deltaRevolutions.first}) $len. ($timeSum, $revolutionSum)",
          () async {
        final cadenceMixin = CadenceMixin();
        var cumulativeTime = 0.0;
        var cumulativeRevolution = 0.0;
        for (final i in List<int>.generate(len, (i) => i, growable: false)) {
          cumulativeTime += deltaTimes[i];
          cumulativeRevolution += deltaRevolutions[i];
          cadenceMixin.addCadenceData(cumulativeTime, cumulativeRevolution);
        }

        expect(cadenceMixin.cadenceData.length, len);
        final cadence = cadenceMixin.computeCadence().toInt();
        if (len == 1) {
          expect(cadence, 0);
        } else {
          expect(cadence,
              (revolutionSum - deltaRevolutions.first) * 60 ~/ (timeSum - deltaTimes.first));
        }
      });
    }
  });

  group('Cadence Mixin trimQueue empties queue when entries are old by time ticks', () {
    final rnd = Random();
    for (var numRevolutions in getRandomInts(
        smallRepetition, CadenceMixin.defaultRevolutionSlidingWindow * 2 + 1, rnd)) {
      numRevolutions += 1;
      test('# revolutions $numRevolutions', () async {
        final cadenceMixin = CadenceMixin();
        final deltaRevolutions = getRandomDoubles(numRevolutions, 5.0, rnd);
        var timeTick = 0.0;
        var revolutions = 0.0;
        for (final deltaRevolution in deltaRevolutions) {
          cadenceMixin.addCadenceData(timeTick, revolutions);
          revolutions += deltaRevolution;
          timeTick += (rnd.nextDouble() * 0.001 + 0.001);
        }

        expect(cadenceMixin.cadenceData.length, numRevolutions);
        cadenceMixin.addCadenceData(
            timeTick + CadenceMixin.defaultRevolutionSlidingWindow * 2, revolutions * 100.0);

        expect(cadenceMixin.cadenceData.length, 1);
      });
    }
  });

  group('Cadence Mixin trimQueue empties queue when entries are old by time stamps', () {
    final rnd = Random();
    for (var numRevolutions in getRandomInts(
        smallRepetition, CadenceMixin.defaultRevolutionSlidingWindow * 2 + 1, rnd)) {
      numRevolutions += 1;
      test('# revolutions $numRevolutions', () async {
        final cadenceMixin = CadenceMixin();
        final deltaRevolutions = getRandomDoubles(numRevolutions, 5.0, rnd);
        var timeTick = 0.0;
        var revolutions = 0.0;
        for (final deltaRevolution in deltaRevolutions) {
          cadenceMixin.addCadenceData(timeTick, revolutions);
          revolutions += deltaRevolution;
          timeTick += (rnd.nextDouble() * 0.001 + 0.001);
        }

        expect(cadenceMixin.cadenceData.length, numRevolutions);
        for (final cadenceData in cadenceMixin.cadenceData) {
          final timeStampAdjust = Duration(
              milliseconds:
                  CadenceMixin.defaultRevolutionSlidingWindow * 2000 + sensorDataThreshold);
          cadenceData.timeStamp = DateTime.now().subtract(timeStampAdjust);
        }
        cadenceMixin.addCadenceData(
            timeTick + CadenceMixin.defaultRevolutionSlidingWindow * 2, revolutions * 100.0);

        expect(cadenceMixin.cadenceData.length, 1);
      });
    }
  });
}
