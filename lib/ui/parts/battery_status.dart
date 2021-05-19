import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../devices/gatt_constants.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';

class BatteryStatusBottomSheet extends StatefulWidget {
  @override
  _BatteryStatusBottomSheetState createState() => _BatteryStatusBottomSheetState();
}

enum CalibrationState {
  PreInit,
  Initializing,
  ReadyToWeighIn,
  WeightSubmitting,
  WeighInProblem,
  WeighInSuccess,
  ReadyToCalibrate,
  CalibrationStarting,
  CalibrationInProgress,
  CalibrationSuccess,
  CalibrationFail,
  NotSupported,
}

class _BatteryStatusBottomSheetState extends State<BatteryStatusBottomSheet> {
  FitnessEquipment _fitnessEquipment;
  HeartRateMonitor _heartRateMonitor;
  String _hrmBatteryLevel;
  String _batteryLevel;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  Future<String> _readBatteryLevelCore(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, BATTERY_SERVICE_ID);
    if (batteryService == null) {
      return NOT_AVAILABLE;
    }

    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, BATTERY_LEVEL_ID);
    if (batteryLevel == null) {
      return NOT_AVAILABLE;
    }

    final batteryLevelData = await batteryLevel.read();
    return "${batteryLevelData[0]}%";
  }

  Future<String> _readBatteryLevel(DeviceBase device) async {
    if (device?.device == null) return NOT_AVAILABLE;

    if (!device.connected) {
      await device.connect();
    }

    if (!device.connected) return NOT_AVAILABLE;

    if (!device.discovered) {
      await device.discover();
    }

    if (!device.discovered) return NOT_AVAILABLE;

    return await _readBatteryLevelCore(device.services);
  }

  Future<void> _readBatteryLevels() async {
    var batteryLevel = await _readBatteryLevel(_fitnessEquipment);
    setState(() {
      _batteryLevel = batteryLevel;
    });
    batteryLevel = await _readBatteryLevel(_heartRateMonitor);
    setState(() {
      _hrmBatteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    _hrmBatteryLevel = NOT_AVAILABLE;
    _batteryLevel = NOT_AVAILABLE;
    _readBatteryLevels();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 5;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
        color: Get.textTheme.bodyText1.color,
      );
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(getIcon(_fitnessEquipment.sport), color: Colors.indigo, size: _sizeDefault),
              Icon(Icons.battery_full, color: Colors.indigo, size: _sizeDefault),
              Text(_batteryLevel, style: _textStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.indigo, size: _sizeDefault),
              Icon(Icons.battery_full, color: Colors.indigo, size: _sizeDefault),
              Text(_hrmBatteryLevel, style: _textStyle),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.close(1),
      ),
    );
  }
}
