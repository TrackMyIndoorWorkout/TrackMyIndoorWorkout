import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

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

      trackStroke =
          Paint()
            ..color = const Color(0xff777777)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * thick
            ..isAntiAlias = true;

      final leftHalfCircleRect = Rect.fromCircle(
        center: Offset(thick + offset.dx + r, thick + offset.dy + r),
        radius: r,
      );

      final rightHalfCircleRect = Rect.fromCircle(
        center: Offset(size.width - (thick + offset.dx + r), thick + offset.dy + r),
        radius: r,
      );

      trackPath =
          Path()
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
      return Offset(thick + offset.dx + r + displacement, trackSize!.height - thick - offset.dy);
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
      return Offset(trackSize!.width - (thick + offset.dx + r) - displacement, thick + offset.dy);
    } else {
      // left half circle
      final rad = (trackLen - d) / track.halfCircle * pi;
      return Offset((1 - sin(rad)) * r + thick + offset.dx, (cos(rad) + 1) * r + thick + offset.dy);
    }
  }

  Offset gpsCoordinates(double distance) {
    final trackLen = track.length;
    final d = distance % trackLen;

    var c = const Offset(0, 0); // Relative to GPS track center, not GPS scaled
    if (d <= track.laneLength) {
      // left straight
      c = Offset(-track.radius, track.laneHalf - d);
    } else if (d <= trackLen / 2) {
      // top half circle
      final rad = (d - track.laneLength) / track.halfCircle * pi;
      c = Offset(-cos(rad) * track.radius, -track.laneHalf - sin(rad) * track.radius);
    } else if (d <= trackLen / 2 + track.laneLength) {
      // right straight
      final displacement = (d - trackLen / 2);
      c = Offset(track.radius, -track.laneHalf + displacement);
    } else {
      // bottom half circle
      final rad = (d - trackLen / 2 - track.laneLength) / track.halfCircle * pi;
      c = Offset(cos(rad) * track.radius, track.laneHalf + sin(rad) * track.radius);
    }

    // lon, lat order!
    return Offset(
      track.center.dx + c.dx * track.horizontalMeter,
      track.center.dy + c.dy * track.verticalMeter,
    );
  }

  // https://stackoverflow.com/a/56499934/292502
  static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = radians(lat2 - lat1);
    final dLon = radians(lon2 - lon1);

    final latSin = sin(dLat / 2.0);
    final lonSin = sin(dLon / 2.0);

    var a = latSin * latSin + lonSin * lonSin * cos(radians(lat1)) * cos(radians(lat2));
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    const earthRadiusM = 6371008; // m
    return earthRadiusM * c;
  }

  static double vincentyDistance(double lat1, double lon1, double lat2, double lon2) {
    // Define WSG84 ellipsoid parameters
    const a = 6378137.0;
    const b = 6356752.314245;
    const f = 1 / 298.257223563;

    double L = radians(lon2 - lon1);
    double u1 = atan((1 - f) * tan(radians(lat1)));
    double u2 = atan((1 - f) * tan(radians(lat2)));
    double sinU1 = sin(u1), cosU1 = cos(u1);
    double sinU2 = sin(u2), cosU2 = cos(u2);

    double lambda = L;
    double lambdaP = 2 * pi;
    int iterationLimit = 100;

    double sinSigma = 0.0;
    double cosSigma = 0.0;
    double sigma = 0.0;
    double cosSqAlpha = 0.0;
    double cos2SigmaM = 0.0;

    while ((lambda - lambdaP).abs() > 1e-12 && --iterationLimit > 0) {
      double sinLambda = sin(lambda), cosLambda = cos(lambda);
      sinSigma = sqrt(
        pow(cosU2 * sinLambda, 2) + pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2),
      );
      if (sinSigma == 0) return 0; // co-incident points
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      double sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1.0 - pow(sinAlpha, 2);
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      if (cos2SigmaM.isNaN) cos2SigmaM = 0; // equatorial line: cosSqAlpha=0 (§6)
      double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda =
          L +
          (1 - C) *
              f *
              sinAlpha *
              (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * pow(cos2SigmaM, 2))));
    }

    // formula failed to converge
    if (iterationLimit == 0) return double.nan;

    double uSq = cosSqAlpha * (pow(a, 2) - pow(b, 2)) / pow(b, 2);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma =
        B *
        sinSigma *
        (cos2SigmaM +
            B /
                4 *
                (cosSigma * (-1 + 2 * pow(cos2SigmaM, 2)) -
                    B /
                        6 *
                        cos2SigmaM *
                        (-3 + 4 * pow(sinSigma, 2)) *
                        (-3 + 4 * pow(cos2SigmaM, 2))));

    return b * A * (sigma - deltaSigma);
  }

  static Offset degreesPerMeter(double latitude) {
    // WGS-84 ellipsoid parameters
    const a = 6378137.0;
    const b = 6356752.314245;

    double e2 = 1.0 - pow(b / a, 2);
    double phi = radians(latitude);
    double sinPhi = sin(phi);
    double cosPhi = cos(phi);
    double e2SinPhiSq = e2 * sinPhi * sinPhi;
    double N = a / sqrt(1 - e2SinPhiSq);
    double R = N * (1 - e2) / (1 - e2SinPhiSq);

    double tmp = a * (1 - e2) / pow(1 - e2SinPhiSq, 1.5);
    double D = sqrt(1 - e2SinPhiSq);
    double S = tmp * D;

    return Offset(degrees(1 / (R * cosPhi)), degrees(1 / S)); // lon, lat
  }
}
