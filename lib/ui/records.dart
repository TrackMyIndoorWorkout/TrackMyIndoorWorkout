import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import 'find_devices.dart';

class RecordsScreen extends StatefulWidget {
  final Activity activity;
  final Size size;
  RecordsScreen({Key key, this.activity, this.size}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecordsScreenState(activity: activity, size: size);
  }
}

class HistogramData {
  final double upper;
  int count;
  final String range;

  HistogramData({this.upper, this.range}) {
    count = 0;
  }

  increment() {
    count++;
  }
}

typedef DataFn = List<Series<Record, DateTime>> Function();
typedef HistogramFn = List<Series<HistogramData, String>> Function();

class TileConfiguration {
  final String title;
  final DataFn dataFn;
  HistogramFn histogramFn;
  final double binSize;
  List<HistogramData> histogram;

  TileConfiguration({this.title, this.dataFn, this.binSize});
}

const MIN_INIT = 10000;

class BoundsAccumulator {
  int minPower = MIN_INIT;
  int maxPower = 0;
  double minSpeed = MIN_INIT.toDouble();
  double maxSpeed = 0;
  int minCadence = MIN_INIT;
  int maxCadence = 0;
  int minHr = MIN_INIT;
  int maxHr = 0;

  processRecord(Record record) {
    if (record.power > 0) {
      maxPower = max(maxPower, record.power);
      minPower = min(minPower, record.power);
    }
    if (record.speed > 0) {
      maxSpeed = max(maxSpeed, record.speed);
      minSpeed = min(minSpeed, record.speed);
    }
    if (record.cadence > 0) {
      maxCadence = max(maxCadence, record.cadence);
      minCadence = min(minCadence, record.cadence);
    }
    if (record.heartRate > 0) {
      maxHr = max(maxHr, record.heartRate);
      minHr = min(minHr, record.heartRate);
    }
  }
}

const BIN_COUNT = 20;

class RecordsScreenState extends State<RecordsScreen> {
  RecordsScreenState({this.activity, this.size});

  final Activity activity;
  final Size size;
  int _count;
  List<Record> _allRecords;
  List<Record> _sampledRecords;
  Map<String, TileConfiguration> _tileConfigurations;
  List<String> _tiles;
  bool _initialized;

