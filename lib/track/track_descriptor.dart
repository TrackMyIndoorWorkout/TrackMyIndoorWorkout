import 'dart:math';

import 'package:flutter/painting.dart';

import '../utils/constants.dart';
import 'constants.dart';
import 'track_kind.dart';

class TrackDescriptor {
  final String name;
  final TrackKind kind;
  late Offset center; // lon, lat order!!!
  final double radiusBoost;
  final double horizontalMeter; // in GPS coordinates
  final double verticalMeter; // in GPS coordinates
  final double altitude; // in meters
  late double lengthFactor;

  double get halfCircle => trackQuarter * lengthFactor * radiusBoost; // length in meters
  double get laneShrink => 2.0 - radiusBoost; // almost a reverse ratio
  double get laneLength => trackQuarter * lengthFactor * laneShrink; // the straight section
  double get radius => halfCircle / pi;
  double get laneHalf => laneLength / 2.0;
  double get length => trackLength * lengthFactor;

  TrackDescriptor({
    required this.name,
    required this.kind,
    required this.radiusBoost,
    center,
    this.horizontalMeter = eps,
    this.verticalMeter = eps,
    this.altitude = 0.0,
  }) {
    this.center = center ?? const Offset(0, 0);
    lengthFactor =
        kind == TrackKind.forWater ? fiveHundredMTrackLengthFactor : fourHundredMTrackLengthFactor;
  }

  factory TrackDescriptor.forDisplay(String sport) => TrackDescriptor(
    name: "ForDisplay",
    kind: getTrackKindForSport(sport).first,
    radiusBoost: trackPaintingRadiusBoost,
  );
}
