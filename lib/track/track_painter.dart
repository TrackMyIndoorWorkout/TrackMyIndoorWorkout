import 'package:flutter/rendering.dart';

import 'calculator.dart';
// import 'constants.dart';

class TrackPainter extends CustomPainter {
  TrackCalculator calculator;

  TrackPainter({required this.calculator});

  @override
  void paint(Canvas canvas, Size size) {
    calculator.calculateConstantsOnDemand(size);

    canvas.drawPath(calculator.trackPath!, calculator.trackStroke!);

    // final dotStroke = Paint()
    //   ..color = Color(0x88FF0000)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = THICK
    //   ..isAntiAlias = true;
    // for (var d = 0.0; d < TRACK_LENGTH * calculator.track.lengthFactor; d += 5.0) {
    //   final position = calculator.trackMarker(d);
    //   canvas.drawCircle(position!, THICK / 2, dotStroke);
    // }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
