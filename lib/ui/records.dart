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

typedef DataFn = List<Series<Record, DateTime>> Function();

class TileConfiguration {
  final String title;
  final DataFn dataFn;
  final DataFn histogramFn;

  TileConfiguration({this.title, this.dataFn, this.histogramFn});
}

class RecordsScreenState extends State<RecordsScreen> {
  RecordsScreenState({this.activity, this.size});

  final Activity activity;
  final Size size;
  int _count;
  List<Record> _allRecords;
  List<Record> _sampledRecords;
  Map<String, TileConfiguration> tileConfigurations;

  @override
  initState() {
    super.initState();
    tileConfigurations = {
      "power": TileConfiguration(title: "Power (W)", dataFn: _getPowerData),
      "speed": TileConfiguration(title: "Speed (km/h)", dataFn: _getSpeedData),
      "cadence": TileConfiguration(title: "Cadence (rpm)", dataFn: _getCadenceData),
      "hr": TileConfiguration(title: "Heart Rate (bpm)", dataFn: _getHRData),
    };
    $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build()
        .then((db) async {
      _allRecords = await db.recordDao.findAllActivityRecords(activity.id);
      setState(() {
        _count = size.width.toInt() - 20;
        if (_allRecords.length < _count) {
          _sampledRecords = _allRecords
              .map((r) => r.hydrate()).toList(growable: false);
        } else {
          final nth = _allRecords.length / _count;
          _sampledRecords = List.generate(
              _count,
              (i) => _allRecords[((i + 1) * nth - 1).round()].hydrate());
        }
        _allRecords = null;
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
      body: _sampledRecords == null
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
              adapter: StaticListAdapter(data: ["power", "speed", "cadence", "hr"]),
              itemBuilder: (context, _, item) {
                return ListTile(
                  title: Text(tileConfigurations[item].title),
                  subtitle: Column(children: [
                    SizedBox(
                      width: size.width,
                      height: size.height / 5,
                      child: TimeSeriesChart(
                        tileConfigurations[item].dataFn(),
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
                          SelectNearest(eventTrigger: SelectionTrigger.tapAndDrag),
                        ],
                      ),
                    ),
                  ]),
                );
              },
          ),

/*
      Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Power (W)"),
                SizedBox(
                  width: size.width,
                  height: size.height / 5,
                  child: TimeSeriesChart(
                    _getPowerData(),
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
                      SelectNearest(eventTrigger: SelectionTrigger.tapAndDrag),
                    ],
                  ),
                ),
                Divider(height: separatorHeight),
                Text("Speed (km/h)"),
                SizedBox(
                  width: size.width,
                  height: size.height / 5,
                  child: TimeSeriesChart(
                    _getSpeedData(),
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
                      SelectNearest(eventTrigger: SelectionTrigger.tapAndDrag),
                    ],
                  ),
                ),
                Divider(height: separatorHeight),
                Text("Cadence (rpm)"),
                SizedBox(
                  width: size.width,
                  height: size.height / 5,
                  child: TimeSeriesChart(
                    _getCadenceData(),
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
                      SelectNearest(eventTrigger: SelectionTrigger.tapAndDrag),
                    ],
                  ),
                ),
                Divider(height: separatorHeight),
                Text("Heart Rate (bpm)"),
                SizedBox(
                  width: size.width,
                  height: size.height / 5,
                  child: TimeSeriesChart(
                    _getHRData(),
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
                      SelectNearest(eventTrigger: SelectionTrigger.tapAndDrag),
                    ],
                  ),
                ),
              ],
            ),*/
    );
  }
}
