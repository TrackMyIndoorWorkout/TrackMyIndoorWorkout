import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import 'package:url_launcher/url_launcher.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/statistics_accumulator.dart';
import '../utils/theme_manager.dart';
import 'models/display_record.dart';
import 'models/histogram_data.dart';
import 'models/measurement_counter.dart';
// import 'models/selection_data.dart';
import 'models/tile_configuration.dart';

class RecordsScreen extends StatefulWidget {
  final Activity activity;
  final Size size;
  RecordsScreen({
    Key? key,
    required this.activity,
    required this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecordsScreenState();
}

class RecordsScreenState extends State<RecordsScreen> {
  late int _pointCount;
  late List<Record> _allRecords;
  late List<DisplayRecord> _sampledRecords;
  late Map<String, TileConfiguration> _tileConfigurations;
  late List<String> _tiles;
  late bool _initialized;
  late List<String> _selectedTimes;
  late List<String> _selectedValues;
  late bool _si;
  late List<PreferencesSpec> _preferencesSpecs;

  double? _mediaWidth;
  late double _sizeDefault;
  late double _sizeDefault2;
  late TextStyle _measurementStyle;
  late TextStyle _textStyle;
  late TextStyle _unitStyle;
  late TextStyle _selectionStyle;
  late TextStyle _selectionTextStyle;
  late ThemeManager _themeManager;
  late bool _isLight;
  late Color _chartTextColor;
  late Color _chartBackground;
  late ExpandableThemeData _expandableThemeData;

  Future<void> extraInit() async {
    final database = Get.find<AppDatabase>();
    _allRecords = await database.recordDao.findAllActivityRecords(widget.activity.id ?? 0);

    setState(() {
      _pointCount = widget.size.width.toInt() - 20;
      if (_allRecords.length < _pointCount) {
        _sampledRecords = _allRecords
            .map((r) => r.hydrate(widget.activity.sport).display())
            .toList(growable: false);
      } else {
        final nth = _allRecords.length / _pointCount;
        _sampledRecords = List.generate(
          _pointCount,
          (i) => _allRecords[((i + 1) * nth - 1).round()].hydrate(widget.activity.sport).display(),
          growable: false,
        );
      }
      final measurementCounter = MeasurementCounter(si: _si, sport: widget.activity.sport);
      _allRecords.forEach((record) {
        measurementCounter.processRecord(record);
      });

      var accu = StatisticsAccumulator(
        si: _si,
        sport: widget.activity.sport,
        calculateAvgPower: measurementCounter.hasPower,
        calculateMaxPower: measurementCounter.hasPower,
        calculateAvgSpeed: measurementCounter.hasSpeed,
        calculateMaxSpeed: measurementCounter.hasSpeed,
        calculateAvgCadence: measurementCounter.hasCadence,
        calculateMaxCadence: measurementCounter.hasCadence,
        calculateAvgHeartRate: measurementCounter.hasHeartRate,
        calculateMaxHeartRate: measurementCounter.hasHeartRate,
      );
      _allRecords.forEach((record) {
        accu.processRecord(record);
      });

      if (measurementCounter.hasPower) {
        _tiles.add("power");
        _selectedTimes.add("--");
        _selectedValues.add("--");
        var prefSpec = _preferencesSpecs[0];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getPowerData,
          dataStringFn: _getPowerString,
          // selectionListener: _powerSelectionListener,
          maxString: accu.maxPower.toStringAsFixed(2),
          avgString: accu.avgPower.toStringAsFixed(2),
        );
        prefSpec.calculateBounds(
          measurementCounter.minPower.toDouble(),
          measurementCounter.maxPower.toDouble(),
          _isLight,
        );
        tileConfig.histogram = prefSpec.zoneUpper
            .asMap()
            .entries
            .map(
              (entry) => HistogramData(index: entry.key, upper: entry.value),
            )
            .toList(growable: false);
        _tileConfigurations["power"] = tileConfig;
      }
      if (measurementCounter.hasSpeed) {
        _tiles.add("speed");
        _selectedTimes.add("--");
        _selectedValues.add("--");
        var prefSpec = _preferencesSpecs[1];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getSpeedData,
          dataStringFn: _getSpeedString,
          // selectionListener: _speedSelectionListener,
          maxString: speedOrPaceString(accu.maxSpeed, _si, widget.activity.sport),
          avgString: speedOrPaceString(accu.avgSpeed, _si, widget.activity.sport),
        );
        prefSpec.calculateBounds(
          measurementCounter.minSpeed,
          measurementCounter.maxSpeed,
          _isLight,
        );
        tileConfig.histogram = prefSpec.zoneUpper
            .asMap()
            .entries
            .map(
              (entry) => HistogramData(index: entry.key, upper: entry.value),
            )
            .toList(growable: false);
        _tileConfigurations["speed"] = tileConfig;
      }
      if (measurementCounter.hasCadence) {
        _tiles.add("cadence");
        _selectedTimes.add("--");
        _selectedValues.add("--");
        var prefSpec = _preferencesSpecs[2];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getCadenceData,
          dataStringFn: _getCadenceString,
          // selectionListener: _cadenceSelectionListener,
          maxString: "${accu.maxCadence}",
          avgString: "${accu.avgCadence}",
        );
        prefSpec.calculateBounds(
          measurementCounter.minCadence.toDouble(),
          measurementCounter.maxCadence.toDouble(),
          _isLight,
        );
        tileConfig.histogram = prefSpec.zoneUpper
            .asMap()
            .entries
            .map(
              (entry) => HistogramData(index: entry.key, upper: entry.value),
            )
            .toList(growable: false);
        _tileConfigurations["cadence"] = tileConfig;
      }
      if (measurementCounter.hasHeartRate) {
        _tiles.add("hr");
        _selectedTimes.add("--");
        _selectedValues.add("--");
        var prefSpec = _preferencesSpecs[3];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getHrData,
          dataStringFn: _getHrString,
          // selectionListener: _hrSelectionListener,
          maxString: "${accu.maxHeartRate}",
          avgString: "${accu.avgHeartRate}",
        );
        prefSpec.calculateBounds(
          measurementCounter.minHr.toDouble(),
          measurementCounter.maxHr.toDouble(),
          _isLight,
        );
        tileConfig.histogram = prefSpec.zoneUpper
            .asMap()
            .entries
            .map(
              (entry) => HistogramData(index: entry.key, upper: entry.value),
            )
            .toList(growable: false);
        _tileConfigurations["hr"] = tileConfig;
      }
      _allRecords.forEach((record) {
        if (measurementCounter.hasPower) {
          if (record.power != null && record.power! > 0) {
            var tileConfig = _tileConfigurations["power"]!;
            tileConfig.count++;
            final binIndex = _preferencesSpecs[0].binIndex(record.power!);
            tileConfig.histogram[binIndex].increment();
          }
        }
        if (measurementCounter.hasSpeed) {
          if (record.speed != null && record.speed! > 0) {
            var tileConfig = _tileConfigurations["speed"]!;
            tileConfig.count++;
            final binIndex =
                _preferencesSpecs[1].binIndex(record.speedByUnit(_si, widget.activity.sport));
            tileConfig.histogram[binIndex].increment();
          }
        }
        if (measurementCounter.hasCadence) {
          if (record.cadence != null && record.cadence! > 0) {
            var tileConfig = _tileConfigurations["cadence"]!;
            tileConfig.count++;
            final binIndex = _preferencesSpecs[2].binIndex(record.cadence!);
            tileConfig.histogram[binIndex].increment();
          }
        }
        if (measurementCounter.hasHeartRate) {
          if (record.heartRate != null && record.heartRate! > 0) {
            var tileConfig = _tileConfigurations["hr"]!;
            tileConfig.count++;
            final binIndex = _preferencesSpecs[3].binIndex(record.heartRate!);
            tileConfig.histogram[binIndex].increment();
          }
        }
      });
      if (measurementCounter.hasPower) {
        var tileConfig = _tileConfigurations["power"]!;
        tileConfig.histogram.forEach((h) {
          h.calculatePercent(tileConfig.count);
        });
        tileConfig.histogramFn = _getPowerHistogram;
      }
      if (measurementCounter.hasSpeed) {
        var tileConfig = _tileConfigurations["speed"]!;
        tileConfig.histogram.forEach((h) {
          h.calculatePercent(tileConfig.count);
        });
        tileConfig.histogramFn = _getSpeedHistogram;
      }
      if (measurementCounter.hasCadence) {
        var tileConfig = _tileConfigurations["cadence"]!;
        tileConfig.histogram.forEach((h) {
          h.calculatePercent(tileConfig.count);
        });
        tileConfig.histogramFn = _getCadenceHistogram;
      }
      if (measurementCounter.hasHeartRate) {
        var tileConfig = _tileConfigurations["hr"]!;
        tileConfig.histogram.forEach((h) {
          h.calculatePercent(tileConfig.count);
        });
        tileConfig.histogramFn = _getHrHistogram;
      }
      _allRecords = [];
      _initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initialized = false;
    _tileConfigurations = {};
    _tiles = [];
    _selectedTimes = [];
    _selectedValues = [];
    final prefService = Get.find<BasePrefService>();
    _si = prefService.get<bool>(UNIT_SYSTEM_TAG) ?? UNIT_SYSTEM_DEFAULT;
    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, widget.activity.sport);
    widget.activity.hydrate();
    _themeManager = Get.find<ThemeManager>();
    _isLight = !_themeManager.isDark();
    _chartTextColor = _themeManager.getProtagonistColor();
    _chartBackground = _themeManager.getAntagonistColor();
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());

    extraInit();
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getPowerData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.power,
        color: _chartTextColor,
      ),
    ];
  }

  String _getPowerString(DisplayRecord record) {
    return record.power.toString();
  }

  // String _getSelectedTime(SelectionData selectionData, Activity activity) {
  //   if (selectionData.time == null || activity.startDateTime == null) return "-";
  //
  //   return selectionData.time!.difference(activity.startDateTime!).toDisplay();
  // }

  // void _powerSelectionListener(charts.SelectionModel<DateTime> model) {
  //   final selectionData = _tileConfigurations["power"]!.getSelectionData(model);
  //
  //   setState(() {
  //     _selectedTimes[0] = _getSelectedTime(selectionData, activity);
  //     _selectedValues[0] = selectionData.value;
  //   });
  // }

  List<charts.CircularSeries<HistogramData, int>> _getPowerHistogram() {
    return <charts.CircularSeries<HistogramData, int>>[
      charts.DoughnutSeries<HistogramData, int>(
        xValueMapper: (HistogramData data, int index) => index,
        yValueMapper: (HistogramData data, _) => data.percent,
        dataSource: _tileConfigurations["power"]!.histogram,
        // dataLabelMapper: ?
        // dataLabelSettings: ?
        // palette: ?
        // labelAccessorFn: (HistogramData data, _) => 'Z${data.index}: ${data.percent}%',
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getSpeedData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si, widget.activity.sport),
        color: _chartTextColor,
      ),
    ];
  }

  String _getSpeedString(DisplayRecord record) {
    return speedOrPaceString(record.speed ?? 0.0, _si, widget.activity.sport);
  }

  // void _speedSelectionListener(charts.SelectionModel<DateTime> model) {
  //   final selectionData = _tileConfigurations["speed"]!.getSelectionData(model);
  //
  //   setState(() {
  //     _selectedTimes[1] = _getSelectedTime(selectionData, activity);
  //     _selectedValues[1] = selectionData.value;
  //   });
  // }

  List<charts.CircularSeries<HistogramData, int>> _getSpeedHistogram() {
    return <charts.CircularSeries<HistogramData, int>>[
      charts.DoughnutSeries<HistogramData, int>(
        dataSource: _tileConfigurations["speed"]!.histogram,
        xValueMapper: (HistogramData data, int index) => index,
        yValueMapper: (HistogramData data, _) => data.percent,
        // dataLabelMapper: ?
        // dataLabelSettings: ?
        // palette: ?
        // labelAccessorFn: (HistogramData data, _) => 'Z${data.index}: ${data.percent}%',
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getCadenceData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.cadence,
        color: _chartTextColor,
      ),
    ];
  }

  String _getCadenceString(DisplayRecord record) {
    return record.cadence.toString();
  }

  // void _cadenceSelectionListener(charts.SelectionModel<DateTime> model) {
  //   final selectionData = _tileConfigurations["cadence"]!.getSelectionData(model);
  //
  //   setState(() {
  //     _selectedTimes[2] = _getSelectedTime(selectionData, activity);
  //     _selectedValues[2] = selectionData.value;
  //   });
  // }

  List<charts.CircularSeries<HistogramData, int>> _getCadenceHistogram() {
    return <charts.CircularSeries<HistogramData, int>>[
      charts.DoughnutSeries<HistogramData, int>(
        dataSource: _tileConfigurations["cadence"]!.histogram,
        xValueMapper: (HistogramData data, int index) => index,
        yValueMapper: (HistogramData data, _) => data.percent,
        // dataLabelMapper: ?
        // dataLabelSettings: ?
        // palette: ?
        // labelAccessorFn: (HistogramData data, _) => 'Z${data.index}: ${data.percent}%',
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getHrData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.heartRate,
        color: _chartTextColor,
      ),
    ];
  }

  String _getHrString(DisplayRecord record) {
    return record.heartRate.toString();
  }

  // void _hrSelectionListener(charts.SelectionModel<DateTime> model) {
  //   final selectionData = _tileConfigurations["hr"]!.getSelectionData(model);
  //
  //   setState(() {
  //     _selectedTimes[3] = _getSelectedTime(selectionData, activity);
  //     _selectedValues[3] = selectionData.value;
  //   });
  // }

  List<charts.CircularSeries<HistogramData, int>> _getHrHistogram() {
    return <charts.CircularSeries<HistogramData, int>>[
      charts.DoughnutSeries<HistogramData, int>(
        dataSource: _tileConfigurations["hr"]!.histogram,
        xValueMapper: (HistogramData data, int index) => index,
        yValueMapper: (HistogramData data, _) => data.percent,
        // dataLabelMapper: ?
        // dataLabelSettings: ?
        // palette: ?
        // labelAccessorFn: (HistogramData data, _) => 'Z${data.index}: ${data.percent}%',
      ),
    ];
  }

  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 7;
      _sizeDefault2 = _sizeDefault / 1.5;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _textStyle = TextStyle(
        fontSize: _sizeDefault2,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
      _selectionStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault2 / 2,
      );
      _selectionTextStyle = TextStyle(
        fontSize: _sizeDefault2 / 2,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () async {
              if (await canLaunch(HELP_URL)) {
                launch(HELP_URL);
              } else {
                Get.snackbar("Attention", "Cannot open URL");
              }
            },
          ),
        ],
      ),
      body: !_initialized
          ? Text('Initializing...')
          : CustomListView(
              paginationMode: PaginationMode.offset,
              initialOffset: 0,
              loadingBuilder: CustomListLoading.defaultBuilder,
              header: Card(
                elevation: 6,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(getIcon(widget.activity.sport), _sizeDefault),
                        Expanded(
                          child: TextOneLine(
                            widget.activity.deviceName,
                            style: _textStyle,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.timer, _sizeDefault),
                        Spacer(),
                        Text(
                          widget.activity.elapsedString,
                          style: _measurementStyle,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.add_road, _sizeDefault),
                        Spacer(),
                        Text(
                          widget.activity.distanceString(_si),
                          style: _measurementStyle,
                        ),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text(
                            _si ? 'm' : 'mi',
                            style: _unitStyle,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.whatshot, _sizeDefault),
                        Spacer(),
                        Text(
                          '${widget.activity.calories}',
                          style: _measurementStyle,
                        ),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text(
                            'cal',
                            style: _unitStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              adapter: StaticListAdapter(data: _tiles),
              itemBuilder: (context, index, item) {
                return Card(
                  elevation: 6,
                  child: ExpandablePanel(
                    theme: _expandableThemeData,
                    header: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _tileConfigurations[item]!.title,
                              style: _textStyle,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _themeManager.getBlueIcon(_preferencesSpecs[index].icon, _sizeDefault2),
                            Text("MAX", style: _unitStyle),
                            Spacer(),
                            Text(
                              _tileConfigurations[item]!.maxString,
                              style: _measurementStyle,
                            ),
                            Spacer(),
                            Text(
                              _preferencesSpecs[index].multiLineUnit,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              style: _unitStyle,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _themeManager.getBlueIcon(_preferencesSpecs[index].icon, _sizeDefault2),
                            Text("AVG", style: _unitStyle),
                            Spacer(),
                            Text(
                              _tileConfigurations[item]!.avgString,
                              style: _measurementStyle,
                            ),
                            Spacer(),
                            Text(
                              _preferencesSpecs[index].multiLineUnit,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              style: _unitStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    collapsed: Container(),
                    expanded: Column(children: [
                      SizedBox(
                        width: widget.size.width,
                        height: widget.size.height / 2,
                        child: charts.SfCartesianChart(
                          primaryXAxis: charts.DateTimeAxis(),
                          margin: EdgeInsets.all(0),
                          series: _tileConfigurations[item]!.dataFn(),

                          // behaviors: [
                          //   charts.LinePointHighlighter(
                          //     showHorizontalFollowLine:
                          //         charts.LinePointHighlighterFollowLineType.nearest,
                          //     showVerticalFollowLine:
                          //         charts.LinePointHighlighterFollowLineType.nearest,
                          //   ),
                          //   charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag),
                          //   charts.RangeAnnotation(
                          //     _preferencesSpecs[index].annotationSegments,
                          //     // defaultLabelStyleSpec: _chartTextStyle,
                          //   ),
                          // ],

                          // selectionModels: [
                          //   charts.SelectionModelConfig(
                          //     type: charts.SelectionModelType.info,
                          //     changedListener: _tileConfigurations[item]!.selectionListener,
                          //   ),
                          // ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_selectedValues[index], style: _selectionStyle),
                          Text(" ", style: _selectionTextStyle),
                          Text(_preferencesSpecs[index].unit, style: _unitStyle),
                          Text(" @ ", style: _selectionTextStyle),
                          Text(_selectedTimes[index], style: _selectionStyle),
                        ],
                      ),
                      Divider(height: 20, thickness: 2),
                      Text(
                        _tileConfigurations[item]!.histogramTitle,
                        style: _textStyle,
                      ),
                      SizedBox(
                        width: widget.size.width,
                        height: widget.size.height / 3,
                        child: charts.SfCircularChart(
                          margin: EdgeInsets.all(0),
                          series: _tileConfigurations[item]!.histogramFn!(),

                          // palette: [],
                          // defaultRenderer: charts.ArcRendererConfig(
                          //   arcWidth: 60,
                          //   arcRendererDecorators: [charts.ArcLabelDecorator()],
                          // ),

                          // behaviors: [
                          //   charts.DatumLegend(
                          //     position: charts.BehaviorPosition.start,
                          //     horizontalFirst: false,
                          //     cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
                          //     showMeasures: true,
                          //     legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
                          //     // entryTextStyle: _chartTextStyle,
                          //     measureFormatter: (num value) {
                          //       return '$value %';
                          //     },
                          //   ),
                          // ],
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
