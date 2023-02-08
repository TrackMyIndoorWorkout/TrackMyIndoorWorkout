import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/gatt/ftms.dart';
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
  String _readFeatures = "Features: $notAvailable";
  String _writeFeatures = "Write Features: $notAvailable";
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();

  Future<String> _readBatteryLevel(DeviceBase? device) async {
    int batteryLevel = await device?.readBatteryLevel() ?? -1;
    if (batteryLevel < 0) {
      return notAvailable;
    }

    return "$batteryLevel%";
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
      for (var readFeatureText in readFeatureTexts) {
        if (_fitnessEquipment!.readFeatures & flagBit > 0) {
          readFeatures.add(readFeatureText);
        }

        flagBit *= 2;
      }
    }

    List<String> writeFeatures = [];
    if ((_fitnessEquipment?.writeFeatures ?? 0) > 0) {
      int flagBit = 1;
      for (var writeFeatureText in writeFeatureTexts) {
        if (_fitnessEquipment!.writeFeatures & flagBit > 0) {
          writeFeatures.add(writeFeatureText);
        }

        flagBit *= 2;
      }
    }

    setState(() {
      if (readFeatures.isNotEmpty) {
        _readFeatures = "Features: ${readFeatures.join(", ")}";
      }

      if (writeFeatures.isNotEmpty) {
        _writeFeatures = "Write Features: ${writeFeatures.join(", ")}";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.displaySmall!.apply(
      fontFamily: fontFamily,
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
      body: ListView(
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
          const Divider(),
          Text(_readFeatures),
          const Divider(),
          Text(_writeFeatures),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.close(1)),
    );
  }
}
