import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../devices/device_descriptor.dart';
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';
import '../persistence/activity.dart';
import '../persistence/db.dart';
import '../persistence/record.dart';
import '../persistence/strava_service.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/utils.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  DeviceScreen({Key key, this.device}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeviceState(device: device);
  }
}

class DeviceState extends State<DeviceScreen> {
  DeviceState({this.device});

  final BluetoothDevice device;
  final DeviceDescriptor descriptor = devices[0];
  bool _discovered;
  bool _measuring;
  bool _paused;
  double _time; // cumulative elapsed (auto pause)
  double _calories; // cumulative (kCal)
  double _power; // snapshot (W)
  double _powerSum;
  int _powerCount;
  double _speed; // snapshot (km/h)
  double _speedSum;
  int _speedCount;
  double _maxSpeed;
  double _cadence; // snapshot (rpm)
  double _cadenceSum;
  int _cadenceCount;
  double _heartRate; // snapshot (bpm)
  double _hrSum;
  int _hrCount;
  double _distance; // cumulative (m)

  DateTime _lastRecord;
  Activity _activity;

  static const double ms2kmh = 3.6;
  static Size size = Size(0, 0);

  final style = TextStyle(
    fontSize: 64,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  _initialConnectOnDemand() async {
    BluetoothDeviceState state = await device.state.last;
    if (state == BluetoothDeviceState.disconnected) {
      await device.connect().then((value) async {
        await _discoverServices();
      });
    } else if (state == BluetoothDeviceState.connected && !_discovered) {
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
    if (data.length != descriptor.byteCount) return;
    for (int i = 0; i < descriptor.measurementPrefix.length; i++) {
      if (data[i] != descriptor.measurementPrefix[i]) return;
    }
    final rightNow = DateTime.now();
    double dD;
    if (_speed > 0) {
      Duration dT = rightNow.difference(_lastRecord);
      dD = _speed / ms2kmh * dT.inMilliseconds / 1000.0;
    }
    _time = descriptor.getTime(data);
    _calories = descriptor.getCalories(data);
    _power = descriptor.getPower(data);
    _speed = descriptor.getSpeed(data);
    _cadence = descriptor.getCadence(data);
    _heartRate = descriptor.getHeartRate(data);
    if (_speed > 0 || !_paused) {
      final dB = Get.find<Db>();
      final gps = calculateGPS(_distance + dD);
      await dB.addRecord(Record(
          distance: _distance + dD,
          elapsed: _time.toInt(),
          calories: _calories.toInt(),
          power: _power.toInt(),
          speed: _speed,
          cadence: _cadence.toInt(),
          heartRate: _heartRate.toInt(),
          lon: gps.dx,
          lat: gps.dy));
    }

    setState(() {
      if (_speed > 0) {
        _distance += dD;
      }

      if (_power > 0 && _measuring) {
        _powerSum += _power;
        _powerCount++;
      }
      if (_speed > 0 && _measuring) {
        _speedSum += _speed;
        _speedCount++;
        _maxSpeed = max(_speed, _maxSpeed);
      }
      if (_cadence > 0 && _measuring) {
        _cadenceSum += _cadence;
        _cadenceCount++;
      }
      if (_heartRate > 0 && _measuring) {
        _hrSum += _heartRate;
        _hrCount++;
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

  _discoverServices() async {
    await device.discoverServices().then((services) async {
      setState(() {
        _discovered = true;
      });
      final deviceInfo = services.firstWhere((service) =>
          service.uuid.toString().substring(4, 8).toLowerCase() ==
          deviceInformationId);
      final nameCharacteristic = deviceInfo.characteristics.firstWhere((ch) =>
          ch.uuid.toString().substring(4, 8).toLowerCase() ==
          manufacturerNameId);
      var name;
      try {
        name = await nameCharacteristic.read();
      } on PlatformException catch (e, stack) {
        debugPrint("${e.message}");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }

      final equipmentService = services.firstWhere(
          (service) =>
              service.uuid.toString().substring(4, 8).toLowerCase() ==
              descriptor.measurementServiceId,
          orElse: () => null);
      if (equipmentService != null) {
        final equipmentTypeChar = equipmentService.characteristics.firstWhere(
            (ch) =>
                ch.uuid.toString().substring(4, 8).toLowerCase() ==
                descriptor.equipmentTypeId,
            orElse: () => null);

        var equipmentType;
        try {
          equipmentType = await equipmentTypeChar.read();
        } on PlatformException catch (e, stack) {
          debugPrint("${e.message}");
          debugPrintStack(stackTrace: stack, label: "trace:");
        }

        if (_areListsEqual(name, descriptor.manufacturer) &&
            _areListsEqual(equipmentType, BIKE_EQUIPMENT)) {
          final measurements = equipmentService.characteristics.firstWhere(
              (ch) =>
                  ch.uuid.toString().substring(4, 8).toLowerCase() ==
                  descriptor.measurementId,
              orElse: () => null);
          if (measurements != null) {
            await measurements.setNotifyValue(true);
            measurements.value.listen((data) async {
              await _recordMeasurement(data);
            });
            _measuring = true;
            _paused = false;
            final db = Get.put<Db>(Db());
            await db.open();
            _activity =
                Activity(deviceName: device.name, deviceId: device.id.id);
            await db.addActivity(_activity);
          }
        }
      }
      if (!_measuring) {
        Get.defaultDialog(
            textConfirm: "OK",
            onConfirm: () => Get.close(1),
            middleText:
                'The device does not look like a ${descriptor.fullName}. ' +
                    'Measurement is not started');
      }
      return services;
    });
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
    _powerSum = 0;
    _powerCount = 0;
    _speed = 0;
    _speedSum = 0;
    _speedCount = 0;
    _cadence = 0;
    _cadenceSum = 0;
    _cadenceCount = 0;
    _heartRate = 0;
    _hrSum = 0;
    _hrCount = 0;
    _distance = 0;

    _initialConnectOnDemand();
  }

  @override
  dispose() {
    super.dispose();
  }

  _finishActivity() async {
    if (!_measuring) return;

    setState(() {
      _measuring = false;
      _paused = true;
    });

    final dB = Get.find<Db>();
    _activity.update(
      _distance,
      _time.toInt(),
      _calories.toInt(),
      _powerSum / _powerCount,
      _speedSum / _speedCount,
      _cadenceSum / _cadenceCount,
      _hrSum / _hrCount,
      _maxSpeed,
    );
    await dB.updateActivity(_activity);
  }

  @override
  Widget build(BuildContext context) {
    var _timeDisplay =
        Duration(seconds: _time.toInt()).toString().split('.')[0];
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
            onPressed: () async =>
                _measuring ? await _finishActivity() : _discoverServices(),
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
        ],
      ),
      body: CustomPaint(
        painter: TrackPainter(),
        child: Stack(children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: style.fontSize),
                  Text(_timeDisplay, style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.whatshot, size: style.fontSize),
                  Text('$_calories', style: style),
                  Text('kCal', style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: style.fontSize),
                  Text('$_power', style: style),
                  Text('W', style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.speed, size: style.fontSize),
                  Text('$_speed', style: style),
                  Text('km/h', style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bike, size: style.fontSize),
                  Text('$_cadence', style: style),
                  Text('rpm', style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: style.fontSize),
                  Text('$_heartRate', style: style),
                  Text('bpm', style: style),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add_road, size: style.fontSize),
                  Text('${_distance / 1000.0}', style: style),
                  Text('km', style: style),
                ],
              ),
            ],
          )),
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
