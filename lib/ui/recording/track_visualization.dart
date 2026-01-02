import 'package:flutter/material.dart';
import '../../track/calculator.dart';
import '../../track/track_painter.dart';

class TrackVisualization extends StatelessWidget {
  const TrackVisualization({
    super.key,
    required this.calculator,
    required this.markers,
    required this.width,
  });

  final TrackCalculator calculator;
  final List<Widget> markers;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrackPainter(calculator: calculator),
      child: SizedBox(
        width: width,
        height: width / 1.9,
        child: Stack(children: markers),
      ),
    );
  }
}
