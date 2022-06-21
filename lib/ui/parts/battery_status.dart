import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const BatteryStatusBottomSheet({Key? key}) : super(key: key);

  @override
  BatteryStatusBottomSheetState createState() => BatteryStatusBottomSheetState();
}

class BatteryStatusBottomSheetState extends State<BatteryStatusBottomSheet> {
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  String _hrmBatteryLevel = notAvailable;
  String _batteryLevel = notAvailable;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();

  Future<String> _readBatteryLevelCore(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, batteryServiceUuid);
    if (batteryService == null) {
      return notAvailable;
    }

    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, batteryLevelUuid);
    if (batteryLevel == null) {
      return notAvailable;
    }

    final batteryLevelData = await batteryLevel.read();
    return "${batteryLevelData[0]}%";
  }

  Future<String> _readBatteryLevel(DeviceBase? device) async {
    if (device == null || device.device == null) return notAvailable;

    if (!device.connected) {
      await device.connect();
    }

    if (!device.connected) return notAvailable;

    if (!device.discovered) {
      await device.discover();
    }

    if (!device.discovered) return notAvailable;

    try {
      return await _readBatteryLevelCore(device.services);
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
      return notAvailable;
    }
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
    _textStyle = Get.textTheme.headline3!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _sizeDefault = _textStyle.fontSize!;
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    _readBatteryLevels();
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
                _themeManager.getBlueIcon(
                    getSportIcon(_fitnessEquipment?.sport ?? ActivityType.workout), _sizeDefault),
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton:
          _themeManager.getBlueFab(Icons.clear, false, false, "Close", 0, () => Get.close(1)),
    );
  }
}
