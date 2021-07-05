import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/tracks.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  final minPixel = 150;
  final maxPixel = 400;

  group('trackMarker start point is invariant', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      test("${track.radiusBoost} $lengthFactor", () async {
        final marker = calculator.trackMarker(0)!;

        expect(
            marker.dx, closeTo(THICK + calculator.trackOffset!.dx + calculator.trackRadius!, EPS));
        expect(marker.dy, closeTo(size.height - THICK - calculator.trackOffset!.dy, EPS));
      });
    });
  });

  group('trackMarker whole laps are at the start point', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);

      test("${track.radiusBoost} $lengthFactor $laps", () async {
        final marker = calculator.trackMarker(laps * TRACK_LENGTH * lengthFactor)!;

        expect(
            marker.dx, closeTo(THICK + calculator.trackOffset!.dx + calculator.trackRadius!, EPS));
        expect(marker.dy, closeTo(size.height - THICK - calculator.trackOffset!.dy, EPS));
      });
    });
  });

  group('trackMarkers on the first (bottom) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + positionRatio * track.laneLength;
      final d = distance % trackLength;
      final r = calculator.trackRadius!;
      final displacement = d * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo(THICK + calculator.trackOffset!.dx + r + displacement, EPS));
        expect(marker.dy, closeTo(size.height - THICK - calculator.trackOffset!.dy, EPS));
      });
    });
  });

  group('trackMarkers on the first (right) chicane are placed as expected', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + track.laneLength + positionRatio * track.halfCircle;
      final d = distance % trackLength;
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      final r = calculator.trackRadius!;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx,
            closeTo(size.width - (THICK + calculator.trackOffset!.dx + r) + sin(rad) * r, EPS));
        expect(marker.dy, closeTo(r + THICK + calculator.trackOffset!.dy + cos(rad) * r, EPS));
      });
    });
  });

  group('trackMarkers on the second (top) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = (laps + 0.5) * trackLength + positionRatio * track.laneLength;
      final d = distance % trackLength;
      final r = calculator.trackRadius!;
      final displacement = (d - trackLength / 2) * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx,
            closeTo(size.width - (THICK + calculator.trackOffset!.dx + r) - displacement, EPS));
        expect(marker.dy, closeTo(THICK + calculator.trackOffset!.dy, EPS));
      });
    });
  });

  group('trackMarkers on the second (left) chicane are placed as expected', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance =
          (laps + 0.5) * trackLength + track.laneLength + positionRatio * track.halfCircle;
      final d = distance % trackLength;
      final r = calculator.trackRadius!;
      final rad = (trackLength - d) / track.halfCircle * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo((1 - sin(rad)) * r + THICK + calculator.trackOffset!.dx, EPS));
        expect(marker.dy, closeTo((cos(rad) + 1) * r + THICK + calculator.trackOffset!.dy, EPS));
      });
    });
  });

  group('trackMarker always in bounds', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      test("${track.radiusBoost} $lengthFactor", () async {
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final size = Size(
            minPixel + rnd.nextDouble() * maxPixel,
            minPixel + rnd.nextDouble() * maxPixel,
          );
          calculator.calculateConstantsOnDemand(size);

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
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + track.laneLength;
      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, TRACK_LENGTH * DISPLAY_EPS));
      });
    });
  });

  group('trackMarker bottom continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = (laps + 0.5) * trackLength + track.laneLength;
      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, TRACK_LENGTH * DISPLAY_EPS));
      });
    });
  });

  group('trackMarker continuity straight vs chicane', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final straightMarkerA = calculator.trackMarker((track.laneHalf - 0.1).toDouble())!;
        final straightMarkerB = calculator.trackMarker((track.laneHalf + 0.1).toDouble())!;
        final sdx = (straightMarkerA.dx - straightMarkerB.dx).abs();
        final sdy = straightMarkerA.dy - straightMarkerB.dy;
        expect(sdy, closeTo(0.0, DISPLAY_EPS));

        final chicaneMarkerA =
            calculator.trackMarker((track.laneLength + track.halfCircle / 2 - 0.1).toDouble())!;
        final chicaneMarkerB =
            calculator.trackMarker((track.laneLength + track.halfCircle / 2 + 0.1).toDouble())!;
        final cdx = chicaneMarkerA.dx - chicaneMarkerB.dx;
        final cdy = (chicaneMarkerA.dy - chicaneMarkerB.dy).abs();

        expect(cdx, closeTo(0.0, DISPLAY_EPS));
        expect(sdx, closeTo(cdy, DISPLAY_EPS));
      });
    });
  });

  group('trackMarker general continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.3;
      final track = TrackDescriptor(
        radiusBoost: 0.65 + rnd.nextDouble(),
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final markerA = calculator.trackMarker(distance.toDouble())!;
          final markerB = calculator.trackMarker((distance + 1).toDouble())!;
          final dx = markerA.dx - markerB.dx;
          final dy = markerA.dy - markerB.dy;

          expect(dx * dx + dy * dy, closeTo(uDSquare, TRACK_LENGTH * DISPLAY_EPS));
        });
      });
    });
  });
}
