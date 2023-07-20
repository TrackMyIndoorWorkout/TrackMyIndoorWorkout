import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import '../../persistence/isar/activity.dart';
import '../../persistence/isar/db_utils.dart';
import '../../persistence/isar/record.dart';
import '../../preferences/activity_ui.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/measurement_font_size_adjust.dart';
import '../../preferences/metric_spec.dart';
import '../../preferences/palette_spec.dart';
import '../../preferences/unit_system.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import '../../utils/statistics_accumulator.dart';
import '../../utils/string_ex.dart';
import '../../utils/theme_manager.dart';
import '../models/display_record.dart';
import '../models/histogram_data.dart';
import '../models/measurement_counter.dart';
import '../models/tile_configuration.dart';
import '../about.dart';
import 'activity_detail_graphs.dart';
import 'activity_detail_row_fit_horizontal.dart';
import 'activity_detail_row_w_unit.dart';
import 'activity_detail_unit_row.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;
  final Size size;
  const ActivityDetailsScreen({
    Key? key,
    required this.activity,
    required this.size,
  }) : super(key: key);

  @override
  ActivityDetailsScreenState createState() => ActivityDetailsScreenState();
}

class ActivityDetailsScreenState extends State<ActivityDetailsScreen> with WidgetsBindingObserver {
  int _editCount = 0;
  int _pointCount = 0;
  List<Record> _allRecords = [];
  List<DisplayRecord> _sampledRecords = [];
  List<DisplayRecord> _averageRecords = [];
  final Map<String, TileConfiguration> _tileConfigurations = {};
  final List<String> _tiles = [];
  bool _initialized = false;
  final List<String> _selectedTimes = [];
  final List<String> _selectedValues = [];
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  bool _calculateMedian = activityDetailsMedianDisplayDefault;
  List<MetricSpec> _preferencesSpecs = [];
  PaletteSpec? _paletteSpec;

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
  Color _chartAvgColor = Colors.orange;
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(iconColor: Colors.black);
  TextStyle _chartLabelStyle = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
  );

  Future<void> extraInit(BasePrefService prefService) async {
    _allRecords = await DbUtils().getRecords(widget.activity.id);
    setState(() {
      _pointCount = widget.size.width.toInt() - 20;
      if (_allRecords.length < _pointCount) {
        _sampledRecords =
            _allRecords.map((r) => DisplayRecord.fromRecord(r)).toList(growable: false);
      } else {
        final nth = _allRecords.length / _pointCount;
        _sampledRecords = List.generate(
          _pointCount,
          (i) => DisplayRecord.fromRecord(_allRecords[((i + 1) * nth - 1).round()]),
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
        calculateMedian: _calculateMedian,
      );
      for (var record in _allRecords) {
        accu.processRecord(record);
      }

      _averageRecords = List.generate(
        _sampledRecords.length,
        (i) => accu.averageDisplayRecord(_sampledRecords[i].timeStamp),
        growable: false,
      );

      _paletteSpec = PaletteSpec.getInstance(prefService);

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
          medianString: accu.medianPower.toStringAsFixed(2),
        );
        prefSpec.calculateBounds(
          measurementCounter.minPower.toDouble(),
          measurementCounter.maxPower.toDouble(),
          _isLight,
          _paletteSpec!,
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
          medianString: speedOrPaceString(accu.medianSpeed, _si, widget.activity.sport),
        );
        prefSpec.calculateBounds(
          measurementCounter.minSpeed,
          measurementCounter.maxSpeed,
          _isLight,
          _paletteSpec!,
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
          medianString: "${accu.medianCadence}",
        );
        prefSpec.calculateBounds(
          measurementCounter.minCadence.toDouble(),
          measurementCounter.maxCadence.toDouble(),
          _isLight,
          _paletteSpec!,
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
          medianString: "${accu.medianHeartRate}",
        );
        prefSpec.calculateBounds(
          measurementCounter.minHr.toDouble(),
          measurementCounter.maxHr.toDouble(),
          _isLight,
          _paletteSpec!,
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
  void didChangeMetrics() {
    setState(() {
      _editCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final prefService = Get.find<BasePrefService>();
    _si = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes =
        Get.find<BasePrefService>().get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    _calculateMedian = Get.find<BasePrefService>().get<bool>(activityDetailsMedianDisplayTag) ??
        activityDetailsMedianDisplayDefault;
    _preferencesSpecs = MetricSpec.getPreferencesSpecs(_si, widget.activity.sport);
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
    _chartAvgColor = _themeManager.getAverageChartColor();

    extraInit(prefService);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _getPowerData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _sampledRecords,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.power,
        color: _chartTextColor,
        animationDuration: 0,
      ),
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _averageRecords,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.power,
        color: _chartAvgColor,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getPowerHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        xValueMapper: (HistogramData data, int index) => 'Z${data.index + 1} ${data.percent}%',
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
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
        color: _chartTextColor,
        animationDuration: 0,
      ),
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _averageRecords,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
        color: _chartAvgColor,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getSpeedHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["speed"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index + 1} ${data.percent}%',
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
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.cadence,
        color: _chartTextColor,
        animationDuration: 0,
      ),
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _averageRecords,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.cadence,
        color: _chartAvgColor,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getCadenceHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["cadence"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index + 1} ${data.percent}%',
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
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.heartRate,
        color: _chartTextColor,
        animationDuration: 0,
      ),
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: _averageRecords,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.heartRate,
        color: _chartAvgColor,
        animationDuration: 0,
      ),
    ];
  }

  List<charts.CircularSeries<HistogramData, String>> _getHrHistogram() {
    return <charts.CircularSeries<HistogramData, String>>[
      charts.PieSeries<HistogramData, String>(
        dataSource: _tileConfigurations["hr"]!.histogram,
        xValueMapper: (HistogramData data, int index) => 'Z${data.index + 1} ${data.percent}%',
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

    final List<Widget> header = [
      ActivityDetailRowWithUnit(
        themeManager: _themeManager,
        icon: getSportIcon(widget.activity.sport),
        iconSize: _sizeDefault,
        text: widget.activity.deviceName,
        textStyle: _textStyle,
        unitText: "",
      ),
      ActivityDetailRowWithUnit(
        themeManager: _themeManager,
        icon: Icons.numbers,
        iconSize: _sizeDefault,
        text: widget.activity.deviceId.shortAddressString(),
        textStyle: _textStyle,
        unitText: "",
      ),
      ActivityDetailRowWithUnit(
        themeManager: _themeManager,
        icon: Icons.timer,
        iconSize: _sizeDefault,
        text: widget.activity.movingTimeString,
        textStyle: _measurementStyle,
        unitText: "",
      ),
    ];
    if (widget.activity.movingTime ~/ 1000 < widget.activity.elapsed) {
      header.addAll([
        ActivityDetailUnitRow(
            themeManager: _themeManager, unitText: "(Moving Time)", unitStyle: _unitStyle),
        ActivityDetailRowFitHorizontal(
          themeManager: _themeManager,
          icon: Icons.timer,
          iconSize: _sizeDefault,
          text: widget.activity.elapsedString,
          textStyle: _measurementStyle,
          unitText: "",
          unitStyle: null,
        ),
        ActivityDetailUnitRow(
            themeManager: _themeManager, unitText: "(Total Time)", unitStyle: _unitStyle),
      ]);
    }

    header.addAll([
      ActivityDetailRowWithUnit(
        themeManager: _themeManager,
        icon: Icons.add_road,
        iconSize: _sizeDefault,
        text: widget.activity.distanceString(_si, _highRes),
        textStyle: _measurementStyle,
        unitText: distanceUnit(_si, _highRes),
        unitStyle: _unitStyle,
      ),
      ActivityDetailRowWithUnit(
        themeManager: _themeManager,
        icon: Icons.whatshot,
        iconSize: _sizeDefault,
        text: '${widget.activity.calories}',
        textStyle: _measurementStyle,
        unitText: 'cal',
        unitStyle: _unitStyle,
      ),
    ]);

    final dateString = DateFormat.Md().format(widget.activity.start);
    final timeString = DateFormat.Hm().format(widget.activity.start);
    final title = "$dateString $timeString";

    final appBarActions = [
      IconButton(
        icon: const Icon(Icons.help),
        onPressed: () => Get.to(() => const AboutScreen()),
      ),
    ];
    if (kDebugMode) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.build),
          onPressed: () async {
            // final tm = TrackManager();
            // final track = await tm.getTrack(widget.activity.sport);
            // debugPrint(track.name);
            await DbUtils().finalizeActivity(widget.activity);
            // await database.recalculateDistance(widget.activity, true);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarActions,
      ),
      body: !_initialized
          ? const Text('Initializing...')
          : CustomListView(
              key: Key("CLV$_editCount"),
              paginationMode: PaginationMode.offset,
              initialOffset: 0,
              loadingBuilder: CustomListLoading.defaultBuilder,
              header: Card(
                elevation: 6,
                child: Column(children: header),
              ),
              adapter: StaticListAdapter(data: _tiles),
              itemBuilder: (context, index, item) {
                return ActivityDetailGraphs(
                  item: item,
                  index: index,
                  size: widget.size,
                  expandableThemeData: _expandableThemeData,
                  textStyle: _textStyle,
                  measurementStyle: _measurementStyle,
                  unitStyle: _unitStyle,
                  chartLabelStyle: _chartLabelStyle,
                  chartTextColor: _chartTextColor,
                  tileConfiguration: _tileConfigurations[item]!,
                  preferencesSpec: _preferencesSpecs[index],
                  si: _si,
                  sport: widget.activity.sport,
                  isLight: _isLight,
                  sizeDefault: _sizeDefault2,
                  paletteSpec: _paletteSpec!,
                  themeManager: _themeManager,
                  displayMedian: _calculateMedian,
                );
              },
            ),
    );
  }
}
