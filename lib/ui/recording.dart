import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:charts_common/common.dart' as common;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:preferences/preferences.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/device_descriptor.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/error_codes.dart';
import '../strava/strava_service.dart';
import '../track/calculator.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import 'models/display_record.dart';
import 'models/row_configuration.dart';
import 'activities.dart';
import 'spin_down.dart';

typedef DataFn = List<charts.Series<DisplayRecord, DateTime>> Function();

class RecordingScreen extends StatefulWidget {
  final BluetoothDevice device;
  final List<String> serviceUuids;
  final BluetoothDeviceState initialState;
  final Size size;

  RecordingScreen({
    Key key,
    @required this.device,
    @required this.serviceUuids,
    @required this.initialState,
    @required this.size,
  })  : assert(device != null),
        assert(serviceUuids != null),
        assert(initialState != null),
        assert(size != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecordingState(
      device: device,
      serviceUuids: serviceUuids,
      initialState: initialState,
      size: size,
    );
  }
}

class RecordingState extends State<RecordingScreen> {
  RecordingState({
    @required this.device,
    @required this.serviceUuids,
    @required this.initialState,
    @required this.size,
  })  : assert(device != null),
        assert(serviceUuids != null),
        assert(initialState != null),
        assert(size != null) {
    this._descriptor = device.getDescriptor(serviceUuids);
  }

  Size size;

  final BluetoothDevice device;
  final List<String> serviceUuids;
  final BluetoothDeviceState initialState;
  HeartRateMonitor _heartRateMonitor;
  DeviceDescriptor _descriptor;
  TrackCalculator _trackCalculator;
  BluetoothCharacteristic _primaryMeasurements;
  StreamSubscription _measurementSubscription;
  BluetoothCharacteristic _cadenceMeasurements;
  StreamSubscription _cadenceSubscription;
  StreamSubscription _heartRateSubscription;
  bool _discovering;
  bool _measuring;
  bool _paused;
  DateTime _pauseStarted;
  Duration _idleDuration;
  int _pointCount;
  ListQueue<DisplayRecord> _graphData;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _measurementStyle;
  TextStyle _unitStyle;
  List<bool> _expandedState;
  List<ExpandableController> _rowControllers;
  List<int> _expandedHeights;
  List<PreferencesSpec> _preferencesSpecs;

  Record _latestRecord;
  Activity _activity;
  AppDatabase _database;
  bool _si;
  bool _simplerUi;
  bool _instantUpload;
  bool _uxDebug;

  // Debugging UX without actual connected device
  Timer _timer;
  final _random = Random();

  Timer _connectionWatchdog;
  int _connectionWatchdogTime = EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT_INT;

  List<DisplayRecord> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig;
  List<String> _values;
  bool _isLoading;

  _initialConnectOnDemand() async {
    var alreadyConnected = false;
    if (initialState == BluetoothDeviceState.disconnected ||
        initialState == BluetoothDeviceState.disconnecting) {
      try {
        await device.connect();
      } catch (e) {
        if (e.code != 'already_connected') {
          throw e;
        } else {
          alreadyConnected = true;
        }
      }
    }
    if (initialState == BluetoothDeviceState.connected && !_discovering || alreadyConnected) {
      try {
        _discoverServices();
      } on PlatformException catch (e, stack) {
        debugPrint("${e.message}");
        debugPrintStack(stackTrace: stack, label: "trace:");
        try {
          await device.connect();
        } catch (e) {
          if (e.code != 'already_connected') {
            throw e;
          }
        }
      }
    }
  }

  _addGraphData(Record record) {
    if (_simplerUi) {
      return;
    }

    _graphData.add(record.hydrate().display());
    if (_pointCount > 0 && _graphData.length > _pointCount) {
      _graphData.removeFirst();
    }
  }

  _fillValues(Record record) {
    _values = [
      record.calories.toString(),
      record.power.toString(),
      record.speedStringByUnit(_si, _descriptor.sport),
      record.cadence.toString(),
      record.heartRate.toString(),
      record.distanceStringByUnit(_si),
    ];
  }

