import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../devices/gatt_constants.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

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
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  String _hrmBatteryLevel = NOT_AVAILABLE;
  String _batteryLevel = NOT_AVAILABLE;
  String _readFeatures = "Features: $NOT_AVAILABLE";
  String _writeFeatures = "Write Features: $NOT_AVAILABLE";
  ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  TextStyle _textStyle = TextStyle();

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

  Future<String> _readBatteryLevel(DeviceBase? device) async {
    if (device == null || device.device == null) return NOT_AVAILABLE;

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

  Future<void> _readAndWriteFeatures() async {
    List<String> readFeatures = [];
    if ((_fitnessEquipment?.readFeatures ?? 0) > 0) {
      int flagBit = 1;
      READ_FEATURE_TEXTS.forEach((readFeatureText) {
        if (_fitnessEquipment!.readFeatures & flagBit > 0) {
          readFeatures.add(readFeatureText);
        }

        flagBit *= 2;
      });
    }

    List<String> writeFeatures = [];
    if ((_fitnessEquipment?.writeFeatures ?? 0) > 0) {
      int flagBit = 1;
      WRITE_FEATURE_TEXTS.forEach((writeFeatureText) {
        if (_fitnessEquipment!.writeFeatures & flagBit > 0) {
          writeFeatures.add(writeFeatureText);
        }

        flagBit *= 2;
      });
    }

    setState(() {
      if (readFeatures.length > 0) {
        _readFeatures = "Features: " + readFeatures.join(", ");
      }

      if (writeFeatures.length > 0) {
        _writeFeatures = "Write Features: " + writeFeatures.join(", ");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline3!.apply(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getProtagonistColor(),
    );
    _sizeDefault = _textStyle.fontSize!;
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    _readBatteryLevels();
    _readAndWriteFeatures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _themeManager.getBlueIcon(getIcon(_fitnessEquipment?.sport), _sizeDefault),
                _themeManager.getBlueIcon(Icons.battery_full, _sizeDefault),
                Text(_batteryLevel, style: _textStyle),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _themeManager.getBlueIcon(Icons.favorite, _sizeDefault),
                _themeManager.getBlueIcon(Icons.battery_full, _sizeDefault),
                Text(_hrmBatteryLevel, style: _textStyle),
              ],
            ),
            Divider(),
            Text(_readFeatures),
            Divider(),
            Text(_writeFeatures),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton:
          _themeManager.getBlueFab(Icons.clear, false, false, "Close", 0, () => Get.close(1)),
    );
  }
}
