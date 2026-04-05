import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/track_descriptor.dart';
import 'package:track_my_indoor_exercise/track/track_kind.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  const minPixel = 150;
  const maxPixel = 400;

  group('trackMarker start point is invariant', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      test("${track.radiusBoost} $lengthFactor", () async {
        final marker = calculator.trackMarker(0)!;

        expect(
          marker.dx,
          closeTo(thick + calculator.trackOffset!.dx + calculator.trackRadius!, eps),
        );
        expect(marker.dy, closeTo(size.height - thick - calculator.trackOffset!.dy, eps));
      });
    }
  });

  group('trackMarker whole laps are at the start point', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);

      test("${track.radiusBoost} $lengthFactor $laps", () async {
        final marker = calculator.trackMarker(laps * track.length)!;

        expect(
          marker.dx,
          closeTo(thick + calculator.trackOffset!.dx + calculator.trackRadius!, eps),
        );
        expect(marker.dy, closeTo(size.height - thick - calculator.trackOffset!.dy, eps));
      });
    }
  });

  group('trackMarkers on the first (bottom) straight are placed proportionally', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * track.length + positionRatio * track.laneLength;
      final d = distance % track.length;
      final r = calculator.trackRadius!;
      final displacement = d * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo(thick + calculator.trackOffset!.dx + r + displacement, eps));
        expect(marker.dy, closeTo(size.height - thick - calculator.trackOffset!.dy, eps));
      });
    }
  });

  group('trackMarkers on the first (right) chicane are placed as expected', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * track.length + track.laneLength + positionRatio * track.halfCircle;
      final d = distance % track.length;
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      final r = calculator.trackRadius!;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(
          marker.dx,
          closeTo(size.width - (thick + calculator.trackOffset!.dx + r) + sin(rad) * r, eps),
        );
        expect(marker.dy, closeTo(r + thick + calculator.trackOffset!.dy + cos(rad) * r, eps));
      });
    }
  });

  group('trackMarkers on the second (top) straight are placed proportionally', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = (laps + 0.5) * track.length + positionRatio * track.laneLength;
      final d = distance % track.length;
      final r = calculator.trackRadius!;
      final displacement = (d - track.length / 2) * r / track.radius;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(
          marker.dx,
          closeTo(size.width - (thick + calculator.trackOffset!.dx + r) - displacement, eps),
        );
        expect(marker.dy, closeTo(thick + calculator.trackOffset!.dy, eps));
      });
    }
  });

  group('trackMarkers on the second (left) chicane are placed as expected', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          (laps + 0.5) * track.length + track.laneLength + positionRatio * track.halfCircle;
      final d = distance % track.length;
      final r = calculator.trackRadius!;
      final rad = (track.length - d) / track.halfCircle * pi;

      test("${track.radiusBoost} $lengthFactor $laps $distance", () async {
        final marker = calculator.trackMarker(distance)!;

        expect(marker.dx, closeTo((1 - sin(rad)) * r + thick + calculator.trackOffset!.dx, eps));
        expect(marker.dy, closeTo((cos(rad) + 1) * r + thick + calculator.trackOffset!.dy, eps));
      });
    }
  });

  group('trackMarker always in bounds', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      test("${track.radiusBoost} $lengthFactor", () async {
        for (var distance in List<int>.generate((track.length * 2).round(), (index) => index)) {
          final size = Size(
            minPixel + rnd.nextDouble() * maxPixel,
            minPixel + rnd.nextDouble() * maxPixel,
          );
          calculator.calculateConstantsOnDemand(size);

          final marker = calculator.trackMarker(distance.toDouble())!;

          expect(marker.dx, greaterThanOrEqualTo(thick));
          expect(marker.dx, lessThanOrEqualTo(size.width - thick));
          expect(marker.dy, greaterThanOrEqualTo(thick));
          expect(marker.dy, lessThanOrEqualTo(size.height - thick));
        }
      });
    }
  });

  group('trackMarker top continuity', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final distance = laps * track.length + track.laneLength;
      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, track.length * displayEps));
      });
    }
  });

  group('trackMarker bottom continuity', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final laps = rnd.nextInt(100);
      final distance = (laps + 0.5) * track.length + track.laneLength;
      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.trackMarker((distance - 0.5).toDouble())!;
        final markerB = calculator.trackMarker((distance + 0.5).toDouble())!;
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(uDSquare, track.length * displayEps));
      });
    }
  });

  group('trackMarker continuity straight vs chicane', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
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
        expect(sdy, closeTo(0.0, displayEps));

        final chicaneMarkerA = calculator.trackMarker(
          (track.laneLength + track.halfCircle / 2 - 0.1).toDouble(),
        )!;
        final chicaneMarkerB = calculator.trackMarker(
          (track.laneLength + track.halfCircle / 2 + 0.1).toDouble(),
        )!;
        final cdx = chicaneMarkerA.dx - chicaneMarkerB.dx;
        final cdy = (chicaneMarkerA.dy - chicaneMarkerB.dy).abs();

        expect(cdx, closeTo(0.0, displayEps));
        expect(sdx, closeTo(cdy, displayEps));
      });
    }
  });

  group('trackMarker general continuity', () {
    final rnd = Random();
    for (var lengthFactor in getRandomDoubles(repetition, 1.5, rnd)) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        name: "ForCalculations",
        kind: TrackKind.forLand,
        radiusBoost: 0.65 + rnd.nextDouble(),
      )..lengthFactor = lengthFactor;
      final calculator = TrackCalculator(track: track);
      final size = Size(
        minPixel + rnd.nextDouble() * maxPixel,
        minPixel + rnd.nextDouble() * maxPixel,
      );
      calculator.calculateConstantsOnDemand(size);

      final unitDistance = calculator.trackRadius! / track.radius;
      final uDSquare = unitDistance * unitDistance;
      test("$size ${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        for (var distance in List<int>.generate((track.length * 2).round(), (index) => index)) {
          final markerA = calculator.trackMarker(distance.toDouble())!;
          final markerB = calculator.trackMarker((distance + 1).toDouble())!;
          final dx = markerA.dx - markerB.dx;
          final dy = markerA.dy - markerB.dy;

          expect(dx * dx + dy * dy, closeTo(uDSquare, track.length * displayEps));
        }
      });
    }
  });
}
