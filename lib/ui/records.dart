import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/preferences_spec.dart';
import '../preferences/unit_system.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/statistics_accumulator.dart';
import '../utils/theme_manager.dart';
import 'models/display_record.dart';
import 'models/histogram_data.dart';
import 'models/measurement_counter.dart';
import 'models/tile_configuration.dart';
import 'about.dart';

class RecordsScreen extends StatefulWidget {
  final Activity activity;
  final Size size;
  const RecordsScreen({
    Key? key,
    required this.activity,
    required this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecordsScreenState();
}

class RecordsScreenState extends State<RecordsScreen> {
  int _pointCount = 0;
  List<Record> _allRecords = [];
  List<DisplayRecord> _sampledRecords = [];
  final Map<String, TileConfiguration> _tileConfigurations = {};
  final List<String> _tiles = [];
  bool _initialized = false;
  final List<String> _selectedTimes = [];
  final List<String> _selectedValues = [];
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  List<PreferencesSpec> _preferencesSpecs = [];

  double? _mediaWidth;
  double _sizeDefault = 10.0;
  double _sizeDefault2 = 10.0;
  double _sizeAdjust = 1.0;
  TextStyle _measurementStyle = const TextStyle();
  TextStyle _textStyle = const TextStyle();
  TextStyle _unitStyle = const TextStyle();
  final TextStyle _pieChartLabelStyle = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _isLight = true;
  Color _chartTextColor = Colors.black;
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(iconColor: Colors.black);
  TextStyle _chartLabelStyle = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
  );

  final charts.TooltipBehavior _tooltipBehavior = charts.TooltipBehavior(enable: true);
  final charts.ZoomPanBehavior _zoomPanBehavior = charts.ZoomPanBehavior(
    enableDoubleTapZooming: true,
    enablePinching: true,
    enableSelectionZooming: true,
    zoomMode: charts.ZoomMode.x,
    enablePanning: true,
  );
  final charts.TrackballBehavior _trackballBehavior = charts.TrackballBehavior(
    enable: true,
    activationMode: charts.ActivationMode.singleTap,
    tooltipDisplayMode: charts.TrackballDisplayMode.groupAllPoints,
  );

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
      for (var record in _allRecords) {
        measurementCounter.processRecord(record);
      }

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
      for (var record in _allRecords) {
        accu.processRecord(record);
      }

      if (measurementCounter.hasPower) {
        _tiles.add("power");
        _selectedTimes.add(emptyMeasurement);
        _selectedValues.add(emptyMeasurement);
        var prefSpec = _preferencesSpecs[0];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getPowerData,
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
        _selectedTimes.add(emptyMeasurement);
        _selectedValues.add(emptyMeasurement);
        var prefSpec = _preferencesSpecs[1];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getSpeedData,
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
        _selectedTimes.add(emptyMeasurement);
        _selectedValues.add(emptyMeasurement);
        var prefSpec = _preferencesSpecs[2];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getCadenceData,
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
        _selectedTimes.add(emptyMeasurement);
        _selectedValues.add(emptyMeasurement);
        var prefSpec = _preferencesSpecs[3];
        var tileConfig = TileConfiguration(
          title: prefSpec.fullTitle,
          histogramTitle: prefSpec.histogramTitle,
          dataFn: _getHrData,
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

      for (var record in _allRecords) {
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
            final binIndex = _preferencesSpecs[1].binIndex(record.speedByUnit(_si));
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
      }

      if (measurementCounter.hasPower) {
        var tileConfig = _tileConfigurations["power"]!;
        for (final h in tileConfig.histogram) {
          h.calculatePercent(tileConfig.count);
        }

        tileConfig.histogramFn = _getPowerHistogram;
      }

      if (measurementCounter.hasSpeed) {
        var tileConfig = _tileConfigurations["speed"]!;
        for (var h in tileConfig.histogram) {
          h.calculatePercent(tileConfig.count);
        }

        tileConfig.histogramFn = _getSpeedHistogram;
      }

      if (measurementCounter.hasCadence) {
        var tileConfig = _tileConfigurations["cadence"]!;
        for (var h in tileConfig.histogram) {
          h.calculatePercent(tileConfig.count);
        }

        tileConfig.histogramFn = _getCadenceHistogram;
      }

      if (measurementCounter.hasHeartRate) {
        var tileConfig = _tileConfigurations["hr"]!;
        for (var h in tileConfig.histogram) {
          h.calculatePercent(tileConfig.count);
        }

        tileConfig.histogramFn = _getHrHistogram;
      }

      _allRecords = [];
      _initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _si = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes =
        Get.find<BasePrefService>().get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, widget.activity.sport);
    widget.activity.hydrate();
    _isLight = !_themeManager.isDark();
    _chartTextColor = _themeManager.getProtagonistColor();
    final sizeAdjustInt =
        prefService.get<int>(measurementFontSizeAdjustTag) ?? measurementFontSizeAdjustDefault;
    if (sizeAdjustInt != 100) {
      _sizeAdjust = sizeAdjustInt / 100.0;
    }
    _chartLabelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 11 * _sizeAdjust,
      color: _chartTextColor,
    );
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
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getPowerHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        xValueMapper: (HistogramData data, int index) => 'Z${data.index} ${data.percent}%',
        yValueMapper: (HistogramData data, _) => data.percent,
        dataSource: _tileConfigurations["power"]!.histogram,
        explode: true,
        dataLabelSettings: charts.DataLabelSettings(
          isVisible: true,
          showZeroValue: false,
          textStyle: _pieChartLabelStyle,
        ),
        enableTooltip: true,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getSpeedData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getSpeedHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["speed"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index} ${data.percent}%',
        yValueMapper: (HistogramData data, _) => data.percent,
        explode: true,
        dataLabelSettings: charts.DataLabelSettings(
          isVisible: true,
          showZeroValue: false,
          textStyle: _pieChartLabelStyle,
        ),
        enableTooltip: true,
        animationDuration: 0,
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
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getCadenceHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["cadence"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index} ${data.percent}%',
        yValueMapper: (HistogramData data, _) => data.percent,
        explode: true,
        dataLabelSettings: charts.DataLabelSettings(
          isVisible: true,
          showZeroValue: false,
          textStyle: _pieChartLabelStyle,
        ),
        enableTooltip: true,
        animationDuration: 0,
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
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getHrHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["hr"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index} ${data.percent}%',
        yValueMapper: (HistogramData data, _) => data.percent,
        explode: true,
        dataLabelSettings: charts.DataLabelSettings(
          isVisible: true,
          showZeroValue: false,
          textStyle: _pieChartLabelStyle,
        ),
        enableTooltip: true,
        animationDuration: 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 7 * _sizeAdjust;
      _sizeDefault2 = _sizeDefault / 1.5;
      _measurementStyle = TextStyle(
        fontFamily: fontFamily,
        fontSize: _sizeDefault,
      );
      _textStyle = TextStyle(
        fontSize: _sizeDefault2,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => Get.to(() => const AboutScreen()),
          ),
        ],
      ),
      body: !_initialized
          ? const Text('Initializing...')
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
                        const Spacer(),
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
                        const Spacer(),
                        Text(
                          widget.activity.distanceString(_si, _highRes),
                          style: _measurementStyle,
                        ),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text(
                            distanceUnit(_si, _highRes),
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
                        const Spacer(),
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
                            const Spacer(),
                            Text(
                              _tileConfigurations[item]!.maxString,
                              style: _measurementStyle,
                            ),
                            const Spacer(),
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
                            const Spacer(),
                            Text(
                              _tileConfigurations[item]!.avgString,
                              style: _measurementStyle,
                            ),
                            const Spacer(),
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
                      item == "speed" && widget.activity.sport != ActivityType.ride
                          ? Text(
                              "Speed ${_si ? 'km' : 'mi'}/h",
                              style: _textStyle,
                            )
                          : Container(),
                      SizedBox(
                        width: widget.size.width,
                        height: widget.size.height / 2,
                        child: charts.SfCartesianChart(
                          primaryXAxis: charts.DateTimeAxis(
                            labelStyle: _chartLabelStyle,
                            axisLine: charts.AxisLine(color: _chartTextColor),
                            majorTickLines: charts.MajorTickLines(color: _chartTextColor),
                            minorTickLines: charts.MinorTickLines(color: _chartTextColor),
                            majorGridLines: charts.MajorGridLines(color: _chartTextColor),
                            minorGridLines: charts.MinorGridLines(color: _chartTextColor),
                          ),
                          primaryYAxis: charts.NumericAxis(
                            plotBands: _preferencesSpecs[index].plotBands,
                            labelStyle: _chartLabelStyle,
                            axisLine: charts.AxisLine(color: _chartTextColor),
                            majorTickLines: charts.MajorTickLines(color: _chartTextColor),
                            minorTickLines: charts.MinorTickLines(color: _chartTextColor),
                            majorGridLines: charts.MajorGridLines(color: _chartTextColor),
                            minorGridLines: charts.MinorGridLines(color: _chartTextColor),
                          ),
                          margin: const EdgeInsets.all(0),
                          series: _tileConfigurations[item]!.dataFn(),
                          zoomPanBehavior: _zoomPanBehavior,
                          trackballBehavior: _trackballBehavior,
                        ),
                      ),
                      const Divider(height: 20, thickness: 2),
                      Text(
                        _tileConfigurations[item]!.histogramTitle,
                        style: _textStyle,
                      ),
                      SizedBox(
                        width: widget.size.width,
                        height: widget.size.height / 3,
                        child: charts.SfCircularChart(
                          margin: const EdgeInsets.all(0),
                          legend: charts.Legend(isVisible: true, textStyle: _pieChartLabelStyle),
                          series: _tileConfigurations[item]!.histogramFn!(),
                          palette: _preferencesSpecs[index].getPiePalette(_isLight),
                          tooltipBehavior: _tooltipBehavior,
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
