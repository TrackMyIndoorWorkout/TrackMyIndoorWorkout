import 'package:charts_common/common.dart' as common;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:meta/meta.dart';

import 'display_record.dart';
import 'histogram_data.dart';
import 'selection_data.dart';

typedef DataFn = List<charts.Series<DisplayRecord, DateTime>> Function();
typedef DataStringFn = String Function(DisplayRecord);
typedef HistogramFn = List<charts.Series<HistogramData, double>> Function();

class TileConfiguration {
  final String title;
  final String histogramTitle;
  final DataFn dataFn;
  final DataStringFn dataStringFn;
  HistogramFn histogramFn;
  final List<double> zoneBounds;
  int count;
  List<HistogramData> histogram;
  final common.SelectionModelListener<DateTime> selectionListener;
  final String maxString;
  final String avgString;

  TileConfiguration({
    @required this.title,
    @required this.histogramTitle,
    @required this.dataFn,
    @required this.dataStringFn,
    @required this.selectionListener,
    this.zoneBounds,
    @required this.maxString,
    @required this.avgString,
  })  : assert(title != null),
        assert(histogramTitle != null),
        assert(dataFn != null),
        assert(dataStringFn != null),
        assert(selectionListener != null),
        assert(maxString != null),
        assert(avgString != null) {
    count = 0;
  }
  bool get hasMeasurement => count > 0;

  SelectionData getSelectionData(charts.SelectionModel<DateTime> model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      final datum = selectedDatum.first.datum;
      return SelectionData(time: datum.dt, value: dataStringFn(datum));
    }

    return SelectionData(time: null, value: "--");
  }
}
