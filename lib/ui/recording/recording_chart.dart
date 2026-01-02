import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import '../models/display_record.dart';

typedef ChartTouchCallback = void Function(charts.ChartTouchInteractionArgs);

class RecordingChart extends StatelessWidget {
  const RecordingChart({
    super.key,
    required this.chartLabelStyle,
    required this.chartTextColor,
    required this.graphViewDuration,
    required this.series,
    this.plotBands = const [],
    required this.onTouchDown,
    required this.onTouchUp,
  });

  final TextStyle chartLabelStyle;
  final Color chartTextColor;
  final double graphViewDuration;
  final List<charts.LineSeries<DisplayRecord, DateTime>> series;
  final List<charts.PlotBand> plotBands;
  final ChartTouchCallback onTouchDown;
  final ChartTouchCallback onTouchUp;

  @override
  Widget build(BuildContext context) {
    return charts.SfCartesianChart(
      primaryXAxis: charts.DateTimeAxis(
        labelStyle: chartLabelStyle,
        axisLine: charts.AxisLine(color: chartTextColor),
        majorTickLines: charts.MajorTickLines(color: chartTextColor),
        minorTickLines: charts.MinorTickLines(color: chartTextColor),
        majorGridLines: charts.MajorGridLines(color: chartTextColor),
        minorGridLines: charts.MinorGridLines(color: chartTextColor),
        autoScrollingDelta: graphViewDuration > 0 ? (graphViewDuration * 60).toInt() : null,
        autoScrollingDeltaType: charts.DateTimeIntervalType.seconds,
        autoScrollingMode: charts.AutoScrollingMode.end,
      ),
      primaryYAxis: charts.NumericAxis(
        plotBands: plotBands,
        labelStyle: chartLabelStyle,
        axisLine: charts.AxisLine(color: chartTextColor),
        majorTickLines: charts.MajorTickLines(color: chartTextColor),
        minorTickLines: charts.MinorTickLines(color: chartTextColor),
        majorGridLines: charts.MajorGridLines(color: chartTextColor),
        minorGridLines: charts.MinorGridLines(color: chartTextColor),
      ),
      margin: const EdgeInsets.all(0),
      series: series,
      onChartTouchInteractionDown: onTouchDown,
      onChartTouchInteractionUp: onTouchUp,
    );
  }
}
