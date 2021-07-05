import 'package:flutter/rendering.dart';

import 'calculator.dart';

class TrackPainter extends CustomPainter {
  TrackCalculator calculator;

  TrackPainter({required this.calculator});

  @override
  void paint(Canvas canvas, Size size) {
    calculator.calculateConstantsOnDemand(size);

    canvas.drawPath(calculator.trackPath!, calculator.trackStroke!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
