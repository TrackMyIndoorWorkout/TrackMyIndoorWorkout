import 'dart:math';

import 'package:flutter/material.dart';
import '../ui/recording.dart';
import 'constants.dart';

Offset calculateTrackMarker(Size size, double distance) {
  if (size == null || RecordingState.trackRadius == null) return null;
  final r = RecordingState.trackRadius;
  final offset = RecordingState.trackOffset;

  final d = distance % TRACK_LENGTH;
  if (d <= LANE_LENGTH) {
    // top straight
    final displacement = d / LANE_LENGTH * pi * LANE_SHRINK / RADIUS_BOOST * r;
    return Offset(
        size.width - THICK - offset.dx - r - displacement, THICK + offset.dy);
  } else if (d <= TRACK_LENGTH / 2) {
    // left half circle
    final rad = (1 - (d - LANE_LENGTH) / HALF_CIRCLE) * pi;
    return Offset((1 - sin(rad)) * r + THICK + offset.dx,
        (cos(rad) + 1) * r + THICK + offset.dy);
  } else if (d <= TRACK_LENGTH / 2 + LANE_LENGTH) {
    // bottom straight
    final displacement = (d - TRACK_LENGTH / 2) /
        LANE_LENGTH *
        pi *
        LANE_SHRINK /
        RADIUS_BOOST *
        r;
    return Offset(
        THICK + offset.dx + r + displacement, size.height - THICK - offset.dy);
  } else {
    // right half circle
    final rad = (2 + (d - TRACK_LENGTH / 2 - LANE_LENGTH) / HALF_CIRCLE) * pi;
    return Offset(size.width - THICK - offset.dx - (1 - sin(rad)) * r,
        r * (cos(rad) + 1) + THICK + offset.dy);
  }
}

Offset calculateGPS(double distance) {
  final d = distance % TRACK_LENGTH;

  if (d <= LANE_LENGTH) {
    // left straight
    final displacement = -d * NS_METER;
    return Offset(trackCenter.dx - EW_RADIUS,
        trackCenter.dy + NS_LANE_HALF + displacement);
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (d - LANE_LENGTH) / HALF_CIRCLE * pi;
    return Offset(trackCenter.dx - cos(rad) * RADIUS * EW_METER,
        trackCenter.dy - NS_LANE_HALF - sin(rad) * RADIUS * NS_METER);
  } else if (d <= TRACK_LENGTH / 2 + LANE_LENGTH) {
    // right straight
    final displacement = (d - TRACK_LENGTH / 2) * NS_METER;
    return Offset(trackCenter.dx + EW_RADIUS,
        trackCenter.dy - NS_LANE_HALF + displacement);
  } else {
    // bottom half circle
    final rad = (d - TRACK_LENGTH / 2 - LANE_LENGTH) / HALF_CIRCLE * pi;
    return Offset(trackCenter.dx + cos(rad) * RADIUS * EW_METER,
        trackCenter.dy + NS_LANE_HALF + sin(rad) * RADIUS * NS_METER);
  }
}
