import 'dart:math';

import 'package:flutter/material.dart';
import '../ui/recording.dart';
import 'constants.dart';
import 'tracks.dart';

Offset calculateTrackMarker(Size size, double distance) {
  final track = trackMap["Painting"];
  if (size == null || RecordingState.trackRadius == null) return null;
  final r = RecordingState.trackRadius;
  final offset = RecordingState.trackOffset;

  final d = distance % TRACK_LENGTH;
  if (d <= track.laneLength) {
    // top straight
    final displacement =
        d / track.laneLength * pi * track.laneShrink / track.radiusBoost * r;
    return Offset(
        size.width - THICK - offset.dx - r - displacement, THICK + offset.dy);
  } else if (d <= TRACK_LENGTH / 2) {
    // left half circle
    final rad = (1 - (d - track.laneLength) / track.halfCircle) * pi;
    return Offset((1 - sin(rad)) * r + THICK + offset.dx,
        (cos(rad) + 1) * r + THICK + offset.dy);
  } else if (d <= TRACK_LENGTH / 2 + track.laneLength) {
    // bottom straight
    final displacement = (d - TRACK_LENGTH / 2) /
        track.laneLength *
        pi *
        track.laneShrink /
        track.radiusBoost *
        r;
    return Offset(
        THICK + offset.dx + r + displacement, size.height - THICK - offset.dy);
  } else {
    // right half circle
    final rad =
        (2 + (d - TRACK_LENGTH / 2 - track.laneLength) / track.halfCircle) * pi;
    return Offset(size.width - THICK - offset.dx - (1 - sin(rad)) * r,
        r * (cos(rad) + 1) + THICK + offset.dy);
  }
}

Offset calculateGPS(double distance, TrackDescriptor track) {
  final d = distance % TRACK_LENGTH;

  if (d <= track.laneLength) {
    // left straight
    final displacement = -d * track.verticalMeter;
    return Offset(track.center.dx - track.gpsRadius,
        track.center.dy + track.gpsLaneHalf + displacement);
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (d - track.laneLength) / track.halfCircle * pi;
    return Offset(
        track.center.dx - cos(rad) * track.radius * track.horizontalMeter,
        track.center.dy -
            track.gpsLaneHalf -
            sin(rad) * track.radius * track.verticalMeter);
  } else if (d <= TRACK_LENGTH / 2 + track.laneLength) {
    // right straight
    final displacement = (d - TRACK_LENGTH / 2) * track.verticalMeter;
    return Offset(track.center.dx + track.gpsRadius,
        track.center.dy - track.gpsLaneHalf + displacement);
  } else {
    // bottom half circle
    final rad =
        (d - TRACK_LENGTH / 2 - track.laneLength) / track.halfCircle * pi;
    return Offset(
        track.center.dx + cos(rad) * track.radius * track.horizontalMeter,
        track.center.dy +
            track.gpsLaneHalf +
            sin(rad) * track.radius * track.verticalMeter);
  }
}
