import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class KayakFirstBottomSheet extends StatefulWidget {
  const KayakFirstBottomSheet({Key? key}) : super(key: key);

  @override
  KayakFirstBottomSheetState createState() => KayakFirstBottomSheetState();
}

class KayakFirstBottomSheetState extends State<KayakFirstBottomSheet> {
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  String _hrmBatteryLevel = notAvailable;
  String _commandResponse = "Response: $notAvailable";
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
    var batteryLevel = await _readBatteryLevel(_heartRateMonitor);
    setState(() {
      _hrmBatteryLevel = batteryLevel;
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
    _fitnessEquipment?.listenToKayakFirst((measurement) => setState(() {
      _commandResponse = "Response: $measurement";
    }));
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
              _themeManager.getBlueIcon(Icons.favorite, _sizeDefault),
              _themeManager.getBlueIcon(Icons.battery_full, _sizeDefault),
              Text(_hrmBatteryLevel, style: _textStyle),
            ],
          ),
          const Divider(),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'Command',
                    hintText: 'Specify command',
                    suffixIcon: ElevatedButton(
                      child: _themeManager.getBlueIcon(Icons.keyboard_command_key, _sizeDefault),
                      onPressed: () async {
                        await _fitnessEquipment?.sendKayakFirstCommand(_textController.text);
                      },
                    ),
                  ),
                  controller: _textController,
                ),
              ],
            ),
          ),
          Text(_commandResponse),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.close(1)),
    );
  }
}
