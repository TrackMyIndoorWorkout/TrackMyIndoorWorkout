import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/track/calculator.dart';
import '../lib/track/constants.dart';
import '../lib/track/tracks.dart';
import '../lib/utils/constants.dart';
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
          () {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (left) straight is placed proportionally', () {
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
          () {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf + displacement, EPS));
      });
    });
  });

  group('gpsCoordinates on the first (top) chicane is placed proportionally', () {
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
          () {
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

  group('gpsCoordinates on the second (right) straight is placed proportionally', () {
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
          () {
        final marker = calculator.gpsCoordinates(distance);

        expect(marker.dx, closeTo(track.center.dx + track.gpsRadius, EPS));
        expect(marker.dy, closeTo(track.center.dy - track.gpsLaneHalf + displacement, EPS));
      });
    });
  });

  group('gpsCoordinates on the second (bottom) chicane is placed proportionally', () {
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
          () {
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
}
