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

  void calculateConstantsOnDemand(Size size) {
    if (trackSize == null || size.width != trackSize!.width || size.height != trackSize!.height) {
      trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 + pi / track.radiusBoost * track.laneShrink);
      final rY = (size.height - 2 * THICK) / 2;
      final r = min(rY, rX);
      trackRadius = r;

      final offset = Offset(
        rX < rY
            ? 0
            : (size.width - 2 * (THICK + r) - r * pi / track.radiusBoost * track.laneShrink) / 2,
        rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2,
      );
      trackOffset = offset;

      trackStroke = Paint()
        ..color = Color(0x88777777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * THICK
        ..isAntiAlias = true;

      final leftHalfCircleRect = Rect.fromCircle(
        center: Offset(
          THICK + offset.dx + r,
          THICK + offset.dy + r,
        ),
        radius: r,
      );

      final rightHalfCircleRect = Rect.fromCircle(
        center: Offset(
          size.width - (THICK + offset.dx + r),
          THICK + offset.dy + r,
        ),
        radius: r,
      );

      trackPath = Path()
        ..moveTo(THICK + offset.dx + r, THICK + offset.dy)
        ..lineTo(size.width - (THICK + offset.dx + r), THICK + offset.dy)
        ..arcTo(rightHalfCircleRect, 1.5 * pi, pi, true)
        ..lineTo(THICK + offset.dx + r, THICK + offset.dy + 2 * r)
        ..arcTo(leftHalfCircleRect, 0.5 * pi, pi, true);
    }
  }

  Offset? trackMarker(double distance) {
    if (trackSize == null || trackRadius == null) return null;

    final r = trackRadius!;
    final offset = trackOffset!;

    final trackLength = TRACK_LENGTH * track.lengthFactor;
    final d = (distance) % trackLength;
    if (d <= track.laneLength) {
      // bottom straight
      final displacement = d * r / track.radius;
      return Offset(
        THICK + offset.dx + r + displacement,
        trackSize!.height - THICK - offset.dy,
      );
    } else if (d <= trackLength / 2) {
      // right half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      return Offset(
        trackSize!.width - (THICK + offset.dx + r) + sin(rad) * r,
        THICK + r + offset.dy + cos(rad) * r,
      );
    } else if (d <= trackLength / 2 + track.laneLength) {
      // top straight
      final displacement = (d - trackLength / 2) * r / track.radius;
      return Offset(
        trackSize!.width - (THICK + offset.dx + r) - displacement,
        THICK + offset.dy,
      );
    } else {
      // left half circle
      final rad = (trackLength - d) / track.halfCircle * pi;
      return Offset(
        (1 - sin(rad)) * r + THICK + offset.dx,
        (cos(rad) + 1) * r + THICK + offset.dy,
      );
    }
  }

  Offset gpsCoordinates(double distance) {
    final trackLength = TRACK_LENGTH * track.lengthFactor;
    final d = distance % trackLength;

    var c = Offset(0, 0); // Relative to GPS track center, not GPS scaled
    if (d <= track.laneLength) {
      // left straight
      c = Offset(
        -track.radius,
        track.laneHalf - d,
      );
    } else if (d <= trackLength / 2) {
      // top half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      c = Offset(
        -cos(rad) * track.radius,
        -track.laneHalf - sin(rad) * track.radius
      );
    } else if (d <= trackLength / 2 + track.laneLength) {
      // right straight
      final displacement = (d - trackLength / 2);
      c = Offset(
        track.radius,
        -track.laneHalf + displacement,
      );
    } else {
      // bottom half circle
      final rad = (d - trackLength / 2 - track.laneLength) / track.halfCircle * pi;
      c = Offset(
        cos(rad) * track.radius,
        track.laneHalf + sin(rad) * track.radius,
      );
    }

    return Offset(
      track.center.dx + c.dx * track.horizontalMeter,
      track.center.dy + c.dy * track.verticalMeter,
    );
  }
}
