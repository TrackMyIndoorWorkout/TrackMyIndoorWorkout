import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'track_descriptor.dart';

class TrackCalculator {
  TrackDescriptor track;

  // Cached variables
  Size? trackSize;
  Paint? trackStroke;
  Path? trackPath;
  Offset? trackOffset;
  double? trackRadius;

  TrackCalculator({required this.track});

  void calculateConstantsOnDemand(Size size) {
    if (trackSize == null || size.width != trackSize!.width || size.height != trackSize!.height) {
      trackSize = size;
      final rX = (size.width - 2 * thick) / (2 + pi / track.radiusBoost * track.laneShrink);
      final rY = (size.height - 2 * thick) / 2;
      final r = min(rY, rX);
      trackRadius = r;

      final offset = Offset(
        rX < rY
            ? 0
            : (size.width - 2 * (thick + r) - r * pi / track.radiusBoost * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (thick + r)) / 2,
      );
      trackOffset = offset;

      trackStroke = Paint()
        ..color = const Color(0xff777777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * thick
        ..isAntiAlias = true;

      final leftHalfCircleRect = Rect.fromCircle(
        center: Offset(
          thick + offset.dx + r,
          thick + offset.dy + r,
        ),
        radius: r,
      );

      final rightHalfCircleRect = Rect.fromCircle(
        center: Offset(
          size.width - (thick + offset.dx + r),
          thick + offset.dy + r,
        ),
        radius: r,
      );

      trackPath = Path()
        ..moveTo(thick + offset.dx + r, thick + offset.dy)
        ..lineTo(size.width - (thick + offset.dx + r), thick + offset.dy)
        ..arcTo(rightHalfCircleRect, 1.5 * pi, pi, true)
        ..lineTo(thick + offset.dx + r, thick + offset.dy + 2 * r)
        ..arcTo(leftHalfCircleRect, 0.5 * pi, pi, true);
    }
  }

  Offset? trackMarker(double distance) {
    // distance in meters
    if (trackSize == null || trackRadius == null) return null;

    final r = trackRadius!;
    final offset = trackOffset!;

    final trackLen = track.length;
    final d = (distance) % trackLen;
    if (d <= track.laneLength) {
      // bottom straight
      final displacement = d * r / track.radius;
      return Offset(
        thick + offset.dx + r + displacement,
        trackSize!.height - thick - offset.dy,
      );
    } else if (d <= trackLen / 2) {
      // right half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      return Offset(
        trackSize!.width - (thick + offset.dx + r) + sin(rad) * r,
        thick + r + offset.dy + cos(rad) * r,
      );
    } else if (d <= trackLen / 2 + track.laneLength) {
      // top straight
      final displacement = (d - trackLen / 2) * r / track.radius;
      return Offset(
        trackSize!.width - (thick + offset.dx + r) - displacement,
        thick + offset.dy,
      );
    } else {
      // left half circle
      final rad = (trackLen - d) / track.halfCircle * pi;
      return Offset(
        (1 - sin(rad)) * r + thick + offset.dx,
        (cos(rad) + 1) * r + thick + offset.dy,
      );
    }
  }

  Offset gpsCoordinates(double distance) {
    final trackLen = track.length;
    final d = distance % trackLen;

    var c = const Offset(0, 0); // Relative to GPS track center, not GPS scaled
    if (d <= track.laneLength) {
      // left straight
      c = Offset(
        -track.radius,
        track.laneHalf - d,
      );
    } else if (d <= trackLen / 2) {
      // top half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      c = Offset(
        -cos(rad) * track.radius,
        -track.laneHalf - sin(rad) * track.radius,
      );
    } else if (d <= trackLen / 2 + track.laneLength) {
      // right straight
      final displacement = (d - trackLen / 2);
      c = Offset(
        track.radius,
        -track.laneHalf + displacement,
      );
    } else {
      // bottom half circle
      final rad = (d - trackLen / 2 - track.laneLength) / track.halfCircle * pi;
      c = Offset(
        cos(rad) * track.radius,
        track.laneHalf + sin(rad) * track.radius,
      );
    }

    // lon, lat order!
    return Offset(
      track.center.dx + c.dx * track.horizontalMeter,
      track.center.dy + c.dy * track.verticalMeter,
    );
  }

  // https://stackoverflow.com/a/56499934/292502
  static double distanceInKmBetweenEarthCoordinates(lat1, lon1, lat2, lon2) {
    final dLat = (lat2 - lat1) * degreesToRadians;
    final dLon = (lon2 - lon1) * degreesToRadians;

    final latSin = sin(dLat / 2.0);
    final lonSin = sin(dLon / 2.0);

    var a = latSin * latSin +
        lonSin * lonSin * cos(lat1 * degreesToRadians) * cos(lat2 * degreesToRadians);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
