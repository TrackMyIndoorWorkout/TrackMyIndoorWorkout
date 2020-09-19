import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../devices/device_descriptor.dart';
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';
import '../persistence/activity.dart';
import '../persistence/db.dart';
import '../persistence/record.dart';
import '../strava/strava_service.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/utils.dart';
import 'activities.dart';

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
  int _time; // cumulative elapsed (auto pause)
  double _calories; // cumulative (kCal)
  int _power; // snapshot (W)
  int _powerSum;
  int _powerCount;
  double _speed; // snapshot (km/h)
  double _speedSum;
  int _speedCount;
  double _maxSpeed;
  int _cadence; // snapshot (rpm)
  int _cadenceSum;
  int _cadenceCount;
  int _heartRate; // snapshot (bpm)
  int _hrSum;
  int _hrCount;
  double _distance; // cumulative (m)

  DateTime _lastRecord;
  Activity _activity;

  static const double ms2kmh = 3.6;
  static Size size = Size(0, 0);
  static double radius = 0;

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
    _time = descriptor.getTime(data).toInt();
    _calories = descriptor.getCalories(data);
    _power = descriptor.getPower(data).toInt();
    _speed = descriptor.getSpeed(data);
    _cadence = descriptor.getCadence(data).toInt();
    _heartRate = descriptor.getHeartRate(data).toInt();
    if (_speed > 0 || !_paused) {
      final dB = Get.find<Db>();
      final gps = calculateGPS(_distance + dD);
      await dB.addRecord(Record(
          distance: _distance + dD,
          elapsed: _time,
          calories: _calories.toInt(),
          power: _power,
          speed: _speed,
          cadence: _cadence,
          heartRate: _heartRate,
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
            _lastRecord = DateTime.now();
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
    _maxSpeed = 0;
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
      _time,
      _calories.toInt(),
      _powerSum.toDouble() / _powerCount,
      _speedSum / _speedCount,
      _cadenceSum.toDouble() / _cadenceCount,
      _hrSum.toDouble() / _hrCount,
      _maxSpeed,
    );
    await dB.updateActivity(_activity);
  }

  @override
  Widget build(BuildContext context) {
    final double sizeDefault = radius > 0 ? radius / 6.0 : 64.0;

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
                    width: size.width - 2 * THICK,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add_road, size: sizeDefault),
                            Spacer(),
                            Text('${oneFractions.format(_distance / 1000.0)}',
                                style: measurementStyle),
                            SizedBox(
                                width: sizeDefault,
                                child: Text('km', style: unitStyle)),
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
