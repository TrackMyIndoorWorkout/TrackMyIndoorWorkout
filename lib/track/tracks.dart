import 'dart:math';

import 'package:flutter/painting.dart';

import '../utils/constants.dart';
import 'constants.dart';

const trackPaintingRadiusBoost = 1.2;

class TrackDescriptor {
  late Offset center; // lon, lat
  final double radiusBoost;
  final double horizontalMeter; // in GPS coordinates
  final double verticalMeter; // in GPS coordinates
  final double altitude; // in meters
  final double lengthFactor;

  double get halfCircle => trackQuarter * lengthFactor * radiusBoost; // length in meters
  double get laneShrink => 2.0 - radiusBoost; // almost a reverse ratio
  double get laneLength => trackQuarter * lengthFactor * laneShrink; // the straight section
  double get radius => halfCircle / pi;
  double get laneHalf => laneLength / 2.0;

  TrackDescriptor({
    required this.radiusBoost,
    center,
    this.horizontalMeter = eps,
    this.verticalMeter = eps,
    this.altitude = 0.0,
    required this.lengthFactor,
  }) {
    this.center = center ?? const Offset(0, 0);
  }
}

Map<String, TrackDescriptor> trackMap = {
  "Marymoor": TrackDescriptor(
    center: const Offset(-122.112045, 47.665821),
    radiusBoost: 1.2,
    horizontalMeter: 0.000013337,
    verticalMeter: 0.000008985,
    altitude: 6.0,
    lengthFactor: 1.0,
  ),
  "Lincoln": TrackDescriptor(
    center: const Offset(-119.77381, 36.846039),
    radiusBoost: 1.15,
    horizontalMeter: 0.00001121,
    verticalMeter: 0.00000901,
    altitude: 108.0,
    lengthFactor: 1.0,
  ),
  "Hoover": TrackDescriptor(
    center: const Offset(-119.768433, 36.8195),
    radiusBoost: 1.1,
    horizontalMeter: 0.000011156,
    verticalMeter: 0.000009036,
    altitude: 100.0,
    lengthFactor: 1.0,
  ),
  "SanJoaquinBluffPointe": TrackDescriptor(
    center: const Offset(-119.8730278, 36.84823845),
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
  ActivityType.ride: "Hoover",
  ActivityType.virtualRide: "Hoover",
  ActivityType.run: "Marymoor",
  ActivityType.virtualRun: "Marymoor",
  ActivityType.elliptical: "Marymoor",
  ActivityType.stairStepper: "Marymoor",
  ActivityType.kayaking: "SanJoaquinBluffPointe",
  ActivityType.canoeing: "SanJoaquinBluffPointe",
  ActivityType.rowing: "SanJoaquinBluffPointe",
  ActivityType.swim: "SanJoaquinBluffPointe",
};

TrackDescriptor getTrack(String sport) {
  String trackName = defaultTrackMap[sport] ?? "Marymoor";
  return trackMap[trackName]!;
}
