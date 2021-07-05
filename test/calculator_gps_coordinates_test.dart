import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/tracks.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("gpsCoordinates start point is invariant", () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);

      test("${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor",
          () {
        final marker = calculator.gpsCoordinates(0);

        expect(marker.dx, closeTo(track.center.dx - track.radius * track.horizontalMeter, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.laneHalf * track.verticalMeter, EPS));
      });
    });
  });

  group('gpsCoordinates whole laps are at the start point', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final distance = laps * TRACK_LENGTH * lengthFactor;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.radius * track.horizontalMeter, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.laneHalf * track.verticalMeter, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (left) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * track.lengthFactor;
      final d = distance % trackLength;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.radius * track.horizontalMeter, EPS));
        expect(marker.dy,
            closeTo(track.center.dy + (track.laneLength / 2 - d) * track.verticalMeter, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (top) chicane are placed as expected', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          laps * TRACK_LENGTH * lengthFactor + track.laneLength + positionRatio * track.halfCircle;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx,
            closeTo(track.center.dx - cos(rad) * track.radius * track.horizontalMeter, EPS));
        expect(
            marker.dy,
            closeTo(
                track.center.dy -
                    (track.laneLength / 2 + sin(rad) * track.radius) * track.verticalMeter,
                EPS));
      });
    });
  });

  group('gpsCoordinates on the second (right) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          (laps + 0.5) * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final displacement = d - trackLength / 2;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx + track.radius * track.horizontalMeter, EPS));
        expect(
            marker.dy,
            closeTo(track.center.dy + (displacement - track.laneLength / 2) * track.verticalMeter,
                EPS));
      });
    });
  });

  group('gpsCoordinates on the second (bottom) chicane are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = (laps + 0.5) * TRACK_LENGTH * lengthFactor +
          track.laneLength +
          positionRatio * track.halfCircle;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final rad = (d - trackLength / 2 - track.laneLength) / track.halfCircle * pi;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx,
            closeTo(track.center.dx + cos(rad) * track.radius * track.horizontalMeter, EPS));
        expect(
            marker.dy,
            closeTo(
                track.center.dy +
                    (track.laneLength / 2 + sin(rad) * track.radius) * track.verticalMeter,
                EPS));
      });
    });
  });

  group('gpsCoordinates left continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);

      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = laps * trackLength + track.laneLength;
      final d =
          track.horizontalMeter * track.horizontalMeter + track.verticalMeter * track.verticalMeter;
      test("${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.gpsCoordinates((distance - 0.5).toDouble());
        final markerB = calculator.gpsCoordinates((distance + 0.5).toDouble());
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(d, EPS));
      });
    });
  });

  group('gpsCoordinates right continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);

      final laps = rnd.nextInt(100);
      final trackLength = TRACK_LENGTH * lengthFactor;
      final distance = (laps + 0.5) * trackLength + track.laneLength;
      final d =
          track.horizontalMeter * track.horizontalMeter + track.verticalMeter * track.verticalMeter;
      test("${track.radiusBoost} $lengthFactor ${calculator.trackRadius}", () async {
        final markerA = calculator.gpsCoordinates((distance - 0.5).toDouble());
        final markerB = calculator.gpsCoordinates((distance + 0.5).toDouble());
        final dx = markerA.dx - markerB.dx;
        final dy = markerA.dy - markerB.dy;

        expect(dx * dx + dy * dy, closeTo(d, EPS));
      });
    });
  });

  group('gpsCoordinates continuity straight vs chicane', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);

      test("${track.radiusBoost} $lengthFactor", () async {
        final straightMarkerA = calculator.gpsCoordinates((track.laneHalf - 0.1).toDouble());
        final straightMarkerB = calculator.gpsCoordinates((track.laneHalf + 0.1).toDouble());
        final sdx = straightMarkerA.dx - straightMarkerB.dx;
        final sdy = (straightMarkerA.dy - straightMarkerB.dy).abs();
        expect(sdx, closeTo(0.0, EPS));

        final chicaneMarkerA =
            calculator.gpsCoordinates((track.laneLength + track.halfCircle / 2 - 0.1).toDouble());
        final chicaneMarkerB =
            calculator.gpsCoordinates((track.laneLength + track.halfCircle / 2 + 0.1).toDouble());
        final cdx = (chicaneMarkerA.dx - chicaneMarkerB.dx).abs();
        final cdy = chicaneMarkerA.dy - chicaneMarkerB.dy;

        expect(cdy, closeTo(0.0, EPS));
        expect(sdy, closeTo(cdx, DISPLAY_EPS));
      });
    });
  });

  group('gpsCoordinates general continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 1.5, rnd).forEach((lengthFactor) {
      lengthFactor += 0.7;
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 0.65 + rnd.nextDouble(),
        horizontalMeter: 0.00001 + rnd.nextDouble() / 10000,
        verticalMeter: 0.00001 + rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final d =
          track.horizontalMeter * track.horizontalMeter + track.verticalMeter * track.verticalMeter;
      test("${track.radiusBoost} $lengthFactor $d", () async {
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final calculator = TrackCalculator(track: track);

          final markerA = calculator.gpsCoordinates(distance.toDouble());
          final markerB = calculator.gpsCoordinates((distance + 1).toDouble());
          final dx = markerA.dx - markerB.dx;
          final dy = markerA.dy - markerB.dy;

          expect(dx * dx + dy * dy, closeTo(d, EPS));
        });
      });
    });
  });
}
