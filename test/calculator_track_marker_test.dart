import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/tracks.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  final minPixel = 100;
  final maxPixel = 300;

  group('trackMarker start point is invariant', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;

      test("${track.radiusBoost} $lengthFactor", () async {
        final marker = calculator.trackMarker(0)!;

        expect(marker.dx, closeTo(THICK + offset.dx + r, EPS));
        expect(marker.dy, closeTo(size.height - THICK - offset.dy, EPS));
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
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);

      test("${track.radiusBoost} $lengthFactor $laps", () async {
        final marker = calculator.trackMarker(laps * TRACK_LENGTH * lengthFactor)!;

        expect(marker.dx, closeTo(THICK + offset.dx + r, EPS));
        expect(marker.dy, closeTo(size.height - THICK - offset.dy, EPS));
      });
    });
  });

  group('trackMarkers on the first (bottom) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + positionRatio * track.laneLength;
      final d = distance % trackLength;
      final displacement = d * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo(THICK + offset.dx + r + displacement, EPS));
        expect(marker.dy, closeTo(size.height - THICK - offset.dy, EPS));
      });
    });
  });

  group('trackMarkers on the first (right) chicane are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance =
          laps * trackLength + track.laneLength + positionRatio * track.halfCircle;
      final d = distance % trackLength;
      final rad = (d - track.laneLength) / track.halfCircle * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo(size.width - (THICK + offset.dx + r) + sin(rad) * r, EPS));
        expect(marker.dy, closeTo(r + THICK + offset.dy + cos(rad) * r, EPS));
      });
    });
  });

  group('trackMarkers on the second (top) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance =
          (laps + 0.5) * trackLength + positionRatio * track.laneLength;
      final d = distance % trackLength;
      final displacement = (d - trackLength / 2) * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo(size.width - (THICK + offset.dx + r) - displacement, EPS));
        expect(marker.dy, closeTo(THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarkers on the second (left) chicane are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = (laps + 0.5) * trackLength +
          track.laneLength +
          positionRatio * track.halfCircle;
      final d = distance % trackLength;
      final rad = (trackLength - d) / track.halfCircle * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo((1 - sin(rad)) * r + THICK + offset.dx, EPS));
        expect(marker.dy, closeTo((cos(rad) + 1) * r + THICK + offset.dy, EPS));
      });
    });
  });

  group('trackMarker always in bounds', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      test("${track.radiusBoost} $lengthFactor", () async {
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final size = Size(
            minPixel + rnd.nextDouble() * maxPixel,
            minPixel + rnd.nextDouble() * maxPixel,
          );
          calculator.trackSize = size;
          final rX = (size.width - 2 * THICK) / (2 + pi * track.laneShrink);
          final rY = (size.height - 2 * THICK) / 2;
          final r = min(rY, rX);
          calculator.trackRadius = r;
          final offset = Offset(
            rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
            rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
          );
          calculator.trackOffset = offset;

          final marker = calculator.trackMarker(distance.toDouble())!;

          expect(marker.dx, greaterThanOrEqualTo(THICK));
          expect(marker.dx, lessThanOrEqualTo(size.width - THICK));
          expect(marker.dy, greaterThanOrEqualTo(THICK));
          expect(marker.dy, lessThanOrEqualTo(size.height - THICK));
        });
      });
    });
  });

  group('trackMarker top continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + track.laneLength;
      final unitDistance = r / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, DISPLAY_EPS));
      });
    });
  });

  group('trackMarker bottom continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = (laps + 0.5) * trackLength + track.laneLength;
      final unitDistance = r / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, DISPLAY_EPS));
      });
    });
  });

  group('trackMarker long continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        radiusBoost: 1 + rnd.nextDouble() / 3,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;
      final offset = Offset(
        rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      calculator.trackOffset = offset;
      final unitDistance = r / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final markerA = calculator.trackMarker(distance.toDouble())!;
          distance++;
          final markerB = calculator.trackMarker(distance.toDouble())!;
          final dx = markerA.dx - markerB.dx;
          final dy = markerA.dy - markerB.dy;

          expect(dx * dx + dy * dy, closeTo(uDSquare, TRACK_LENGTH * DISPLAY_EPS));
        });
      });
    });
  });
}
