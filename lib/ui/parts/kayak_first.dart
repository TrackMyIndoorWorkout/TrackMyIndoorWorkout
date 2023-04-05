import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:get/get.dart';
import 'package:number_selector/number_selector.dart';
import 'package:pref/pref.dart';
import '../../devices/device_descriptors/kayak_first_descriptor.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/boat_color.dart';
import '../../preferences/boat_weight.dart';
import '../../preferences/log_level.dart';
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
  int _logLevel = logLevelDefault;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  Color _borderColor = Colors.black;
  Color _backgroundColor = Colors.white;
  Color _iconColor = Colors.black;
  TextStyle _textStyle = const TextStyle();
  final BasePrefService _prefService = Get.find<BasePrefService>();
  int _boatWeight = boatWeightDefault;
  int _boatColor = boatColorOnConsoleDefault;
  int _athleteWeight = athleteBodyWeightDefault;
  late final CircleColorPickerController _colorPickerController;
  double? _mediaWidth;

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
    _borderColor = _themeManager.getGreyColor();
    _backgroundColor = _themeManager.isDark() ? Colors.grey.shade800 : Colors.grey.shade200;
    _iconColor = _themeManager.getProtagonistColor();
    _boatWeight = _prefService.get<int>(boatWeightTag) ?? boatWeightDefault;
    _boatColor = _prefService.get<int>(boatColorOnConsole) ?? boatColorOnConsoleDefault;
    _colorPickerController = CircleColorPickerController(initialColor: Color(_boatColor));
    _athleteWeight = _prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    _logLevel = _fitnessEquipment?.logLevel ?? logLevelDefault;
    _readBatteryLevels();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
    }

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
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Name',
                    hintText: 'Specify bluetooth name',
                  ),
                  initialValue: _fitnessEquipment?.bluetoothName ?? "",
                  controller: _textController,
                  onChanged: (String value) => {_fitnessEquipment?.bluetoothName = value},
                ),
                const Text(boatWeight),
                NumberSelector(
                  current: _boatWeight,
                  min: boatWeightMin,
                  max: boatWeightMax,
                  showMinMax: true,
                  showSuffix: false,
                  hasBorder: true,
                  borderColor: _borderColor,
                  hasDividers: true,
                  dividerColor: _borderColor,
                  backgroundColor: _backgroundColor,
                  iconColor: _iconColor,
                  onUpdate: (int value) {
                    _boatWeight = value;
                    _prefService.set<int>(boatWeightTag, value);
                  },
                ),
                const Text(boatColorOnConsole),
                CircleColorPicker(
                  controller: _colorPickerController,
                  onChanged: (color) {
                    _boatColor = color.value;
                    _prefService.set<int>(boatColorOnConsoleTag, color.value);
                  },
                  size: Size(_mediaWidth!, _mediaWidth!),
                  strokeWidth: 5,
                  thumbSize: _mediaWidth! / 5,
                  textStyle: _textStyle,
                ),
                const Text(athleteBodyWeight),
                NumberSelector(
                  current: _athleteWeight,
                  min: athleteBodyWeightMin,
                  max: athleteBodyWeightMax,
                  showMinMax: true,
                  showSuffix: false,
                  hasBorder: true,
                  borderColor: _borderColor,
                  hasDividers: true,
                  dividerColor: _borderColor,
                  backgroundColor: _backgroundColor,
                  iconColor: _iconColor,
                  onUpdate: (int value) {
                    _athleteWeight = value;
                    _prefService.set<int>(athleteBodyWeightIntTag, value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.clear, () => Get.close(1)),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, () {
              if (_fitnessEquipment != null) {
                return;
              }

              final kayakFirst = _fitnessEquipment!.descriptor as KayakFirstDescriptor;
              kayakFirst.applyConfiguration(
                _fitnessEquipment!.getControlPoint()!,
                _fitnessEquipment?.bluetoothName ?? unnamedDevice,
                _logLevel,
              );
            }),
          ],
        ),
      ),
    );
  }
}
