import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/track/calculator.dart';
import '../lib/track/constants.dart';
import '../lib/track/tracks.dart';
import '../lib/utils/constants.dart';
import 'utils.dart';

void main() {
  final minPixel = 10;
  final maxPixel = 300;

  group('trackMarker start point is invariant', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;

      test("${track.radiusBoost} $lengthFactor", () {
        final marker = calculator.trackMarker(0);

        expect(marker.dx, closeTo(size.width - THICK - offset.dx - r, EPS));
        expect(marker.dy, closeTo(THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarker whole laps are at the start point', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);

      test("${track.radiusBoost} $lengthFactor $laps", () {
        final marker = calculator.trackMarker(laps * TRACK_LENGTH * lengthFactor);

        expect(marker.dx, closeTo(size.width - THICK - offset.dx - r, EPS));
        expect(marker.dy, closeTo(THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarker on the first (top) straight is placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final displacement = d / track.laneLength * pi * track.laneShrink / track.radiusBoost * r;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () {
        final marker = calculator.trackMarker(distance);

        expect(marker.dx, closeTo(size.width - THICK - offset.dx - r - displacement, EPS));
        expect(marker.dy, closeTo(THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarker on the first (left) chicane is placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          laps * TRACK_LENGTH * lengthFactor + track.laneLength + positionRatio * track.halfCircle;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final rad = (1 - (d - track.laneLength) / track.halfCircle) * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () {
        final marker = calculator.trackMarker(distance);

        expect(marker.dx, closeTo((1 - sin(rad)) * r + THICK + offset.dx, EPS));
        expect(marker.dy, closeTo((cos(rad) + 1) * r + THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarker on the second (bottom) straight is placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          (laps + 0.5) * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final displacement =
          (d - trackLength / 2) / track.laneLength * pi * track.laneShrink / track.radiusBoost * r;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () {
        final marker = calculator.trackMarker(distance);

        expect(marker.dx, closeTo(THICK + offset.dx + r + displacement, EPS));
        expect(marker.dy, closeTo(size.height - THICK - offset.dy, EPS));
      });
    });
  });

  group('trackMarker on the second (right) chicane is placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size =
          Size(minPixel + rnd.nextDouble() * maxPixel, minPixel + rnd.nextDouble() * maxPixel);
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = (laps + 0.5) * TRACK_LENGTH * lengthFactor +
          track.laneLength +
          positionRatio * track.halfCircle;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final rad = (2 + (d - trackLength / 2 - track.laneLength) / track.halfCircle) * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () {
        final marker = calculator.trackMarker(distance);

        expect(marker.dx, closeTo(size.width - THICK - offset.dx - (1 - sin(rad)) * r, EPS));
        expect(marker.dy, closeTo(r * (cos(rad) + 1) + THICK + offset.dy, EPS));
      });
    });
  });
}
