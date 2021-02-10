import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/track/constants.dart';
import '../lib/track/tracks.dart';
import '../lib/track/utils.dart';
import 'utils.dart';

void main() {
  test('calculateGPS start point is invariant', () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );

      final marker = calculateGPS(0, track);

      expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, 1e-6));
      expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf, 1e-6));
    });
  });

  test('calculateGPS whole laps are at the start point', () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final distance = laps * TRACK_LENGTH * lengthFactor;

      final marker = calculateGPS(distance, track);

      expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, 1e-6));
      expect(marker.dy, closeTo(track.center.dy + track.gpsLaneHalf, 1e-6));
    });
  });

  test('calculateGPS on the first (left) straight is placed proportionally',
      () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance =
          laps * TRACK_LENGTH * lengthFactor + positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * track.lengthFactor;
      final d = distance % trackLength;
      final displacement = -d * track.verticalMeter;

      final marker = calculateGPS(distance, track);

      expect(marker.dx, closeTo(track.center.dx - track.gpsRadius, 1e-6));
      expect(marker.dy,
          closeTo(track.center.dy + track.gpsLaneHalf + displacement, 1e-6));
    });
  });

  test('calculateGPS on the first (top) chicane is placed proportionally',
      () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = laps * TRACK_LENGTH * lengthFactor +
          track.laneLength +
          positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final rad = (d - track.laneLength) / track.halfCircle * pi;

      final marker = calculateGPS(distance, track);

      expect(
          marker.dx,
          closeTo(
              track.center.dx - cos(rad) * track.radius * track.horizontalMeter,
              1e-6));
      expect(
          marker.dy,
          closeTo(
              track.center.dy -
                  track.gpsLaneHalf -
                  sin(rad) * track.radius * track.verticalMeter,
              1e-6));
    });
  });

  test('calculateGPS on the second (right) straight is placed proportionally',
      () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
        radiusBoost: 1 + rnd.nextDouble() / 3,
        horizontalMeter: rnd.nextDouble() / 10000,
        verticalMeter: rnd.nextDouble() / 10000,
        lengthFactor: lengthFactor,
      );
      final laps = rnd.nextInt(100);
      final positionRatio = rnd.nextDouble();
      final distance = (laps + 0.5) * TRACK_LENGTH * lengthFactor +
          positionRatio * track.laneLength;
      final trackLength = TRACK_LENGTH * lengthFactor;
      final d = distance % trackLength;
      final displacement = (d - trackLength / 2) * track.verticalMeter;

      final marker = calculateGPS(distance, track);

      expect(marker.dx, closeTo(track.center.dx + track.gpsRadius, 1e-6));
      expect(marker.dy,
          closeTo(track.center.dy - track.gpsLaneHalf + displacement, 1e-6));
    });
  });

  test('calculateGPS on the second (bottom) chicane is placed proportionally',
      () async {
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    getRandomDoubles(count, 2, rnd).forEach((lengthFactor) {
      final track = TrackDescriptor(
        center:
            Offset(rnd.nextDouble() * 360 - 180, rnd.nextDouble() * 180 - 90),
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
      final rad =
          (d - trackLength / 2 - track.laneLength) / track.halfCircle * pi;

      final marker = calculateGPS(distance, track);

      expect(
          marker.dx,
          closeTo(
              track.center.dx + cos(rad) * track.radius * track.horizontalMeter,
              1e-6));
      expect(
          marker.dy,
          closeTo(
              track.center.dy +
                  track.gpsLaneHalf +
                  sin(rad) * track.radius * track.verticalMeter,
              1e-6));
    });
  });
}
