import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
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
  final int index;
  final double upper;
  int count;
  int percent;
  final String range;

  HistogramData({this.index, this.upper, this.range}) {
    count = 0;
    percent = 0;
  }

  increment() {
    count++;
  }

  calculatePercent(int total) {
    if (count > 0) {
      percent = total * 100 ~/ count;
    }
  }
}

class MeasurementCounter {
  int powerCounter = 0;
  int speedCounter = 0;
  int cadenceCounter = 0;
  int hrCounter = 0;

  processRecord(Record record) {
    if (record.power > 0) {
      powerCounter++;
    }
    if (record.speed > 0) {
      speedCounter++;
    }
    if (record.cadence > 0) {
      cadenceCounter++;
    }
    if (record.heartRate > 0) {
      hrCounter++;
    }
  }

  bool get hasPower => powerCounter > 0;
  bool get hasSpeed => speedCounter > 0;
  bool get hasCadence => cadenceCounter > 0;
  bool get hasHeartRate => hrCounter > 0;
}

typedef DataFn = List<Series<Record, DateTime>> Function();
typedef HistogramFn = List<Series<HistogramData, String>> Function();

class TileConfiguration {
  final String title;
  final DataFn dataFn;
  HistogramFn histogramFn;
  final List<double> zoneBounds;
  int count;
  List<HistogramData> histogram;

  TileConfiguration({this.title, this.dataFn, this.zoneBounds}) {
    count = 0;
  }
  bool get hasMeasurement => count > 0;
}

class RecordsScreenState extends State<RecordsScreen> {
  RecordsScreenState({this.activity, this.size});

  final Activity activity;
  final Size size;
  int _pointCount;
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
        _pointCount = size.width.toInt() - 20;
        if (_allRecords.length < _pointCount) {
          _sampledRecords =
              _allRecords.map((r) => r.hydrate()).toList(growable: false);
        } else {
          final nth = _allRecords.length / _pointCount;
          _sampledRecords = List.generate(_pointCount,
              (i) => _allRecords[((i + 1) * nth - 1).round()].hydrate());
        }
        final measurementCounter = MeasurementCounter();
        _allRecords.forEach((record) {
          measurementCounter.processRecord(record);
        });
        preferencesSpecs.forEach((prefSpec) => prefSpec.calculateZones());

