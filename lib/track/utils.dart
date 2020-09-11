import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart';

double calculateTrackMarker(Size size, double distance, bool horizontal) {
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
    if (horizontal) return THICK + offset.dx;
    final displacement =
        (1 - d / straight) * pi * LANE_SHRINK / RADIUS_BOOST * r;
    return r + THICK + offset.dy + displacement;
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (1 - (d - straight) / halfCircle) * pi;
    if (horizontal) return (cos(rad) + 1) * r + THICK + offset.dx;
    return (1 - sin(rad)) * r + THICK + offset.dy;
  } else if (d <= TRACK_LENGTH / 2 + straight) {
    // right straight
    if (horizontal) return 2 * r + THICK + offset.dx;
    final displacement =
        (d - TRACK_LENGTH / 2) / straight * pi * LANE_SHRINK / RADIUS_BOOST * r;
    return r + THICK + offset.dy + displacement;
  } else {
    // bottom half circle
    final rad = (2 + (d - TRACK_LENGTH / 2 - straight) / halfCircle) * pi;
    if (horizontal) return (cos(rad) + 1) * r + THICK + offset.dx;
    return size.height - THICK - offset.dy - r * (1 - sin(rad));
  }
}

Offset calculateGPS(double distance) {
  final d = distance % TRACK_LENGTH;

  if (d <= LANE_LENGTH) {
    // left straight
    final displacement = (1 - d / LANE_LENGTH) * LANE_LENGTH * LAT_METER;
    return Offset(
        trackCenter.dx - LON_RADIUS, trackCenter.dy + LANE_HALF + displacement);
  } else if (d <= TRACK_LENGTH / 2) {
    // top half circle
    final rad = (1 - (d - LANE_LENGTH) / HALF_CIRCLE) * pi;
    return Offset(trackCenter.dx + (cos(rad) + 1) * RADIUS * LON_METER,
        trackCenter.dy - LANE_HALF + (1 - sin(rad)) * RADIUS * LAT_METER);
  } else if (d <= TRACK_LENGTH / 2 + LANE_LENGTH) {
    // right straight
    final displacement = (d - TRACK_LENGTH / 2) * LANE_LENGTH * LAT_METER;
    return Offset(
        trackCenter.dx + LON_RADIUS, trackCenter.dy - LANE_HALF + displacement);
  } else {
    // bottom half circle
    final rad = (2 + (d - TRACK_LENGTH / 2 - LANE_LENGTH) / HALF_CIRCLE) * pi;
    return Offset(trackCenter.dx + (cos(rad) + 1) * RADIUS * LON_METER,
        trackCenter.dy + LANE_HALF + (1 - sin(rad)) * RADIUS * LAT_METER);
  }
}