  @override
  initState() {
    super.initState();
    _initialized = false;
    _tileConfigurations = {};
    _tiles = [];
    $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build()
        .then((db) async {
      _allRecords = await db.recordDao.findAllActivityRecords(activity.id);
      setState(() {
        _count = size.width.toInt() - 20;
        if (_allRecords.length < _count) {
          _sampledRecords =
              _allRecords.map((r) => r.hydrate()).toList(growable: false);
        } else {
          final nth = _allRecords.length / _count;
          _sampledRecords = List.generate(_count,
              (i) => _allRecords[((i + 1) * nth - 1).round()].hydrate());
        }
        var bounds = BoundsAccumulator();
        _allRecords.forEach((record) {
          bounds.processRecord(record);
        });

        if (bounds.minPower < MIN_INIT) {
          _tiles.add("power");
          final binSize = (bounds.maxPower - bounds.minPower) / BIN_COUNT;
          final tileConfig = TileConfiguration(
            title: "Power (W)",
            dataFn: _getPowerData,
            binSize: binSize,
          );
          tileConfig.histogram = List.generate(
              BIN_COUNT,
              (i) => HistogramData(
                    upper: bounds.minPower + (i + 1) * binSize,
                    range: ' - ${bounds.minPower + (i + 1) * binSize}',
                  ));
          _tileConfigurations["power"] = tileConfig;
        }
        if (bounds.minSpeed < MIN_INIT) {
          _tiles.add("speed");
          final binSize = (bounds.maxSpeed - bounds.minSpeed) / BIN_COUNT;
          final tileConfig = TileConfiguration(
            title: "Speed (km/h)",
            dataFn: _getSpeedData,
            binSize: binSize,
          );
          tileConfig.histogram = List.generate(
              BIN_COUNT,
              (i) => HistogramData(
                    upper: bounds.minSpeed + (i + 1) * binSize,
                    range: ' - ${bounds.minSpeed + (i + 1) * binSize}',
                  ));
          _tileConfigurations["speed"] = tileConfig;
        }
        if (bounds.minCadence < MIN_INIT) {
          _tiles.add("cadence");
          final binSize = (bounds.maxCadence - bounds.minCadence) / BIN_COUNT;
          final tileConfig = TileConfiguration(
            title: "Cadence (rpm)",
            dataFn: _getCadenceData,
            binSize: binSize,
          );
          tileConfig.histogram = List.generate(
              BIN_COUNT,
              (i) => HistogramData(
                    upper: bounds.minCadence + (i + 1) * binSize,
                    range: ' - ${bounds.minCadence + (i + 1) * binSize}',
                  ));
          _tileConfigurations["cadence"] = tileConfig;
        }
        if (bounds.minHr < MIN_INIT) {
          _tiles.add("hr");
          final binSize = (bounds.maxHr - bounds.minHr) / BIN_COUNT;
          final tileConfig = TileConfiguration(
            title: "Cadence (rpm)",
            dataFn: _getHRData,
            binSize: (bounds.maxHr - bounds.minHr) / BIN_COUNT,
          );
          tileConfig.histogram = List.generate(
              BIN_COUNT,
              (i) => HistogramData(
                    upper: bounds.minHr + (i + 1) * binSize,
                    range: ' - ${bounds.minHr + (i + 1) * binSize}',
                  ));
          _tileConfigurations["hr"] = tileConfig;
        }
        _allRecords.forEach((record) {
          if (bounds.minPower < MIN_INIT) {
            if (record.power > 0) {
              var tileConfig = _tileConfigurations["power"];
              int binIndex = min(BIN_COUNT - 1,
                  (record.power - bounds.minPower) ~/ tileConfig.binSize);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (bounds.minSpeed < MIN_INIT) {
            if (record.speed > 0) {
              var tileConfig = _tileConfigurations["speed"];
              int binIndex = min(BIN_COUNT - 1,
                  (record.speed - bounds.minSpeed) ~/ tileConfig.binSize);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (bounds.minCadence < MIN_INIT) {
            if (record.cadence > 0) {
              var tileConfig = _tileConfigurations["cadence"];
              int binIndex = min(BIN_COUNT - 1,
                  (record.cadence - bounds.minCadence) ~/ tileConfig.binSize);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (bounds.minHr < MIN_INIT) {
            if (record.heartRate > 0) {
              var tileConfig = _tileConfigurations["hr"];
              int binIndex = min(BIN_COUNT - 1,
                  (record.heartRate - bounds.minHr) ~/ tileConfig.binSize);
              tileConfig.histogram[binIndex].increment();
            }
          }
        });
        _tileConfigurations["power"].histogramFn = _getPowerHistogram;
        _tileConfigurations["speed"].histogramFn = _getSpeedHistogram;
        _tileConfigurations["cadence"].histogramFn = _getCadenceHistogram;
        _tileConfigurations["hr"].histogramFn = _getHrHistogram;
        _allRecords = null;
        _initialized = true;
      });
    });
  }

  List<Series<Record, DateTime>> _getPowerData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'power',
        colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.power,
        data: _sampledRecords,
      ),
    ];
  }

  List<Series<HistogramData, String>> _getPowerHistogram() {
    return <Series<HistogramData, String>>[
      Series<HistogramData, String>(
        id: 'powerHistogram',
        colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.count,
        data: _tileConfigurations["power"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getSpeedData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'Speed (km/h)',
        colorFn: (_, __) => MaterialPalette.indigo.shadeDefault,
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.speed,
        data: _sampledRecords,
      ),
    ];
  }

  List<Series<HistogramData, String>> _getSpeedHistogram() {
    return <Series<HistogramData, String>>[
      Series<HistogramData, String>(
        id: 'speedHistogram',
        colorFn: (_, __) => MaterialPalette.indigo.shadeDefault,
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.count,
        data: _tileConfigurations["speed"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getCadenceData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'Cadence (rpm)',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.cadence,
        data: _sampledRecords,
      ),
    ];
  }

  List<Series<HistogramData, String>> _getCadenceHistogram() {
    return <Series<HistogramData, String>>[
      Series<HistogramData, String>(
        id: 'speedHistogram',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.count,
        data: _tileConfigurations["cadence"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getHRData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'Heart Rate (bpm)',
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.heartRate,
        data: _sampledRecords,
      ),
    ];
  }

  List<Series<HistogramData, String>> _getHrHistogram() {
    return <Series<HistogramData, String>>[
      Series<HistogramData, String>(
        id: 'hrHistogram',
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.count,
        data: _tileConfigurations["hr"].histogram,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        actions: <Widget>[
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
              paginationMode: PaginationMode.page,
              initialOffset: 0,
              loadingBuilder: CustomListLoading.defaultBuilder,
              separatorBuilder: (context, _) {
                return Divider(height: 2);
              },
              header: Center(
                child: Column(
                  children: [
                    Text('Device: ${activity.deviceName}'),
                    Text('Elapsed: ${activity.elapsed} s'),
                    Text('Distance: ${activity.distance.toStringAsFixed(1)} m'),
                    Text('Calories: ${activity.calories} kCal'),
                  ],
                ),
              ),
              adapter: StaticListAdapter(data: _tiles),
              itemBuilder: (context, _, item) {
                return ListTile(
                  title: Text(_tileConfigurations[item].title),
                  subtitle: Column(children: [
                    SizedBox(
                      width: size.width,
                      height: size.height / 5,
                      child: TimeSeriesChart(
                        _tileConfigurations[item].dataFn(),
                        animate: true,
                        primaryMeasureAxis: NumericAxisSpec(
                          tickProviderSpec:
                              BasicNumericTickProviderSpec(zeroBound: false),
                        ),
                        behaviors: [
                          LinePointHighlighter(
                            showHorizontalFollowLine:
                                LinePointHighlighterFollowLineType.none,
                            showVerticalFollowLine:
                                LinePointHighlighterFollowLineType.nearest,
                          ),
                          SelectNearest(
                              eventTrigger: SelectionTrigger.tapAndDrag),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      height: size.height / 5,
                      child: BarChart(
                        _tileConfigurations[item].histogramFn(),
                        animate: true,
                        primaryMeasureAxis: NumericAxisSpec(
                          tickProviderSpec:
                              BasicNumericTickProviderSpec(zeroBound: false),
                        ),
                        behaviors: [
                          LinePointHighlighter(
                            showHorizontalFollowLine:
                                LinePointHighlighterFollowLineType.none,
                            showVerticalFollowLine:
                                LinePointHighlighterFollowLineType.nearest,
                          ),
                          SelectNearest(
                              eventTrigger: SelectionTrigger.tapAndDrag),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
