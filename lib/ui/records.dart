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

  HistogramData({this.index, this.upper}) {
    count = 0;
    percent = 0;
  }

  increment() {
    count++;
  }

  calculatePercent(int total) {
    if (total > 0) {
      percent = count * 100 ~/ total;
    } else {
      percent = 0;
    }
  }
}

const MIN_INIT = 10000;

class MeasurementCounter {
  int powerCounter = 0;
  int minPower = MIN_INIT;
  int maxPower = 0;

  int speedCounter = 0;
  double minSpeed = MIN_INIT.toDouble();
  double maxSpeed = 0;

  int cadenceCounter = 0;
  int minCadence = MIN_INIT;
  int maxCadence = 0;

  int hrCounter = 0;
  int minHr = MIN_INIT;
  int maxHr = 0;

  processRecord(Record record) {
    if (record.power > 0) {
      powerCounter++;
      maxPower = max(maxPower, record.power);
      minPower = min(minPower, record.power);
    }
    if (record.speed > 0) {
      speedCounter++;
      maxSpeed = max(maxSpeed, record.speed);
      minSpeed = min(minSpeed, record.speed);
    }
    if (record.cadence > 0) {
      cadenceCounter++;
      maxCadence = max(maxCadence, record.cadence);
      minCadence = min(minCadence, record.cadence);
    }
    if (record.heartRate > 0) {
      hrCounter++;
      maxHr = max(maxHr, record.heartRate);
      minHr = min(minHr, record.heartRate);
    }
  }

  bool get hasPower => powerCounter > 0;
  bool get hasSpeed => speedCounter > 0;
  bool get hasCadence => cadenceCounter > 0;
  bool get hasHeartRate => hrCounter > 0;
}

typedef DataFn = List<Series<Record, DateTime>> Function();
typedef HistogramFn = List<Series<HistogramData, double>> Function();

class TileConfiguration {
  final String title;
  final String histogramTitle;
  final DataFn dataFn;
  HistogramFn histogramFn;
  final List<double> zoneBounds;
  int count;
  List<HistogramData> histogram;