        if (measurementCounter.hasPower) {
          _tiles.add("power");
          final tileConfig = TileConfiguration(
            title: "Power (W)",
            dataFn: _getPowerData,
          );
          tileConfig.histogram =
              preferencesSpecs[0].zoneBounds.asMap().entries.map(
                    (entry) => HistogramData(
                      index: entry.key,
                      upper: entry.value,
                      range: '<${entry.value.toStringAsFixed(0)}',
                    ),
                  ).toList();
          tileConfig.histogram.add(HistogramData(
            index: preferencesSpecs[0].binCount - 1,
            upper: 0,
            range: '>${preferencesSpecs[0].zoneBounds.last.toStringAsFixed(0)}',
          ));
          _tileConfigurations["power"] = tileConfig;
        }
        if (measurementCounter.hasSpeed) {
          _tiles.add("speed");
          final tileConfig = TileConfiguration(
            title: "Speed (km/h)",
            dataFn: _getSpeedData,
          );
          tileConfig.histogram =
              preferencesSpecs[1].zoneBounds.asMap().entries.map(
                    (entry) => HistogramData(
                      index: entry.key,
                      upper: entry.value,
                      range: '<${entry.value.toStringAsFixed(0)}',
                    ),
                  ).toList();
          tileConfig.histogram.add(HistogramData(
            index: preferencesSpecs[0].binCount - 1,
            upper: 0,
            range: '>${preferencesSpecs[1].zoneBounds.last.toStringAsFixed(0)}',
          ));
          _tileConfigurations["speed"] = tileConfig;
        }
        if (measurementCounter.hasCadence) {
          _tiles.add("cadence");
          final tileConfig = TileConfiguration(
            title: "Cadence (rpm)",
            dataFn: _getCadenceData,
          );
          tileConfig.histogram =
              preferencesSpecs[2].zoneBounds.asMap().entries.map(
                    (entry) => HistogramData(
                      index: entry.key,
                      upper: entry.value,
                      range: '<${entry.value.toStringAsFixed(0)}',
                    ),
                  ).toList();
          tileConfig.histogram.add(HistogramData(
            index: preferencesSpecs[0].binCount - 1,
            upper: 0,
            range: '>${preferencesSpecs[2].zoneBounds.last.toStringAsFixed(0)}',
          ));
          _tileConfigurations["cadence"] = tileConfig;
        }
        if (measurementCounter.hasHeartRate) {
          _tiles.add("hr");
          final tileConfig = TileConfiguration(
            title: "Cadence (rpm)",
            dataFn: _getHRData,
          );
          tileConfig.histogram =
              preferencesSpecs[3].zoneBounds.asMap().entries.map(
                    (entry) => HistogramData(
                      index: entry.key,
                      upper: entry.value,
                      range: '<${entry.value.toStringAsFixed(0)}',
                    ),
                  ).toList();
          tileConfig.histogram.add(HistogramData(
            index: preferencesSpecs[0].binCount - 1,
            upper: 0,
            range: '>${preferencesSpecs[3].zoneBounds.last.toStringAsFixed(0)}',
          ));
          _tileConfigurations["hr"] = tileConfig;
        }
        _allRecords.forEach((record) {
          if (measurementCounter.hasPower) {
            if (record.power > 0) {
              var tileConfig = _tileConfigurations["power"];
              tileConfig.count++;
              final binIndex = preferencesSpecs[0].binIndex(record.power);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (measurementCounter.hasSpeed) {
            if (record.speed > 0) {
              var tileConfig = _tileConfigurations["speed"];
              tileConfig.count++;
              final binIndex = preferencesSpecs[1].binIndex(record.speed);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (measurementCounter.hasCadence) {
            if (record.cadence > 0) {
              var tileConfig = _tileConfigurations["cadence"];
              tileConfig.count++;
              final binIndex = preferencesSpecs[2].binIndex(record.cadence);
              tileConfig.histogram[binIndex].increment();
            }
          }
          if (measurementCounter.hasHeartRate) {
            if (record.heartRate > 0) {
              var tileConfig = _tileConfigurations["hr"];
              tileConfig.count++;
              final binIndex = preferencesSpecs[3].binIndex(record.heartRate);
              tileConfig.histogram[binIndex].increment();
            }
          }
        });
        if (measurementCounter.hasPower) {
          var tileConfig = _tileConfigurations["power"];
          tileConfig.histogram.forEach((h) {
            h.calculatePercent(tileConfig.count);
          });
          tileConfig.histogramFn = _getPowerHistogram;
        }
        if (measurementCounter.hasSpeed) {
          var tileConfig = _tileConfigurations["speed"];
          tileConfig.histogram.forEach((h) {
            h.calculatePercent(tileConfig.count);
          });
          tileConfig.histogramFn = _getSpeedHistogram;
        }
        if (measurementCounter.hasCadence) {
          var tileConfig = _tileConfigurations["cadence"];
          tileConfig.histogram.forEach((h) {
            h.calculatePercent(tileConfig.count);
          });
          tileConfig.histogramFn = _getCadenceHistogram;
        }
        if (measurementCounter.hasHeartRate) {
          var tileConfig = _tileConfigurations["hr"];
          tileConfig.histogram.forEach((h) {
            h.calculatePercent(tileConfig.count);
          });
          tileConfig.histogramFn = _getHrHistogram;
        }
        _allRecords = null;
        _initialized = true;
      });
    });
  }

  List<Series<Record, DateTime>> _getPowerData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'power',
        colorFn: (Record record, __) =>
            preferencesSpecs[0].binFgColor(record.power),
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
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[0].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.percent,
        data: _tileConfigurations["power"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getSpeedData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'speed',
        colorFn: (Record record, __) =>
            preferencesSpecs[1].binFgColor(record.speed),
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
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[1].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.percent,
        data: _tileConfigurations["speed"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getCadenceData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'cadence',
        colorFn: (Record record, __) =>
            preferencesSpecs[2].binFgColor(record.cadence),
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
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[2].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.percent,
        data: _tileConfigurations["cadence"].histogram,
      ),
    ];
  }

  List<Series<Record, DateTime>> _getHRData() {
    return <Series<Record, DateTime>>[
      Series<Record, DateTime>(
        id: 'hr',
        colorFn: (Record record, __) =>
            preferencesSpecs[3].binFgColor(record.heartRate),
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
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[3].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.range,
        measureFn: (HistogramData data, _) => data.percent,
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
              paginationMode: PaginationMode.offset,
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
                        // primaryMeasureAxis: NumericAxisSpec(
                        //   tickProviderSpec:
                        //       BasicNumericTickProviderSpec(zeroBound: false),
                        // ),
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
