import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../devices/device_descriptor.dart';
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';

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
  double _time; // cumulative elapsed (auto pause)
  double _calories; // cumulative (kCal)
  double _power; // snapshot (W)
  double _speed; // snapshot (km/h)
  double _cadence; // snapshot (rpm)
  double _heartRate; // snapshot (bpm)
  double _distance; // cumulative (m)
  static const double ms2kmh = 3.6;
  DateTime _lastRecord;
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

  _recordMeasurement(List<int> data) {
    if (data.length != descriptor.byteCount) return;
    for (int i = 0; i < descriptor.measurementPrefix.length; i++) {
      if (data[i] != descriptor.measurementPrefix[i]) return;
    }
    setState(() {
      final rightNow = DateTime.now();
      if (_speed > 0) {
        Duration dT = rightNow.difference(_lastRecord);
        final dD = _speed / ms2kmh * dT.inMilliseconds / 1000.0;
        _distance += dD;
      }

      _time = descriptor.getTime(data);
      _calories = descriptor.getCalories(data);
      _power = descriptor.getPower(data);
      _speed = descriptor.getSpeed(data);
      _cadence = descriptor.getCadence(data);
      _heartRate = descriptor.getHeartRate(data);

      // TODO: record FIT
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
            measurements.value.listen((data) {
              _recordMeasurement(data);
            });
            _measuring = true;
          }
        }
      }
      if (!_measuring) {
        Get.defaultDialog(
            textConfirm: "OK",
            onConfirm: () => Get.close(1),
            middleText:
                '''The device does not look like a ${descriptor.fullName}.
                Measurement is not started''');
      }
      return services;
    });
  }

  @override
  initState() {
    super.initState();
    _discovered = false;
    _measuring = false;
    _time = 0;
    _calories = 0;
    _power = 0;
    _speed = 0;
    _cadence = 0;
    _heartRate = 0;
    _distance = 0;

    _initialConnectOnDemand();
  }

  @override
  dispose() {
    super.dispose();
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
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  text = 'CONNECTED';
                  if (!_discovered) {
                    _discoverServices();
                  }
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: Icon(snapshot.data == BluetoothDeviceState.connected
                    ? Icons.bluetooth_connected
                    : (snapshot.data == BluetoothDeviceState.disconnected
                        ? Icons.bluetooth_disabled
                        : Icons.bluetooth_searching)),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: style.fontSize),
                  Text(_timeDisplay, style: style),
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.whatshot, size: style.fontSize),
                Text('$_calories', style: style),
                Text('kCal', style: style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.bolt, size: style.fontSize),
                Text('$_power', style: style),
                Text('W', style: style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.speed, size: style.fontSize),
                Text('$_speed', style: style),
                Text('km/h', style: style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.directions_bike, size: style.fontSize),
                Text('$_cadence', style: style),
                Text('rpm', style: style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: style.fontSize),
                Text('$_heartRate', style: style),
                Text('bpm', style: style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add_road, size: style.fontSize),
                Text('${_distance / 1000.0}', style: style),
                Text('km', style: style),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
