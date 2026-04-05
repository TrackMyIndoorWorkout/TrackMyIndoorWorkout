import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:track_my_indoor_exercise/ui/recording/recording_chart.dart';
import 'package:track_my_indoor_exercise/ui/models/display_record.dart';

void main() {
  testWidgets('RecordingChart renders SfCartesianChart', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingChart(
            chartLabelStyle: const TextStyle(fontSize: 10),
            chartTextColor: Colors.black,
            graphViewDuration: 10.0,
            series: const <LineSeries<DisplayRecord, DateTime>>[],
            onTouchDown: (_) {},
            onTouchUp: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(SfCartesianChart), findsOneWidget);
  });

  testWidgets('RecordingChart passes plotBands', (WidgetTester tester) async {
    final plotBands = <PlotBand>[PlotBand(start: 0, end: 10, color: Colors.blue)];

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingChart(
            chartLabelStyle: const TextStyle(fontSize: 10),
            chartTextColor: Colors.black,
            graphViewDuration: 10.0,
            series: const <LineSeries<DisplayRecord, DateTime>>[],
            plotBands: plotBands,
            onTouchDown: (_) {},
            onTouchUp: (_) {},
          ),
        ),
      ),
    );

    final chart = tester.widget<SfCartesianChart>(find.byType(SfCartesianChart));
    final yAxis = chart.primaryYAxis as NumericAxis;
    expect(yAxis.plotBands, containsAll(plotBands));
  });
}