  TileConfiguration(
      {this.title, this.histogramTitle, this.dataFn, this.zoneBounds}) {
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
  String _elapsedString;

  @override
  initState() {
    super.initState();
    _initialized = false;
    _tileConfigurations = {};
    _tiles = [];
    $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3])
        .build()
        .then((db) async {
          _allRecords = await db.recordDao.findAllActivityRecords(activity.id);
          setState(() {
            _elapsedString = Duration(seconds: activity.elapsed)
                .toString()
                .split('.')
                .first
                .padLeft(8, "0");
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
              var prefSpec = preferencesSpecs[0];
              var tileConfig = TileConfiguration(
                title: prefSpec.fullTitle,
                histogramTitle: prefSpec.histogramTitle,
                dataFn: _getPowerData,
              );
              prefSpec.calculateBounds(measurementCounter.minPower.toDouble(),
                  measurementCounter.maxPower.toDouble());
              tileConfig.histogram = prefSpec.zoneBounds
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        HistogramData(index: entry.key, upper: entry.value),
                  )
                  .toList();
              tileConfig.histogram.add(HistogramData(
                index: prefSpec.binCount - 1,
                upper: 0,
              ));
              _tileConfigurations["power"] = tileConfig;
            }
            if (measurementCounter.hasSpeed) {
              _tiles.add("speed");
              var prefSpec = preferencesSpecs[1];
              var tileConfig = TileConfiguration(
                title: prefSpec.fullTitle,
                histogramTitle: prefSpec.histogramTitle,
                dataFn: _getSpeedData,
              );
              prefSpec.calculateBounds(
                  measurementCounter.minSpeed, measurementCounter.maxSpeed);
              tileConfig.histogram = prefSpec.zoneBounds
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        HistogramData(index: entry.key, upper: entry.value),
                  )
                  .toList();
              tileConfig.histogram.add(HistogramData(
                index: prefSpec.binCount - 1,
                upper: 0,
              ));
              _tileConfigurations["speed"] = tileConfig;
            }
            if (measurementCounter.hasCadence) {
              _tiles.add("cadence");
              var prefSpec = preferencesSpecs[2];
              var tileConfig = TileConfiguration(
                title: prefSpec.fullTitle,
                histogramTitle: prefSpec.histogramTitle,
                dataFn: _getCadenceData,
              );
              prefSpec.calculateBounds(measurementCounter.minCadence.toDouble(),
                  measurementCounter.maxCadence.toDouble());
              tileConfig.histogram = prefSpec.zoneBounds
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        HistogramData(index: entry.key, upper: entry.value),
                  )
                  .toList();
              tileConfig.histogram.add(HistogramData(
                index: prefSpec.binCount - 1,
                upper: 0,
              ));
              _tileConfigurations["cadence"] = tileConfig;
            }
            if (measurementCounter.hasHeartRate) {
              _tiles.add("hr");
              var prefSpec = preferencesSpecs[3];
              var tileConfig = TileConfiguration(
                title: prefSpec.fullTitle,
                histogramTitle: prefSpec.histogramTitle,
                dataFn: _getHRData,
              );
              prefSpec.calculateBounds(measurementCounter.minHr.toDouble(),
                  measurementCounter.maxHr.toDouble());
              tileConfig.histogram = prefSpec.zoneBounds
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        HistogramData(index: entry.key, upper: entry.value),
                  )
                  .toList();
              tileConfig.histogram.add(HistogramData(
                index: prefSpec.binCount - 1,
                upper: 0,
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
                  final binIndex =
                      preferencesSpecs[3].binIndex(record.heartRate);
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

  List<Series<HistogramData, double>> _getPowerHistogram() {
    return <Series<HistogramData, double>>[
      Series<HistogramData, double>(
        id: 'powerHistogram',
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[0].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.upper,
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

  List<Series<HistogramData, double>> _getSpeedHistogram() {
    return <Series<HistogramData, double>>[
      Series<HistogramData, double>(
        id: 'speedHistogram',
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[1].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.upper,
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

  List<Series<HistogramData, double>> _getCadenceHistogram() {
    return <Series<HistogramData, double>>[
      Series<HistogramData, double>(
        id: 'speedHistogram',
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[2].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.upper,
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

  List<Series<HistogramData, double>> _getHrHistogram() {
    return <Series<HistogramData, double>>[
      Series<HistogramData, double>(
        id: 'hrHistogram',
        colorFn: (HistogramData data, __) =>
            preferencesSpecs[3].binFgColor(data.index),
        domainFn: (HistogramData data, _) => data.upper,
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
                    Text('Elapsed: $_elapsedString'),
                    Text('Distance: ${activity.distance.toStringAsFixed(1)} m'),
                    Text('Calories: ${activity.calories} kCal'),
                  ],
                ),
              ),
              adapter: StaticListAdapter(data: _tiles),
              itemBuilder: (context, index, item) {
                return ListTile(
                  title: const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  subtitle: Column(children: [
                    Text(_tileConfigurations[item].title),
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
                                LinePointHighlighterFollowLineType.nearest,
                            showVerticalFollowLine:
                                LinePointHighlighterFollowLineType.nearest,
                          ),
                          SelectNearest(
                              eventTrigger: SelectionTrigger.tapAndDrag),
                          RangeAnnotation(
                            List.generate(
                              preferencesSpecs[index].binCount,
                              (i) => RangeAnnotationSegment(
                                preferencesSpecs[index].zoneLower[i],
                                preferencesSpecs[index].zoneUpper[i],
                                RangeAnnotationAxisType.measure,
                                color: preferencesSpecs[index].binBgColor(i),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(_tileConfigurations[item].histogramTitle),
                    SizedBox(
                      width: size.width,
                      height: size.height / 5,
                      child: LineChart(
                        _tileConfigurations[item].histogramFn(),
                        animate: true,
                        behaviors: [
                          LinePointHighlighter(
                            showHorizontalFollowLine:
                                LinePointHighlighterFollowLineType.nearest,
                            showVerticalFollowLine:
                                LinePointHighlighterFollowLineType.nearest,
                          ),
                          SelectNearest(
                              eventTrigger: SelectionTrigger.tapAndDrag),
                          RangeAnnotation(
                            List.generate(
                              preferencesSpecs[index].binCount,
                              (i) => RangeAnnotationSegment(
                                preferencesSpecs[index].zoneLower[i],
                                preferencesSpecs[index].zoneUpper[i],
                                RangeAnnotationAxisType.domain,
                                color: preferencesSpecs[index].binBgColor(i),
                              ),
                            ),
                          )
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
