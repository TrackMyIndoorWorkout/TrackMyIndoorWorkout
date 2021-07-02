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
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final calculator = TrackCalculator(track: track);

      test("${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor",
          () {
        final marker = calculator.gpsCoordinates(0);

        expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf, EPS));
      });
    });
  });

  group('gpsCoordinates whole laps are at the start point', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final distance = laps * TRACK_LENGTH * lengthFactor;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (left) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * track.lengthFactor;
      final d = distance % trackLength;
      final displacement = -d * track.verticalMeter;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf + displacement, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (top) chicane are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          laps * TRACK_LENGTH * lengthFactor + track.laneLength + positionRatio * track.laneLength;
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
                track.center.dy - track.gpsLaneHalf - sin(rad) * track.radius * track.verticalMeter,
                EPS));
      });
    });
  });

  group('gpsCoordinates on the second (right) straight are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          (laps + 0.5) * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final displacement = (d - trackLength / 2) * track.verticalMeter;
      final calculator = TrackCalculator(track: track);

      test(
          "${track.radiusBoost} ${track.horizontalMeter} ${track.verticalMeter} $lengthFactor $laps $distance",
          () async {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx + track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy - track.gpsLaneHalf + displacement, EPS));
      });
    });
  });

  group('gpsCoordinates on the second (bottom) chicane are placed proportionally', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
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
                track.center.dy + track.gpsLaneHalf + sin(rad) * track.radius * track.verticalMeter,
                EPS));
      });
    });
  });

  group('gpsCoordinates continuity', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center: Offset(rnd.nextDouble() * 360 * 10000 - 180, rnd.nextDouble() * 180 * 10000 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble(), // / 10000,
        verticalMeter: rnd.nextDouble(), // / 10000,
        lengthFactor: lengthFactor,
      );
      final d = track.horizontalMeter * track.horizontalMeter + track.verticalMeter * track.verticalMeter;
      test("${track.radiusBoost} $lengthFactor $d", () async {
        var maxD = 0.0;
        1.to((TRACK_LENGTH * 2).round()).forEach((distance) {
          final calculator = TrackCalculator(track: track);

          final markerA = calculator.gpsCoordinates(distance.toDouble());
          distance++;
          final markerB = calculator.gpsCoordinates(distance.toDouble());
          final dx = markerA.dx - markerB.dx;
          final dy = markerA.dy - markerB.dy;

          // expect(dx * dx + dy * dy, closeTo(d, EPS));
          maxD = max(maxD, dx * dx + dy * dy);
        });
        expect(maxD, lessThanOrEqualTo(d));
      });
    });
  });
}
