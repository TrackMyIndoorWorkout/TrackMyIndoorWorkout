import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'tracks.dart';

class TrackCalculator {
  TrackDescriptor track;

  // Cached variables
  Size? trackSize;
  Paint? trackStroke;
  Path? trackPath;
  Offset? trackOffset;
  double? trackRadius;

  TrackCalculator({required this.track});

  Offset? trackMarker(double distance) {
    if (trackSize == null || trackRadius == null) return null;

    final r = trackRadius!;
    final offset = trackOffset!;

    final trackLength = TRACK_LENGTH * track.lengthFactor;
    final d = (distance) % trackLength;
    if (d <= track.laneLength) {
      // bottom straight
      final displacement = d * r / track.radius;
      return Offset(THICK + offset.dx + r + displacement, trackSize!.height - THICK - offset.dy);
    } else if (d <= trackLength / 2) {
      // right half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      return Offset(trackSize!.width - (THICK + offset.dx + r) + sin(rad) * r,
          r + THICK + offset.dy + cos(rad) * r);
    } else if (d <= trackLength / 2 + track.laneLength) {
      // top straight
      final displacement = (d - trackLength / 2) * r / track.radius;
      return Offset(trackSize!.width - (THICK + offset.dx + r) - displacement, THICK + offset.dy);
    } else {
      // left half circle
      final rad = (trackLength - d) / track.halfCircle * pi;
      return Offset((1 - sin(rad)) * r + THICK + offset.dx, (cos(rad) + 1) * r + THICK + offset.dy);
    }
  }

  Offset gpsCoordinates(double distance) {
    final trackLength = TRACK_LENGTH * track.lengthFactor;
    final d = distance % trackLength;

    if (d <= track.laneLength) {
      // left straight
      final displacement = -d * track.verticalMeter;
      return Offset(
          track.center.dx - track.gpsRadius, track.center.dy + track.gpsLaneHalf + displacement);
    } else if (d <= trackLength / 2) {
      // top half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      return Offset(track.center.dx - cos(rad) * track.radius * track.horizontalMeter,
          track.center.dy - track.gpsLaneHalf - sin(rad) * track.radius * track.verticalMeter);
    } else if (d <= trackLength / 2 + track.laneLength) {
      // right straight
      final displacement = (d - trackLength / 2) * track.verticalMeter;
      return Offset(
          track.center.dx + track.gpsRadius, track.center.dy - track.gpsLaneHalf + displacement);
    } else {
      // bottom half circle
      final rad = (d - trackLength / 2 - track.laneLength) / track.halfCircle * pi;
      return Offset(track.center.dx + cos(rad) * track.radius * track.horizontalMeter,
          track.center.dy + track.gpsLaneHalf + sin(rad) * track.radius * track.verticalMeter);
    }
  }
}