  _recordMeasurement(List<int> data) async {
    if (!_descriptor.canPrimaryMeasurementProcessed(data)) return;

    _connectionWatchdog?.cancel();
    if (_connectionWatchdogTime > 0) {
      _connectionWatchdog =
          Timer(Duration(seconds: _connectionWatchdogTime), _reconnectionWorkaround);
    }

    Duration currentIdle = Duration();
    if (_paused) {
      currentIdle = DateTime.now().difference(_pauseStarted);
    }

    final latestRecord = _descriptor.processPrimaryMeasurement(
      _activity,
      _idleDuration + currentIdle,
      _latestRecord,
      data,
      _heartRateMonitor,
    );

    if (!_paused && _measuring) {
      if (latestRecord.elapsed != _latestRecord?.elapsed) {
        await _database?.recordDao?.insertRecord(latestRecord);
      }
      _addGraphData(latestRecord);
    }

    setState(() {
      _latestRecord = latestRecord;
      _fillValues(_latestRecord);

      if (_measuring) {
        if ((_latestRecord?.speed ?? 0.0) <= EPS) {
          _pauseStarted = DateTime.now();
          _paused = true;
        } else {
          _paused = false;
          _idleDuration += currentIdle;
        }
      }
    });
  }

  _processCadenceMeasurement(List<int> data) {
    if (!_descriptor.canCadenceMeasurementProcessed(data)) return;

    // _latestRecord?.cadence = _descriptor.processCadenceMeasurement(data);
  }

