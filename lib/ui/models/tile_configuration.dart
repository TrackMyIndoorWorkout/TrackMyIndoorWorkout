import 'package:syncfusion_flutter_charts/charts.dart' as charts;

import 'display_record.dart';
import 'histogram_data.dart';

typedef DataFn = List<charts.LineSeries<DisplayRecord, DateTime>> Function();
typedef HistogramFn = List<charts.CircularSeries<HistogramData, String>> Function();

class TileConfiguration {
  final String title;
  final String histogramTitle;
  final DataFn dataFn;
  HistogramFn? histogramFn;
  final List<double>? zoneBounds;
  int count = 0;
  List<HistogramData> histogram = [];
  final String maxString;
  final String avgString;
  final String medianString;

  TileConfiguration({
    required this.title,
    required this.histogramTitle,
    required this.dataFn,
    this.zoneBounds,
    required this.maxString,
    required this.avgString,
    required this.medianString,
  });

  bool get hasMeasurement => count > 0;
}
