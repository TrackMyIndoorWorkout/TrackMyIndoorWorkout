import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/device_descriptor.dart';
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../strava/strava_service.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/utils.dart';
import 'activities.dart';

const UX_DEBUG = true;

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothDeviceState initialState;
  DeviceScreen({Key key, this.device, this.initialState}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeviceState(device: device, initialState: initialState);
  }
}

class DeviceState extends State<DeviceScreen> {
  DeviceState({this.device, this.initialState});

  // Track drawing cached computed values
  static Size trackSize;
  static Paint trackStroke;
  static Path trackPath;

  final BluetoothDevice device;
  final BluetoothDeviceState initialState;
  final DeviceDescriptor descriptor = devices[0];
  BluetoothCharacteristic _measurements;
  bool _discovered;
  bool _measuring;
  bool _paused;
  int _time; // cumulative elapsed (auto pause)
  int _calories; // cumulative (kCal)
  int _power; // snapshot (W)
  double _speed; // snapshot (km/h)
  int _cadence; // snapshot (rpm)
  int _heartRate; // snapshot (bpm)
  double _distance; // cumulative (m)

  DateTime _lastRecord;
  Activity _activity;
  AppDatabase _database;

  // Debugging UX without actual connected device
  Timer _timer;
  var _rightNow = DateTime.now();
  final _random = Random();

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

  _recordMeasurement(List<int> data) async {
    if (!descriptor.canMeasurementProcessed(data)) return;

    final rightNow = DateTime.now();
    final record = descriptor.getMeasurement(
        _activity.id, rightNow, _lastRecord, _speed, _distance, data, null);

    if (!_paused && _measuring) {
      await _database?.recordDao?.insertRecord(record);
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

      if (_measuring) {
        if (_speed <= 0) {
          _paused = true;
        } else {
          _paused = false;
        }
      }
      _lastRecord = rightNow;
    });
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

      final equipmentService =
          _filterService(services, descriptor.measurementServiceId);
      if (equipmentService != null) {
        final equipmentTypeChar = _filterCharacteristic(
            equipmentService.characteristics, descriptor.equipmentTypeId);

        var equipmentType;
        try {
          equipmentType = await equipmentTypeChar.read();
        } on PlatformException catch (e, stack) {
          debugPrint("${e.message}");
          debugPrintStack(stackTrace: stack, label: "trace:");
        }

        if (_areListsEqual(name, descriptor.manufacturer) &&
            _areListsEqual(equipmentType, BIKE_EQUIPMENT)) {
          _measurements = _filterCharacteristic(
              equipmentService.characteristics, descriptor.measurementId);
          if (_measurements != null) {
            await _measurements.setNotifyValue(true);
            _lastRecord = DateTime.now();
            _measurements.value.listen((data) async {
              await _recordMeasurement(data);
            });
            _measuring = true;
            _paused = false;

            _activity = Activity(
                deviceName: device.name,
                deviceId: device.id.id,
                start: _lastRecord.millisecondsSinceEpoch);
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
    _database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }

  @override
  initState() {
    super.initState();
    _discovered = false;
    _measuring = false;
    _paused = false;
    _time = 0;
    _calories = 0;
    _power = 0;
    _speed = 0;
    _cadence = 0;
    _heartRate = 0;
    _distance = UX_DEBUG ? _random.nextInt(100000).toDouble() : 0;

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
    _measurements?.setNotifyValue(false);
    _database?.close();
    Wakelock.disable();
    super.dispose();
  }

  void _simulateMeasurements() {
    setState(() {
      _rightNow = DateTime.now();
      _time++;
      _calories = _random.nextInt(1500);
      _power = 50 + _random.nextInt(500);
      _speed = 15.0 + _random.nextDouble() * 15.0;
      _cadence = 30 + _random.nextInt(100);
      _heartRate = 60 + _random.nextInt(120);
      _distance += _random.nextInt(10);

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _rightNow.millisecond),
        _simulateMeasurements,
      );
    });
  }

  _finishActivity() async {
    if (!_measuring) return;

    setState(() {
      _measuring = false;
      _paused = true;
    });

    // Add one last record for the time of stopping
    final rightNow = DateTime.now();
    final supplement = Record(
      distance: _distance,
      elapsed: _time,
      calories: _calories,
      power: _power,
      speed: _speed,
      cadence: _cadence,
      heartRate: _heartRate,
    );
    final record = descriptor.getMeasurement(_activity.id, rightNow,
        _lastRecord, _speed, _distance, null, supplement);

    await _database?.recordDao?.insertRecord(record);

    _activity.finish(
      _distance,
      _time,
      _calories.toInt(),
    );
    // final changed =
    await _database?.activityDao?.updateActivity(_activity);
  }

  @override
  Widget build(BuildContext context) {
    final double sizeDefault = Get.mediaQuery.size.width / 7;

    final measurementStyle = TextStyle(
      fontFamily: 'DSEG7',
      fontSize: sizeDefault,
    );
    final unitStyle = TextStyle(
      fontFamily: 'DSEG14',
      fontSize: sizeDefault / 3,
      color: Colors.indigo,
    );

    var _timeDisplay = Duration(seconds: _time).toString().split('.')[0];
    if (_timeDisplay.length == 7) {
      _timeDisplay = '0$_timeDisplay';
    }
    final trackMarker = calculateTrackMarker(trackSize, _distance);

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
                : Get.to(ActivitiesScreen()),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: sizeDefault, color: Colors.indigo),
              Text(_timeDisplay, style: measurementStyle),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.whatshot, size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_calories.toString(), style: measurementStyle),
              SizedBox(
                  width: sizeDefault, child: Text('k Cal', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.bolt, size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_power.toString(), style: measurementStyle),
              SizedBox(width: sizeDefault, child: Text('W', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.speed, size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_speed.toStringAsFixed(1), style: measurementStyle),
              SizedBox(
                  width: sizeDefault, child: Text('km/h', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.directions_bike,
                  size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_cadence.toString(), style: measurementStyle),
              SizedBox(
                  width: sizeDefault, child: Text('rpm', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_heartRate.toString(), style: measurementStyle),
              SizedBox(
                  width: sizeDefault, child: Text('bpm', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.add_road, size: sizeDefault, color: Colors.indigo),
              Spacer(),
              Text(_distance.toStringAsFixed(0), style: measurementStyle),
              SizedBox(width: sizeDefault, child: Text('m', style: unitStyle)),
            ],
          ),
          Divider(height: 1),
          Expanded(
            child: CustomPaint(
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
          ),
        ],
      ),
    );
  }
}
