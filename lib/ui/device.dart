import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/devices.dart';
import '../devices/device_descriptor.dart';
import '../devices/gatt_constants.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/utils.dart';
import 'activities.dart';

const UX_DEBUG = false;
const Map<int, int> ROW_TO_EXTRA = {
  0: 0,
  1: 1,
  2: 1,
  3: 2,
  4: 3,
  5: 4,
  6: 0,
};

typedef DataFn = List<charts.Series<Record, DateTime>> Function();

class RowConfig {
  final IconData icon;
  final String unit;

  RowConfig({this.icon, this.unit});
}

extension DeviceIdentification on BluetoothDevice {
  DeviceDescriptor getDescriptor() {
    for (var dev in deviceMap.values) {
      if (name.startsWith(dev.namePrefix)) {
        return dev;
      }
    }

    // Default to standard GATT (Schwinn IC4/IC8)
    return deviceMap['SIC4'];
  }
}

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothDeviceState initialState;
  final Size size;

  DeviceScreen({
    Key key,
    this.device,
    this.initialState,
    this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeviceState(device: device, initialState: initialState, size: size);
  }
}

class DeviceState extends State<DeviceScreen> {
  DeviceState({this.device, this.initialState, this.size}) {
    this.descriptor = device.getDescriptor();
  }

  Size size;
  // Track drawing cached computed values
  static Size trackSize;
  static Paint trackStroke;
  static Path trackPath;
  static Offset trackOffset;
  static double trackRadius;

  final BluetoothDevice device;
  final BluetoothDeviceState initialState;
  DeviceDescriptor descriptor;
  BluetoothCharacteristic _primaryMeasurements;
  BluetoothCharacteristic _cadenceMeasurements;
  bool _discovered;
  bool _measuring;
  bool _paused;
  DateTime _pauseStarted;
  Duration _idleDuration;
  int _time; // cumulative elapsed (auto pause)
  int _calories; // cumulative (kCal)
  int _power; // snapshot (W)
  double _speed; // snapshot (km/h)
  int _cadence; // snapshot (rpm)
  int _heartRate; // snapshot (bpm)
  double _distance; // cumulative (m)
  int _selectedRow;
  int _extraDisplayIndex;
  int _pointCount;
  ListQueue<Record> _graphData;
  TextStyle _unselectedUnitStyle;
  TextStyle _selectedUnitStyle;

  int _lastElapsed;
  Activity _activity;
  AppDatabase _database;
  bool _si;

  // Debugging UX without actual connected device
  Timer _timer;
  final _random = Random();

  List<Record> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfig> _rowConfig;
  List<String> _values;

  _initialConnectOnDemand() async {
    if (initialState == BluetoothDeviceState.disconnected) {
      await device.connect().then((value) async {
        await _discoverServices();
      });
    } else if (initialState == BluetoothDeviceState.connected && !_discovered) {
      await _discoverServices();
    }
  }

