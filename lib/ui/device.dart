import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  static Size size;
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

  static Size size = Size(0, 0);
  static double radius = 0;

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
      await _database.recordDao.insertRecord(record);
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
            final id = await _database.activityDao.insertActivity(_activity);
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
    initializeDateFormatting();
    _discovered = false;
    _measuring = false;
    _paused = false;
    _time = 0;
    _calories = 0;
    _power = 0;
    _speed = 0;
    _cadence = 0;
    _heartRate = 0;
    _distance = 0;

    _initialConnectOnDemand();
    _openDatabase();

    Wakelock.enable();
  }

  @override
  dispose() {
    if (_measurements != null) {
      _measurements.setNotifyValue(false);
    }
    _database.close();
    Wakelock.disable();
    super.dispose();
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

    await _database.recordDao.insertRecord(record);

    _activity.finish(
      _distance,
      _time,
      _calories.toInt(),
    );
    final changed = await _database.activityDao.updateActivity(_activity);
  }

  @override
  Widget build(BuildContext context) {
    final double sizeDefault = radius > 0 ? radius / 3.0 : 64.0;

    final timeStyle = TextStyle(
      fontSize: sizeDefault,
      fontFeatures: [FontFeature.tabularFigures()],
      color: Colors.indigo,
    );
    final measurementStyle =
        TextStyle(fontSize: sizeDefault, color: Colors.indigo);
    final unitStyle = TextStyle(fontSize: sizeDefault / 2.5);
    final oneFractions = NumberFormat()
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
    final zeroFractions = NumberFormat()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 0;

    var _timeDisplay = Duration(seconds: _time).toString().split('.')[0];
    if (_timeDisplay.length == 7) {
      _timeDisplay = '0$_timeDisplay';
    }
    final trackMarker = calculateTrackMarker(size, _distance);

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
      body: CustomPaint(
        painter: TrackPainter(),
        child: Stack(children: <Widget>[
          radius <= 0
              ? Text("Waiting for data...", style: measurementStyle)
              : Center(
                  child: SizedBox(
                    width: size.width - 4 * THICK,
                    height: size.height - 2 * THICK,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(child: Icon(Icons.timer, size: sizeDefault)),
                            Spacer(),
                            Text(_timeDisplay, style: timeStyle),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.whatshot, size: sizeDefault),
                            Spacer(),
                            Text('${zeroFractions.format(_calories)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('kCal', style: unitStyle)),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt, size: sizeDefault),
                            Spacer(),
                            Text('${zeroFractions.format(_power)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('W', style: unitStyle)),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.speed, size: sizeDefault),
                            Spacer(),
                            Text('${oneFractions.format(_speed)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('km/h', style: unitStyle)),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bike, size: sizeDefault),
                            Spacer(),
                            Text('${zeroFractions.format(_cadence)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('rpm', style: unitStyle)),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, size: sizeDefault),
                            Spacer(),
                            Text('${zeroFractions.format(_heartRate)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('bpm', style: unitStyle)),
                          ],
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add_road, size: sizeDefault),
                            Spacer(),
                            Text('${zeroFractions.format(_distance)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('m', style: unitStyle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
          )
        ]),
      ),
    );
  }
}
