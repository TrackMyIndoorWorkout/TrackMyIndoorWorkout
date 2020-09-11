import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../services/db.dart';
import '../devices/device_descriptor.dart';
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';

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
  // List<BluetoothService> _services;
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
  double _cadence; // snapshot (rpm)
  double _cadenceSum;
  int _cadenceCount;
  double _heartRate; // snapshot (bpm)
  double _hrSum;
  int _hrCount;
  double _distance; // cumulative (m)

  static const double ms2kmh = 3.6;
  DateTime _lastRecord;
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
      await dB.addRecord(_distance + dD, _time.toInt(), _calories.toInt(),
          _power.toInt(), _speed, _cadence.toInt(), _heartRate.toInt());
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

        if (_areListsEqual(name, descriptor.nameStart) &&
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
            final db = Db();
            Get.put<Db>(db);
            await db.open();
            await db.startActivity(device.name);
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

  double _calculate(distance, horizontal) {
    final rX = (size.width - 2 * THICK) / (2 * RADIUS_BOOST);
    final rY =
        (size.height - 2 * THICK) / (2 * RADIUS_BOOST + pi * LANE_SHRINK);
    final r = min(rY, rX) * RADIUS_BOOST;
    final offset = Offset(
        rX > rY ? (size.width - 2 * (THICK + r)) / 2 : 0,
        rX < rY
            ? (size.height - 2 * THICK - r * 2 - pi * rX * LANE_SHRINK) / 2
            : 0);

    final d = distance % TRACK_LENGTH;
    final straight = TRACK_LENGTH / 4 * LANE_SHRINK;
    final halfCircle = TRACK_LENGTH / 4 * RADIUS_BOOST;
    if (d <= straight) {
      // left straight
      if (horizontal) return THICK + offset.dx;
      final displacement =
          (1 - d / straight) * pi * LANE_SHRINK / RADIUS_BOOST * r;
      return r + THICK + offset.dy + displacement;
    } else if (d <= TRACK_LENGTH / 2) {
      // top half circle
      final rad = (1 - (d - straight) / halfCircle) * pi;
      if (horizontal) return (cos(rad) + 1) * r + THICK + offset.dx;
      return (1 - sin(rad)) * r + THICK + offset.dy;
    } else if (d <= TRACK_LENGTH / 2 + straight) {
      // right straight
      if (horizontal) return 2 * r + THICK + offset.dx;
      final displacement = (d - TRACK_LENGTH / 2) /
          straight *
          pi *
          LANE_SHRINK /
          RADIUS_BOOST *
          r;
      return r + THICK + offset.dy + displacement;
    } else {
      // bottom half circle
      final rad = (2 + (d - TRACK_LENGTH / 2 - straight) / halfCircle) * pi;
      if (horizontal) return (cos(rad) + 1) * r + THICK + offset.dx;
      return size.height - THICK - offset.dy - r * (1 - sin(rad));
    }
  }

  _finishActivity() async {
    if (!_measuring) return;

    setState(() {
      _measuring = false;
      _paused = true;
    });

    final dB = Get.find<Db>();
    await dB.endActivity(
        _distance,
        _time.toInt(),
        _calories.toInt(),
        _powerSum / _powerCount,
        _speedSum / _speedCount,
        _cadenceSum / _cadenceCount,
        _hrSum / _hrCount);
  }

  @override
  Widget build(BuildContext context) {
    var _timeDisplay =
        Duration(seconds: _time.toInt()).toString().split('.')[0];
    if (_timeDisplay.length == 7) {
      _timeDisplay = '0$_timeDisplay';
    }
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
              onPressed: () async => await _finishActivity())
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
            top: _calculate(_distance, false) - THICK,
            left: _calculate(_distance, true) - THICK,
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