  bool _areListsEqual(var list1, var list2) {
    if (!(list1 is List && list2 is List) || list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  _addGraphData(Record record) {
    _graphData.add(record.hydrate());
    if (_pointCount > 0 && _graphData.length > _pointCount) {
      _graphData.removeFirst();
    }
  }

  _fillValues(Record record) {
    _values = [
      record.calories.toString(),
      record.power.toString(),
      record.speedByUnit(_si).toStringAsFixed(1),
      record.cadence.toString(),
      record.heartRate.toString(),
      record.distanceStringByUnit(_si),
    ];
  }

  _recordMeasurement(List<int> data) async {
    if (!descriptor.canPrimaryMeasurementProcessed(data)) return;

    Duration currentIdle = Duration();
    if (_paused) {
      currentIdle = DateTime.now().difference(_pauseStarted);
    }

    final record = descriptor.processPrimaryMeasurement(
      _activity,
      _lastElapsed,
      _idleDuration + currentIdle,
      _speed,
      _distance,
      _calories,
      _cadence,
      data,
      null,
    );

    if (!_paused && _measuring) {
      if (record.elapsed != _lastElapsed) {
        await _database?.recordDao?.insertRecord(record);
      }
      _addGraphData(record);
    }

    setState(() {
      _time = record.elapsed;
      _calories = record.calories;
      _power = record.power;
      _speed = record.speed;
      _cadence = record.cadence;
      _heartRate = record.heartRate;

      if (_speed > 0 && !_paused) {
        _distance = record.distance;
      }

      _fillValues(record);

      if (_measuring) {
        if (_speed <= 0) {
          _pauseStarted = DateTime.now();
          _paused = true;
        } else {
          _paused = false;
          _idleDuration += currentIdle;
        }
      }
      _lastElapsed = record.elapsed;
    });
  }

  _processCadenceMeasurement(List<int> data) {
    if (!descriptor.canCadenceMeasurementProcessed(data)) return;

    _cadence = descriptor.processCadenceMeasurement(data);
  }

  BluetoothService _filterService(List<BluetoothService> services, identifier) {
    return services.firstWhere(
        (service) =>
            service.uuid.toString().substring(4, 8).toLowerCase() == identifier,
        orElse: () => null);
  }

  BluetoothCharacteristic _filterCharacteristic(
      List<BluetoothCharacteristic> characteristics, identifier) {
    return characteristics.firstWhere(
        (ch) => ch.uuid.toString().substring(4, 8).toLowerCase() == identifier,
        orElse: () => null);
  }

  _discoverServices() async {
    await device.discoverServices().then((services) async {
      if (_primaryMeasurements != null) {
        return services;
      }

      setState(() {
        _discovered = true;
      });
      final deviceInfo = _filterService(services, deviceInformationId);
      final nameCharacteristic =
          _filterCharacteristic(deviceInfo.characteristics, manufacturerNameId);
      var name;
      try {
        name = await nameCharacteristic.read();
      } on PlatformException catch (e, stack) {
        debugPrint("${e.message}");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }

      if (name == null) {
        return services;
      }

      if (_areListsEqual(name, descriptor.manufacturer)) {
        if (descriptor.cadenceMeasurementServiceId != '') {
          final cadenceMeasurementService =
              _filterService(services, descriptor.cadenceMeasurementServiceId);
          if (cadenceMeasurementService != null) {
            _cadenceMeasurements = _filterCharacteristic(
                cadenceMeasurementService.characteristics,
                descriptor.cadenceMeasurementId);
          }
          if (_cadenceMeasurements != null) {
            await _cadenceMeasurements.setNotifyValue(true);
            _cadenceMeasurements.value.listen((data) async {
              if (data != null && data.length > 1) {
                await _processCadenceMeasurement(data);
              }
            });
          }
        }
        final measurementService1 =
            _filterService(services, descriptor.primaryMeasurementServiceId);
        if (measurementService1 != null) {
          _primaryMeasurements = _filterCharacteristic(
              measurementService1.characteristics,
              descriptor.primaryMeasurementId);
          if (_primaryMeasurements != null) {
            await _primaryMeasurements.setNotifyValue(true);
            _primaryMeasurements.value.listen((data) async {
              if (data != null && data.length > 1) {
                await _recordMeasurement(data);
              }
            });
            _measuring = true;
            _paused = false;

            final now = DateTime.now();
            _activity = Activity(
              fourCC: descriptor.fourCC,
              deviceName: device.name,
              deviceId: device.id.id,
              start: now.millisecondsSinceEpoch,
              startDateTime: now,
            );
            final id = await _database?.activityDao?.insertActivity(_activity);
            _activity.id = id;
          }
        }
      } else {
        Get.defaultDialog(
          middleText:
              'The device does not look like a ${descriptor.fullName}. ' +
                  'Measurement is not started',
          confirm: FlatButton(
            child: Text("Ok"),
            onPressed: () => Get.close(1),
          ),
        );
      }
      return services;
    });
  }

  _openDatabase() async {
    _database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3]).build();
  }

  @override
  initState() {
    super.initState();
    _selectedRow = 0;
    _extraDisplayIndex = ROW_TO_EXTRA[_selectedRow];
    _pointCount = size.width ~/ 2;
    _graphData = ListQueue<Record>(_pointCount);
    _unselectedUnitStyle = TextStyle(
      fontFamily: 'DSEG14',
      color: Colors.indigo,
    );
    _selectedUnitStyle = TextStyle(
      fontFamily: 'DSEG14',
      color: Colors.indigo,
    );
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    preferencesSpecs[1].unit = _si ? 'kmh' : 'mph';
    preferencesSpecs.forEach((prefSpec) => prefSpec.calculateZones());
    preferencesSpecs.forEach((prefSpec) => prefSpec.calculateBounds(
          0,
          prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0,
        ));

    _metricToDataFn = {
      "power": _powerChartData,
      "speed": _speedChartData,
      "cadence": _cadenceChartData,
      "hr": _hRChartData,
    };

    _rowConfig = [
      RowConfig(icon: Icons.whatshot, unit: 'cal'),
      RowConfig(icon: Icons.bolt, unit: preferencesSpecs[0].unit),
      RowConfig(icon: Icons.speed, unit: preferencesSpecs[1].unit),
      RowConfig(icon: Icons.directions_bike, unit: preferencesSpecs[2].unit),
      RowConfig(icon: Icons.favorite, unit: preferencesSpecs[3].unit),
      RowConfig(icon: Icons.add_road, unit: _si ? 'm' : 'mi'),
    ];

    _discovered = false;
    _measuring = false;
    _paused = false;
    _idleDuration = Duration();
    _time = 0;
    _calories = 0;
    _power = 0;
    _speed = 0;
    _cadence = 0;
    _heartRate = 0;
    _lastElapsed = 0;
    _distance = UX_DEBUG ? _random.nextInt(100000).toDouble() : 0;
    _values = ["N/A", "N/A", "N/A", "N/A", "N/A", "N/A"];

    if (UX_DEBUG) {
      _simulateMeasurements();
    } else {
      _initialConnectOnDemand();
      _openDatabase();
    }

    Wakelock.enable();
  }

