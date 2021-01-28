import 'dart:math';

import 'package:flutter/material.dart';
import '../tcx/activity_type.dart';
import 'constants.dart';

class TrackDescriptor {
  final String sport; // What sport is it intended for?
  final Offset center; // lon, lat
  final double radiusBoost;
  final double horizontalMeter; // in GPS coordinates
  final double verticalMeter; // in GPS coordinates
  final double altitude; // in meters
  final double lengthFactor;

  double get halfCircle =>
      TRACK_QUARTER * lengthFactor * radiusBoost; // length in meters
  double get laneShrink => 2.0 - radiusBoost; // almost a reverse ratio
  double get laneLength =>
      TRACK_QUARTER * lengthFactor * laneShrink; // the straight section
  double get radius => halfCircle / pi;
  double get gpsRadius => radius * horizontalMeter; // lon
  double get gpsLaneHalf => laneLength / 2.0 * horizontalMeter;

  TrackDescriptor({
    this.sport,
    this.radiusBoost,
    this.center,
    this.horizontalMeter,
    this.verticalMeter,
    this.altitude,
    this.lengthFactor,
  });
}

Map<String, TrackDescriptor> trackMap = {
  "Marymoor": TrackDescriptor(
    sport: ActivityType.Ride,
    center: Offset(-122.112045, 47.665821),
    radiusBoost: 1.2,
    horizontalMeter: 0.000013356,
    verticalMeter: 0.000008993,
    altitude: 6.0,
    lengthFactor: 1.0,
  ),
  "Lincoln": TrackDescriptor(
    sport: ActivityType.Run,
    center: Offset(-119.77381, 36.846039),
    radiusBoost: 1.18,
    horizontalMeter: 0.00001121,
    verticalMeter: 0.00000901,
    altitude: 108.0,
    lengthFactor: 1.0,
  ),
  "Hoover": TrackDescriptor(
    sport: ActivityType.Run,
    center: Offset(-119.768433, 36.8195),
    radiusBoost: 1.15,
    horizontalMeter: 0.000011156,
    verticalMeter: 0.000009036,
    altitude: 100.0,
    lengthFactor: 1.0,
  ),
  "Painting": TrackDescriptor(
    radiusBoost: 1.2,
    lengthFactor: 1.0,
  ),
  "SanJoaquinBluffPointe": TrackDescriptor(
    sport: ActivityType.Kayaking,
    center: Offset(-119.8730278, 36.84823845),
    radiusBoost: 1.2,
    horizontalMeter: 0.00001121,
    verticalMeter: 0.00000901,
    altitude: 75.0,
    lengthFactor: 1.25, // So track is 500m in length
  ),
};

// For bikes we use a running track and for runs we'll use the velodrome
// So KOMs and CRs won't be disturbed. We mustn't to fit on any segment.
Map<String, String> defaultTrackMap = {
  ActivityType.Ride: "Hoover",
  ActivityType.VirtualRide: "Hoover",
  ActivityType.Run: "Marymoor",
  ActivityType.VirtualRun: "Marymoor",
  ActivityType.Kayaking: "SanJoaquinBluffPointe",
  ActivityType.Canoeing: "SanJoaquinBluffPointe",
  ActivityType.Rowing: "SanJoaquinBluffPointe",
};

TrackDescriptor getDefaultTrack(String sport) {
  return trackMap[defaultTrackMap[sport]];
}
