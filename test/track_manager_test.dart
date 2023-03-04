import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/track_kind.dart';
import 'package:track_my_indoor_exercise/track/track_manager.dart';

void main() {
  group("Track length factors are nominal", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("$timeZone ${track.kind} ${track.lengthFactor}", () async {
          final expectedLengthFactor = track.kind == TrackKind.forWater
              ? fiveHundredMTrackLengthFactor
              : fourHundredMTrackLengthFactor;
          expect(track.lengthFactor, expectedLengthFactor);
        });
      }
    }
  });

  group("Haversine and Vincenty distances are very close on the straight", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("${track.name} ${track.length}m ($timeZone)", () async {
          final calculator = TrackCalculator(track: track);

          final gpsA = calculator.gpsCoordinates(0);
          final gpsB = calculator.gpsCoordinates(50);

          final haversineDistance =
              TrackCalculator.haversineDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
          expect(haversineDistance, closeTo(50, 1.8));

          final vincentyDistance =
              TrackCalculator.vincentyDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
          expect(vincentyDistance, closeTo(50, 1.1));

          expect(haversineDistance, closeTo(vincentyDistance, 0.5));
        });
      }
    }
  });

  group("Haversine and Vincenty distances are very close across the chicane", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("${track.name} ${track.length}m ($timeZone)", () async {
          final calculator = TrackCalculator(track: track);

          final gpsA = calculator.gpsCoordinates(track.laneLength);
          final gpsB = calculator.gpsCoordinates(track.laneLength + track.halfCircle);

          final expected = track.halfCircle / pi * 2.0;
          final haversineDistance =
              TrackCalculator.haversineDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
          expect(haversineDistance, closeTo(expected, 0.6));

          final vincentyDistance =
              TrackCalculator.vincentyDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
          expect(vincentyDistance, closeTo(expected, 0.7));

          expect(haversineDistance, closeTo(vincentyDistance, 0.4));
        });
      }
    }
  });

  group("Walking the track ends up with the expected length", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("${track.name} ${track.length}m ($timeZone)", () async {
          final calculator = TrackCalculator(track: track);
          double haversineLap = 0.0;
          double vincentyLap = 0.0;
          int steps = track.length.toInt();
          Offset currentGps = calculator.gpsCoordinates(0.0);
          for (var i in List<int>.generate(steps, (index) => index)) {
            final nextGps = calculator.gpsCoordinates(i.toDouble());
            haversineLap += TrackCalculator.haversineDistance(
                currentGps.dy, currentGps.dx, nextGps.dy, nextGps.dx);
            vincentyLap += TrackCalculator.vincentyDistance(
                currentGps.dy, currentGps.dx, nextGps.dy, nextGps.dx);
            currentGps = nextGps;
          }

          expect(haversineLap, closeTo(track.length, 1.7));
          expect(vincentyLap, closeTo(track.length, 1.7));
        });
      }
    }
  });

  group("Horizontal and vertical meter is close to what expected", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("${track.name} ${track.length}m ($timeZone)", () async {
          final distanceMeter = TrackCalculator.degreesPerMeter(track.center.dy);
          expect(distanceMeter.dx, closeTo(track.horizontalMeter, 1e-10));
          expect(distanceMeter.dy, closeTo(track.verticalMeter, 1e-10));
        });
      }
    }
  });
}
