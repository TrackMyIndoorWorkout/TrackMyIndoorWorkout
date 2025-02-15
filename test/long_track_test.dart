import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/track/track_manager.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  test("Long track length factors is nominal", () async {
    final trackManager = TrackManager();
    expect(trackManager.longTrack.lengthFactor, closeTo(4.15, eps));
  });

  test("Haversine and Vincenty distances are very close on the straight", () async {
    final trackManager = TrackManager();
    final calculator = TrackCalculator(track: trackManager.longTrack);

    final gpsA = calculator.gpsCoordinates(0);
    final gpsB = calculator.gpsCoordinates(50);

    final haversineDistance = TrackCalculator.haversineDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
    expect(haversineDistance, closeTo(50, 0.17));

    final vincentyDistance = TrackCalculator.vincentyDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
    expect(vincentyDistance, closeTo(50, 0.1));

    expect(haversineDistance, closeTo(vincentyDistance, 0.5));
  });

  test("Haversine and Vincenty distances are very close across the chicane", () async {
    final trackManager = TrackManager();
    final calculator = TrackCalculator(track: trackManager.longTrack);

    final gpsA = calculator.gpsCoordinates(trackManager.longTrack.laneLength);
    final gpsB = calculator.gpsCoordinates(
      trackManager.longTrack.laneLength + trackManager.longTrack.halfCircle,
    );

    final expected = trackManager.longTrack.halfCircle / pi * 2.0;
    final haversineDistance = TrackCalculator.haversineDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
    expect(haversineDistance, closeTo(expected, 1.0));

    final vincentyDistance = TrackCalculator.vincentyDistance(gpsA.dy, gpsA.dx, gpsB.dy, gpsB.dx);
    expect(vincentyDistance, closeTo(expected, 1.1501));

    expect(haversineDistance, closeTo(vincentyDistance, 0.62));
  });

  test("Walking the track ends up with the expected length", () async {
    final trackManager = TrackManager();
    final calculator = TrackCalculator(track: trackManager.longTrack);
    double haversineLap = 0.0;
    double vincentyLap = 0.0;
    int steps = trackManager.longTrack.length.toInt();
    Offset currentGps = calculator.gpsCoordinates(0.0);
    for (var i in List<int>.generate(steps, (index) => index)) {
      final nextGps = calculator.gpsCoordinates(i.toDouble());
      haversineLap += TrackCalculator.haversineDistance(
        currentGps.dy,
        currentGps.dx,
        nextGps.dy,
        nextGps.dx,
      );
      vincentyLap += TrackCalculator.vincentyDistance(
        currentGps.dy,
        currentGps.dx,
        nextGps.dy,
        nextGps.dx,
      );
      currentGps = nextGps;
    }

    expect(haversineLap, closeTo(trackManager.longTrack.length, 3.82));
    expect(vincentyLap, closeTo(trackManager.longTrack.length, 2.86));
  });

  test("Horizontal and vertical meter is close to what expected", () async {
    final trackManager = TrackManager();
    final distanceMeter = TrackCalculator.degreesPerMeter(trackManager.longTrack.center.dy);
    expect(distanceMeter.dx, closeTo(trackManager.longTrack.horizontalMeter, 1e-10));
    expect(distanceMeter.dy, closeTo(trackManager.longTrack.verticalMeter, 1e-10));
  });
}