  _discoverServices() async {
    if (_discovering) {
      return;
    }
    device.discoverServices().then((services) async {
      if (_primaryMeasurements != null) {
        return services;
      }

      setState(() {
        _discovering = true;
      });
      final deviceInfo = BluetoothDeviceEx.filterService(services, DEVICE_INFORMATION_ID);
      final nameCharacteristic =
          BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, MANUFACTURER_NAME_ID);
      var nameString;
      try {
        final nameBytes = await nameCharacteristic.read();
        nameString = String.fromCharCodes(nameBytes);
      } on PlatformException catch (e, stack) {
        debugPrint("${e.message}");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }

      if (nameString == null) {
        setState(() {
          _discovering = false;
        });
        return services;
      }

      if (nameString == _descriptor.manufacturer) {
        if (_descriptor.cadenceServiceId != null) {
          final cadenceMeasurementService =
              BluetoothDeviceEx.filterService(services, _descriptor.cadenceServiceId);
          _cadenceMeasurements = BluetoothDeviceEx.filterCharacteristic(
              cadenceMeasurementService?.characteristics, _descriptor.cadenceMeasurementId);
          if (_cadenceMeasurements != null) {
            await _cadenceMeasurements.setNotifyValue(true);
            _cadenceSubscription = _cadenceMeasurements.value.listen((data) async {
              if (data?.length ?? 0 > 1) {
                await _processCadenceMeasurement(data);
              }
            });
          }
        }
        final measurementService =
            BluetoothDeviceEx.filterService(services, _descriptor.primaryServiceId);
        _primaryMeasurements = BluetoothDeviceEx.filterCharacteristic(
            measurementService?.characteristics, _descriptor.primaryMeasurementId);
        if (_primaryMeasurements != null) {
          await _primaryMeasurements.setNotifyValue(true);
          _measurementSubscription = _primaryMeasurements.value.listen((data) async {
            if ((data?.length ?? 0) > 1) {
              await _recordMeasurement(data);
            }
          });
          _measuring = true;
          _paused = false;

          await _addActivity();
        }
      } else {
        Get.defaultDialog(
          middleText: 'The device does not look like a ${_descriptor.fullName}. ' +
              'Measurement is not started',
          confirm: TextButton(
            child: Text("Ok"),
            onPressed: () => Get.close(1),
          ),
        );
      }
      setState(() {
        _discovering = false;
      });
      return services;
    });
  }

  _openDatabase() async {
    _database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3]).build();
  }

  _onToggleDetails(int index) {
    setState(() {
      _expandedState[index] = _rowControllers[index].expanded;
      final expandedStateStr =
          List<String>.generate(_expandedState.length, (index) => _expandedState[index] ? "1" : "0")
              .join("");
      PrefService.setString(MEASUREMENT_PANELS_EXPANDED_TAG, expandedStateStr);
    });
  }

  _onTogglePower() {
    _onToggleDetails(0);
  }

  _onToggleSpeed() {
    _onToggleDetails(1);
  }

  _onToggleRpm() {
    _onToggleDetails(2);
  }

  _onToggleHr() {
    _onToggleDetails(3);
  }

  _onToggleDistance() {
    _onToggleDetails(4);
  }

  _onLongPress(int index) {
    setState(() {
      _expandedHeights[index] = (_expandedHeights[index] + 1) % 3;
      final expandedHeightStr = List<String>.generate(
          _expandedHeights.length, (index) => _expandedHeights[index].toString()).join("");
      PrefService.setString(MEASUREMENT_DETAIL_SIZE_TAG, expandedHeightStr);
    });
  }

  RecordWithSport _blankRecord() {
    return RecordWithSport(
      timeStamp: 0,
      distance: _uxDebug ? _random.nextInt(100000).toDouble() : 0.0,
      elapsed: 0,
      calories: 0,
      power: 0,
      speed: 0.0,
      cadence: 0,
      heartRate: 0,
      elapsedMillis: 0,
      sport: _descriptor.sport,
    );
  }

  @override
  initState() {
    super.initState();
    _isLoading = true;
    _discovering = false;
    _pointCount = size.width ~/ 2;
    _unitStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      color: Colors.indigo,
    );
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    PrefService.setString(LAST_EQUIPMENT_ID_TAG, device.id.id);
    _descriptor.setPowerThrottle(
      PrefService.getString(THROTTLE_POWER_TAG),
      PrefService.getBool(THROTTLE_OTHER_TAG),
    );
    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: TRACK_PAINTING_RADIUS_BOOST,
        lengthFactor: _descriptor.lengthFactor,
      ),
    );
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _simplerUi = PrefService.getBool(SIMPLER_UI_TAG);
    _instantUpload = PrefService.getBool(INSTANT_UPLOAD_TAG);
    if (!_simplerUi) {
      _graphData = ListQueue<DisplayRecord>(_pointCount);
    }
    final connectionWatchdogTimeString =
        PrefService.getString(EQUIPMENT_DISCONNECTION_WATCHDOG_TAG);
    _connectionWatchdogTime = int.tryParse(connectionWatchdogTimeString);
    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, _descriptor);
    _preferencesSpecs.forEach((prefSpec) => prefSpec.calculateBounds(
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
      RowConfiguration(icon: Icons.whatshot, unit: 'cal', expandable: false),
      RowConfiguration(icon: _preferencesSpecs[0].icon, unit: _preferencesSpecs[0].unit),
      RowConfiguration(icon: _preferencesSpecs[1].icon, unit: _preferencesSpecs[1].unit),
      RowConfiguration(icon: _preferencesSpecs[2].icon, unit: _preferencesSpecs[2].unit),
      RowConfiguration(icon: _preferencesSpecs[3].icon, unit: _preferencesSpecs[3].unit),
      RowConfiguration(icon: Icons.add_road, unit: _si ? 'm' : 'mi'),
    ];
    _rowControllers = [];
    _expandedHeights = [];
    final expandedStateStr = PrefService.getString(MEASUREMENT_PANELS_EXPANDED_TAG);
    final expandedHeightStr = PrefService.getString(MEASUREMENT_DETAIL_SIZE_TAG);
    _expandedState = List<bool>.generate(expandedStateStr.length, (int index) {
      final expanded = expandedStateStr[index] == "1";
      ExpandableController rowController = ExpandableController(initialExpanded: expanded);
      _rowControllers.add(rowController);
      switch (index) {
        case 0:
          rowController.addListener(_onTogglePower);
          break;
        case 1:
          rowController.addListener(_onToggleSpeed);
          break;
        case 2:
          rowController.addListener(_onToggleRpm);
          break;
        case 3:
          rowController.addListener(_onToggleHr);
          break;
        case 4:
        default:
          rowController.addListener(_onToggleDistance);
          break;
      }
      final expandedHeight = int.tryParse(expandedHeightStr[index]);
      _expandedHeights.add(expandedHeight);
      return expanded;
    });

    _uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG);
    _measuring = false;
    _paused = false;
    _idleDuration = Duration();
    _latestRecord = _blankRecord();
    _values = ["--", "--", "--", "--", "--", "--"];

    if (_uxDebug) {
      _simulateMeasurements();
    } else {
      _heartRateMonitor?.attach()?.then((_) {
        _heartRateSubscription = _heartRateMonitor?.listenForYourHeart?.listen((heartRate) async {
          setState(() {
            _values[4] = heartRate?.toString() ?? "--";
          });
        });
      });
      _initialConnectOnDemand();
      _openDatabase();
    }

    _isLoading = false;
    Wakelock.enable();
  }

  _preDispose() async {
    await _heartRateSubscription?.cancel();
    await _heartRateMonitor?.detach();
    _connectionWatchdog?.cancel();
    _timer?.cancel();
    await _measurementSubscription?.cancel();
    await _primaryMeasurements?.setNotifyValue(false);
    await _cadenceSubscription?.cancel();
    await _cadenceMeasurements?.setNotifyValue(false);
    await _database?.close();
  }

  @override
  dispose() {
    Wakelock.disable();
    super.dispose();
  }

  Future<void> _addActivity() async {
    final now = DateTime.now();
    _activity = Activity(
      fourCC: _descriptor.fourCC,
      deviceName: device.name,
      deviceId: device.id.id,
      start: now.millisecondsSinceEpoch,
      startDateTime: now,
    );
    final id = await _database?.activityDao?.insertActivity(_activity);
    _activity.id = id;
  }

  Future<void> _restartWorkout() async {
    _connectionWatchdog?.cancel();
    _descriptor.restartWorkout();
    _latestRecord = _blankRecord();
    if (!_uxDebug) {
      await _database?.recordDao?.deleteAllActivityRecords(_activity.id);
      await _addActivity();
    }
  }

  Future<void> _reconnectionWorkaround() async {
    Get.snackbar("Warning", "Equipment might be disconnected. Auto-starting new workout:");
    _measuring = false;
    await _measurementSubscription?.cancel();
    await _primaryMeasurements?.setNotifyValue(false);
    await _cadenceSubscription?.cancel();
    await _cadenceMeasurements?.setNotifyValue(false);
    _primaryMeasurements = null;
    _measurementSubscription = null;
    _cadenceMeasurements = null;
    _cadenceSubscription = null;
    Get.snackbar("Warning", "1. Disconnecting...");
    await device.disconnect();
    _discovering = false;
    Get.snackbar("Warning", "2. Reconnecting...");
    await device.connect();
    Get.snackbar("Warning", "3. Restarting...");
    await _initialConnectOnDemand();
  }

  void _simulateMeasurements() {
    setState(() {
      final rightNow = DateTime.now();
      final newElapsed = _latestRecord.elapsed + 1;
      _latestRecord = RecordWithSport(
        timeStamp: rightNow.millisecondsSinceEpoch,
        distance: _latestRecord.distance + _random.nextInt(10),
        elapsed: newElapsed,
        calories: _random.nextInt(1500),
        power: 50 + _random.nextInt(500),
        speed: 15.0 + _random.nextDouble() * 15.0,
        cadence: 30 + _random.nextInt(100),
        heartRate: 60 + _random.nextInt(120),
        elapsedMillis: newElapsed,
        sport: _descriptor.sport,
      );
      _fillValues(_latestRecord);
      _addGraphData(_latestRecord);

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: rightNow.millisecond),
        _simulateMeasurements,
      );
    });
  }

  _stravaUpload(bool onlyWhenAuthenticated) async {
    StravaService stravaService;
    if (!Get.isRegistered<StravaService>()) {
      stravaService = Get.put<StravaService>(StravaService());
    } else {
      stravaService = Get.find<StravaService>();
    }

    if (onlyWhenAuthenticated && !await stravaService.hasValidToken()) {
      return;
    }

    if (!await DataConnectionChecker().hasConnection) {
      Get.snackbar("Warning", "No data connection detected");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final success = await stravaService.login();
    if (!success) {
      Get.snackbar("Warning", "Strava login unsuccessful");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final records = await _database.recordDao.findAllActivityRecords(_activity.id);
    final statusCode = await stravaService.upload(_activity, records);
    Get.snackbar(
        "Upload",
        statusCode == statusOk || statusCode >= 200 && statusCode < 300
            ? "Activity ${_activity.id} submitted successfully"
            : "Activity ${_activity.id} upload failure");
    setState(() {
      _isLoading = false;
    });
  }

  _finishActivity(bool quick) async {
    if (!_measuring) return;

    Duration currentIdle = Duration();
    if (_paused && _pauseStarted != null) {
      currentIdle = DateTime.now().difference(_pauseStarted);
    }

    setState(() {
      _measuring = false;
      _paused = true;
    });

    // Add one last record for the time of stopping
    _latestRecord = _descriptor.processPrimaryMeasurement(
      _activity,
      _idleDuration + currentIdle,
      _latestRecord,
      null,
      _heartRateMonitor,
    );

    await _database?.recordDao?.insertRecord(_latestRecord);

    _activity.finish(
      _latestRecord.distance,
      _latestRecord.elapsed,
      _latestRecord.calories,
    );
    final retVal = await _database?.activityDao?.updateActivity(_activity);
    if (retVal <= 0 && !quick) {
      Get.snackbar("Warning", "Could not save activity");
      return;
    }

    if (_instantUpload && !quick) {
      await _stravaUpload(true);
    }
  }

  List<charts.Series<DisplayRecord, DateTime>> _powerChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'power',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[0].fgColorByValue(record.power),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.power,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _speedChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'speed',
        colorFn: (DisplayRecord record, __) =>
            _preferencesSpecs[1].fgColorByValue(record.speedByUnit(_si, _descriptor.sport)),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.speedByUnit(_si, _descriptor.sport),
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _cadenceChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'cadence',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[2].fgColorByValue(record.cadence),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.cadence,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _hRChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'hr',
        colorFn: (DisplayRecord record, __) =>
            _preferencesSpecs[3].fgColorByValue(record.heartRate),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.heartRate,
        data: graphData,
      ),
    ];
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('About to navigate away'),
            content: Text("If there is a workout in progress it'll be finished. Are you sure?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.close(1),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await _finishActivity(true);
                  await _preDispose();
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final separatorHeight = 1.0;

    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = Get.mediaQuery.size.width / 8;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _unitStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault / 2,
        color: Colors.indigo,
      );
    }

    final _timeDisplay = Duration(seconds: _latestRecord.elapsed).toDisplay();

    List<Widget> rows = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: _sizeDefault, color: Colors.indigo),
          Text(_timeDisplay, style: _measurementStyle),
          SizedBox(width: _sizeDefault / 4),
        ],
      ),
    ];

    _rowConfig.asMap().entries.forEach((entry) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _rowConfig[entry.key].icon,
            size: _sizeDefault,
            color: Colors.indigo,
          ),
          Spacer(),
          Text(_values[entry.key], style: _measurementStyle),
          SizedBox(
            width: _sizeDefault * (entry.value.expandable ? 1.3 : 2),
            child: Text(
              _rowConfig[entry.key].unit,
              maxLines: 2,
              style: _unitStyle,
            ),
          ),
        ],
      ));
    });

    var extras = [];
    if (!_simplerUi) {
      _preferencesSpecs.asMap().entries.forEach((entry) {
        List<common.AnnotationSegment> annotationSegments = [];
        if (!_isLoading) {
          annotationSegments.addAll(List.generate(
            entry.value.binCount,
            (i) => charts.RangeAnnotationSegment(
              entry.value.zoneLower[i],
              entry.value.zoneUpper[i],
              charts.RangeAnnotationAxisType.measure,
              color: entry.value.bgColorByBin(i),
              startLabel: entry.value.zoneLower[i].toString(),
              labelAnchor: charts.AnnotationLabelAnchor.start,
            ),
          ));
          annotationSegments.addAll(List.generate(
            entry.value.binCount,
            (i) => charts.LineAnnotationSegment(
              entry.value.zoneUpper[i],
              charts.RangeAnnotationAxisType.measure,
              startLabel: entry.value.zoneUpper[i].toString(),
              labelAnchor: charts.AnnotationLabelAnchor.end,
              strokeWidthPx: 1.0,
              color: charts.MaterialPalette.black,
            ),
          ));
        }

        var height = 0.0;
        switch (_expandedHeights[entry.key]) {
          case 0:
            height = size.height / 4;
            break;
          case 1:
            height = size.height / 3;
            break;
          case 2:
            height = size.height / 2;
            break;
        }
        extras.add(
          GestureDetector(
            onLongPress: () => _onLongPress(entry.key),
            child: SizedBox(
              width: size.width,
              height: height,
              child: charts.TimeSeriesChart(
                _metricToDataFn[entry.value.metric](),
                animate: false,
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.NoneRenderSpec(),
                ),
                behaviors: [
                  charts.RangeAnnotation(annotationSegments),
                ],
              ),
            ),
          ),
        );
      });

      final trackMarker = _trackCalculator.trackMarker(_latestRecord.distance);
      extras.add(
        CustomPaint(
          painter: TrackPainter(calculator: _trackCalculator),
          child: SizedBox(
            width: size.width,
            height: size.width / 1.9,
            child: trackMarker == null
                ? null
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
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: TextOneLine(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: initialState,
              builder: (c, snapshot) {
                VoidCallback onPressed;
                IconData icon;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () {
                      device.disconnect();
                    };
                    icon = Icons.bluetooth_connected;
                    _discoverServices();
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () async {
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      }
                    };
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
                onPressed: () async {
                  if (_measuring) {
                    await _finishActivity(false);
                  } else {
                    final deviceState = await device.state.last;
                    var alreadyConnected = false;
                    if (deviceState == BluetoothDeviceState.disconnected) {
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        } else {
                          alreadyConnected = true;
                        }
                      }
                    }
                    if (deviceState != BluetoothDeviceState.disconnected || alreadyConnected) {
                      _discoverServices();
                    }
                  }
                }),
          ],
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                rows[0],
                Divider(height: separatorHeight),
                rows[1],
                Divider(height: separatorHeight),
                ExpandablePanel(
                  header: rows[2],
                  expanded: _simplerUi ? null : extras[0],
                  controller: _rowControllers[0],
                ),
                Divider(height: separatorHeight),
                ExpandablePanel(
                  header: rows[3],
                  expanded: _simplerUi ? null : extras[1],
                  controller: _rowControllers[1],
                ),
                Divider(height: separatorHeight),
                ExpandablePanel(
                  header: rows[4],
                  expanded: _simplerUi ? null : extras[2],
                  controller: _rowControllers[2],
                ),
                Divider(height: separatorHeight),
                ExpandablePanel(
                  header: rows[5],
                  expanded: _simplerUi ? null : extras[3],
                  controller: _rowControllers[3],
                ),
                Divider(height: separatorHeight),
                ExpandablePanel(
                  header: rows[6],
                  expanded: _simplerUi ? null : extras[4],
                  controller: _rowControllers[4],
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FabCircularMenu(
          fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
          fabCloseIcon: const Icon(Icons.close, color: Colors.white),
          children: [
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(BrandIcons.strava),
              onPressed: () async {
                if (_measuring) {
                  Get.snackbar("Warning", "Cannot upload while measurement is under progress");
                  return;
                }

                await _stravaUpload(false);
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.list_alt),
              onPressed: () async {
                if (_measuring) {
                  Get.snackbar("Warning", "Cannot navigate while measurement is under progress");
                } else {
                  await Get.to(ActivitiesScreen());
                }
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.wifi_protected_setup),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('About to restart the workout'),
                    content: Text('This will start a new workout! Are you sure?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Get.close(1),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _restartWorkout();
                          Get.close(1);
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.settings),
              onPressed: () async {
                await Get.bottomSheet(
                  SpinDownBottomSheet(device: device, descriptor: _descriptor),
                  isDismissible: false,
                  enableDrag: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
