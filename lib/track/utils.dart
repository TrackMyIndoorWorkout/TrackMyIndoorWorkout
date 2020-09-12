import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart';

Offset calculateTrackMarker(Size size, double distance) {
  final rX = (size.width - 2 * THICK) / (2 * RADIUS_BOOST);
  final rY = (size.height - 2 * THICK) / (2 * RADIUS_BOOST + pi * LANE_SHRINK);
  final r = min(rY, rX) * RADIUS_BOOST;
  final offset = Offset(
      rX > rY ? (size.width - 2 * (THICK + r)) / 2 : 0,
      rX < rY
          ? (size.height - 2 * THICK - r * 2 - pi * rX * LANE_SHRINK) / 2
          : 0);

  final d = distance % TRACK_LENGTH;
  final straight = TRACK_QUARTER * LANE_SHRINK;
  final halfCircle = TRACK_QUARTER * RADIUS_BOOST;
  if (d <= straight) {
    // left straight
    final displacement =
        (1 - d / straight) * pi * LANE_SHRINK / RADIUS_BOOST * r;
    return Offset(THICK + offset.dx, r + THICK + offset.dy + displacement);
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (1 - (d - straight) / halfCircle) * pi;
    return Offset((cos(rad) + 1) * r + THICK + offset.dx,
        (1 - sin(rad)) * r + THICK + offset.dy);
  } else if (d <= TRACK_LENGTH / 2 + straight) {
    // right straight
    final displacement =
        (d - TRACK_LENGTH / 2) / straight * pi * LANE_SHRINK / RADIUS_BOOST * r;
    return Offset(
        2 * r + THICK + offset.dx, r + THICK + offset.dy + displacement);
  } else {
    // bottom half circle
    final rad = (2 + (d - TRACK_LENGTH / 2 - straight) / halfCircle) * pi;
    return Offset((cos(rad) + 1) * r + THICK + offset.dx,
        size.height - THICK - offset.dy - r * (1 - sin(rad)));
  }
}

Offset calculateGPS(double distance) {
  final d = distance % TRACK_LENGTH;

  if (d <= LANE_LENGTH) {
    // left straight
    final displacement = -d * LAT_METER;
    return Offset(
        trackCenter.dx - LON_RADIUS, trackCenter.dy + LANE_HALF + displacement);
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (d - LANE_LENGTH) / HALF_CIRCLE * pi;
    return Offset(trackCenter.dx - cos(rad) * RADIUS * LON_METER,
        trackCenter.dy - LANE_HALF - sin(rad) * RADIUS * LAT_METER);
  } else if (d <= TRACK_LENGTH / 2 + LANE_LENGTH) {
    // right straight
    final displacement = (d - TRACK_LENGTH / 2) * LAT_METER;
    return Offset(
        trackCenter.dx + LON_RADIUS, trackCenter.dy - LANE_HALF + displacement);
  } else {
    // bottom half circle
    final rad = (d - TRACK_LENGTH / 2 - LANE_LENGTH) / HALF_CIRCLE * pi;
    return Offset(trackCenter.dx + cos(rad) * RADIUS * LON_METER,
        trackCenter.dy + LANE_HALF + sin(rad) * RADIUS * LAT_METER);
  }
}
