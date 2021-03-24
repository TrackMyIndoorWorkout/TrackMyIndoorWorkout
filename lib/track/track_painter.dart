import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import 'calculator.dart';
import 'constants.dart';

class TrackPainter extends CustomPainter {
  TrackCalculator calculator;

  TrackPainter({@required this.calculator}) : assert(calculator != null);

  @override
  void paint(Canvas canvas, Size size) {
    final track = calculator.track;
    if (calculator.trackSize == null ||
        size.width != calculator.trackSize.width ||
        size.height != calculator.trackSize.height) {
      calculator.trackSize = size;
      final rX = (size.width - 2 * THICK) / (2 * track.radiusBoost + pi * track.laneShrink);
      final rY = (size.height - 2 * THICK) / (2 * track.radiusBoost);
      final r = min(rY, rX) * track.radiusBoost;
      calculator.trackRadius = r;

      final offset = Offset(
          rX < rY ? 0 : (size.width - 2 * (THICK + r) - pi * r * track.laneShrink) / 2,
          rX > rY ? 0 : (size.height - 2 * (THICK + r)) / 2);
      calculator.trackOffset = offset;

      calculator.trackStroke = Paint()
        ..color = Color(0x88777777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * THICK
        ..isAntiAlias = true;

      final leftHalfCircleRect =
          Rect.fromCircle(center: Offset(r + THICK + offset.dx, r + THICK + offset.dy), radius: r);

      final rightHalfCircleRect = Rect.fromCircle(
          center: Offset(size.width - r - THICK - offset.dx, r + THICK + offset.dy), radius: r);

      calculator.trackPath = Path()
        ..moveTo(THICK + offset.dx + r, THICK + offset.dy)
        ..lineTo(size.width - r - THICK - offset.dx, THICK + offset.dy)
        ..arcTo(rightHalfCircleRect, 1.5 * pi, pi, true)
        ..lineTo(THICK + offset.dx + r, 2 * r + THICK + offset.dy)
        ..arcTo(leftHalfCircleRect, pi / 2, pi, true);
    }

    canvas.drawPath(calculator.trackPath, calculator.trackStroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
