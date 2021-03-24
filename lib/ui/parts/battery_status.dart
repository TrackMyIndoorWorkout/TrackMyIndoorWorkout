import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/device_base.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../devices/gatt_constants.dart';
import '../../persistence/preferences.dart';

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
  double _sizeDefault;
  TextStyle _textStyle;

  Future<String> _readBatteryLevelCore(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, BATTERY_SERVICE_ID);
    if (batteryService == null) {
      return "N/A";
    }
    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, BATTERY_LEVEL_ID);
    if (batteryLevel == null) {
      return "N/A";
    }
    final batteryLevelData = await batteryLevel.read();
    return "${batteryLevelData[0]}%";
  }

  Future<String> _readBatteryLevel(DeviceBase device) async {
    if (device?.device == null) return "N/A";

    if (!device.connected) {
      await device.connect();
    }

    if (!device.connected) return "N/A";

    if (!device.discovered) {
      await device.discover();
    }

    if (!device.discovered) return "N/A";

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
    _hrmBatteryLevel = "N/A";
    _batteryLevel = "N/A";
    _sizeDefault = Get.mediaQuery.size.width / 5;
    _textStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      fontSize: _sizeDefault,
      color: Get.textTheme.bodyText1.color,
    );
    _readBatteryLevels();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_fitnessEquipment.descriptor.getIcon(),
                  color: Colors.indigo, size: _sizeDefault),
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