  @override
  dispose() {
    _timer?.cancel();
    _primaryMeasurements?.setNotifyValue(false);
    _cadenceMeasurements?.setNotifyValue(false);
    _database?.close();
    Wakelock.disable();
    super.dispose();
  }

  void _simulateMeasurements() {
    setState(() {
      final rightNow = DateTime.now();
      _time++;
      _calories = _random.nextInt(1500);
      _power = 50 + _random.nextInt(500);
      _speed = 15.0 + _random.nextDouble() * 15.0;
      _cadence = 30 + _random.nextInt(100);
      _heartRate = 60 + _random.nextInt(120);
      _distance += _random.nextInt(10);

      final simulatedRecord = Record(
        timeStamp: rightNow.millisecondsSinceEpoch,
        distance: _distance,
        elapsed: _time,
        calories: _calories,
        power: _power,
        speed: _speed,
        cadence: _cadence,
        heartRate: _heartRate,
      );
      _fillValues(simulatedRecord);
      _addGraphData(simulatedRecord);

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: rightNow.millisecond),
        _simulateMeasurements,
      );
    });
  }

  _finishActivity() async {
    if (!_measuring) return;

    Duration currentIdle = Duration();
    if (_paused) {
      currentIdle = DateTime.now().difference(_pauseStarted);
    }

    setState(() {
      _measuring = false;
      _paused = true;
    });

    // Add one last record for the time of stopping
    final supplement = Record(
      distance: _distance,
      elapsed: _time,
      calories: _calories,
      power: _power,
      speed: _speed,
      cadence: _cadence,
      heartRate: _heartRate,
    );
    final record = descriptor.processPrimaryMeasurement(
      _activity,
      _lastElapsed,
      _idleDuration + currentIdle,
      _speed,
      _distance,
      _calories,
      _cadence,
      null,
      supplement,
    );

    await _database?.recordDao?.insertRecord(record);

    _activity.finish(
      _distance,
      _time,
      _calories.toInt(),
    );
    // final changed =
    await _database?.activityDao?.updateActivity(_activity);
  }

  Color getExtraColor(int rowIndex) {
    if (_selectedRow == rowIndex) {
      return Colors.red;
    }
    return Colors.indigo;
  }

  TextStyle getTextStyle(int rowIndex) {
    if (_selectedRow == rowIndex) {
      return _selectedUnitStyle;
    }
    return _unselectedUnitStyle;
  }

  _onRowTap(int rowIndex) {
    setState(() {
      _selectedRow = rowIndex;
      _extraDisplayIndex = ROW_TO_EXTRA[rowIndex];
    });
  }

  List<charts.Series<Record, DateTime>> _powerChartData() {
    return <charts.Series<Record, DateTime>>[
      charts.Series<Record, DateTime>(
        id: 'power',
        colorFn: (Record record, __) =>
            preferencesSpecs[0].binFgColor(record.power),
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.power,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<Record, DateTime>> _speedChartData() {
    return <charts.Series<Record, DateTime>>[
      charts.Series<Record, DateTime>(
        id: 'speed',
        colorFn: (Record record, __) =>
            preferencesSpecs[1].binFgColor(record.speedByUnit(_si)),
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.speedByUnit(_si),
        data: graphData,
      ),
    ];
  }

  List<charts.Series<Record, DateTime>> _cadenceChartData() {
    return <charts.Series<Record, DateTime>>[
      charts.Series<Record, DateTime>(
        id: 'cadence',
        colorFn: (Record record, __) =>
            preferencesSpecs[2].binFgColor(record.cadence),
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.cadence,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<Record, DateTime>> _hRChartData() {
    return <charts.Series<Record, DateTime>>[
      charts.Series<Record, DateTime>(
        id: 'hr',
        colorFn: (Record record, __) =>
            preferencesSpecs[3].binFgColor(record.heartRate),
        domainFn: (Record record, _) => record.dt,
        measureFn: (Record record, _) => record.heartRate,
        data: graphData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final separatorHeight = 3.0;
    final double sizeDefault = Get.mediaQuery.size.width / 7;

    final measurementStyle = TextStyle(
      fontFamily: 'DSEG7',
      fontSize: sizeDefault,
    );
    _unselectedUnitStyle = TextStyle(
      fontFamily: 'DSEG14',
      fontSize: sizeDefault / 3,
      color: Colors.indigo,
    );
    _selectedUnitStyle = TextStyle(
      fontFamily: 'DSEG14',
      fontSize: sizeDefault / 3,
      color: Colors.red,
    );

    final _timeDisplay = Duration(seconds: _latestRecord.elapsed).toDisplay();
    final trackMarker = calculateTrackMarker(trackSize, _latestRecord.distance);

    List<Widget> rows = [
      GestureDetector(
        onTap: () => _onRowTap(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.timer, size: sizeDefault, color: getExtraColor(0)),
            Text(_timeDisplay, style: measurementStyle),
          ],
        ),
      ),
    ];

    _rowConfig.asMap().entries.forEach((entry) {
      rows.add(Divider(height: separatorHeight));
      rows.add(GestureDetector(
        onTap: () => _onRowTap(entry.key + 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _rowConfig[entry.key].icon,
              size: sizeDefault,
              color: getExtraColor(entry.key + 1),
            ),
            Spacer(),
            Text(_values[entry.key], style: measurementStyle),
            SizedBox(
              width: sizeDefault,
              child: Text(
                _rowConfig[entry.key].unit,
                style: getTextStyle(entry.key + 1),
              ),
            ),
          ],
        ),
      ));
    });

    List<Widget> extras = [
      CustomPaint(
        painter: TrackPainter(),
        child: trackMarker == null
            ? SizedBox(width: 0, height: 0)
            : Stack(
                children: <Widget>[
                  Positioned(
                    left: trackMarker.dx - THICK,
                    top: trackMarker.dy - THICK,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color(0x88FF0000),
                          borderRadius: BorderRadius.circular(THICK),
                        ),
                        width: THICK * 2,
                        height: THICK * 2),
                  ),
                ],
              ),
      ),
    ];

    preferencesSpecs.forEach((prefSpec) {
      extras.add(
        charts.TimeSeriesChart(
          _metricToDataFn[prefSpec.metric](),
          animate: false,
          behaviors: [
            charts.RangeAnnotation(
              List.generate(
                prefSpec.binCount,
                (i) => charts.RangeAnnotationSegment(
                  prefSpec.zoneLower[i],
                  prefSpec.zoneUpper[i],
                  charts.RangeAnnotationAxisType.measure,
                  color: prefSpec.binBgColor(i),
                ),
              ),
            )
          ],
        ),
      );
    });

    rows.add(Divider(height: separatorHeight));
    rows.add(Expanded(
      child: IndexedStack(
        index: _extraDisplayIndex,
        children: extras,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              IconData icon;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = null;
                  icon = Icons.bluetooth_connected;
                  if (!_discovered) {
                    _discoverServices();
                  }
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  icon = Icons.bluetooth_disabled;
                  break;
                default:
                  onPressed = null;
                  icon = Icons.bluetooth_searching;
                  break;
              }
              return IconButton(
                icon: Icon(icon),
                onPressed: onPressed,
              );
            },
          ),
          IconButton(
            icon: Icon(_measuring ? Icons.stop : Icons.play_arrow),
            onPressed: () async => _measuring
                ? await _finishActivity()
                : (await device.state.last == BluetoothDeviceState.disconnected
                    ? device.connect()
                    : _discoverServices()),
          ),
          IconButton(
            icon: Icon(BrandIcons.strava),
            onPressed: () async {
              StravaService stravaService;
              if (!Get.isRegistered<StravaService>()) {
                stravaService = Get.put<StravaService>(StravaService());
              } else {
                stravaService = Get.find<StravaService>();
              }
              final success = await stravaService.login();
              if (!success) {
                Get.snackbar("Warning", "Strava login unsuccessful");
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () async => _measuring
                ? Get.snackbar(
                    "Warning", "Cannot navigate away during measurement!")
                : await Get.to(ActivitiesScreen()),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
