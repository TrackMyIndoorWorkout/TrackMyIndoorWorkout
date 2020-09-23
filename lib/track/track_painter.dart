import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart';

class TrackPainter extends CustomPainter {
  static Size _size;
  static Paint _trackStroke;
  static Path _trackPath;

  @override
  paint(Canvas canvas, Size size) {
    if (_size == null ||
        size.width != _size.width ||
        size.height != _size.height) {
      _size = size;
      final rX = (size.width - 2 * THICK) / (2 * RADIUS_BOOST);
      final rY =
          (size.height - 2 * THICK) / (2 * RADIUS_BOOST + pi * LANE_SHRINK);
      final r = min(rY, rX) * RADIUS_BOOST;
      final offset = Offset(
          rX > rY ? (size.width - 2 * (THICK + r)) / 2 : 0,
          rX < rY
              ? (size.height - 2 * THICK - r * 2 - pi * rX * LANE_SHRINK) / 2
              : 0);

      _trackStroke = Paint()
        ..color = Color(0x88777777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * THICK
        ..isAntiAlias = true;

      final topHalfCircleRect = Rect.fromCircle(
          center: Offset(r + THICK + offset.dx, r + THICK + offset.dy),
          radius: r);

      final bottomHalfCircleRect = Rect.fromCircle(
          center: Offset(
              r + THICK + offset.dx, size.height - r - THICK - offset.dy),
          radius: r);

      _trackPath = Path()
        ..moveTo(THICK + offset.dx,
            THICK + offset.dy + r * (1 + pi * LANE_SHRINK / RADIUS_BOOST))
        ..lineTo(THICK + offset.dx, r + THICK + offset.dy)
        ..arcTo(topHalfCircleRect, pi, pi, true)
        ..lineTo(2 * r + THICK + offset.dx,
            THICK + offset.dy + r * (1 + pi * LANE_SHRINK / RADIUS_BOOST))
        ..arcTo(bottomHalfCircleRect, 0, pi, true);
    }

    canvas.drawPath(_trackPath, _trackStroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
