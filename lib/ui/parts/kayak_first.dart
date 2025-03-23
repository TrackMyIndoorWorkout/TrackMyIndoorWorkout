import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:number_selector/number_selector.dart';
import 'package:pref/pref.dart';

import '../../devices/device_descriptors/kayak_first_descriptor.dart';
import '../../devices/gadgets/device_base.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/kayak_first_display_configuration.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../preferences/kayak_first_display_slot.dart';

class KayakFirstBottomSheet extends StatefulWidget {
  const KayakFirstBottomSheet({super.key});

  @override
  KayakFirstBottomSheetState createState() => KayakFirstBottomSheetState();
}

class KayakFirstBottomSheetState extends State<KayakFirstBottomSheet> {
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  String _hrmBatteryLevel = notAvailable;
  int _logLevel = logLevelDefault;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  Color _borderColor = Colors.black;
  Color _backgroundColor = Colors.white;
  Color _iconColor = Colors.black;
  TextStyle _textStyle = const TextStyle();
  final BasePrefService _prefService = Get.find<BasePrefService>();
  int _athleteWeight = athleteBodyWeightDefault;
  final List<int> _slotChoices = kayakFirstDisplaySlots.map((s) => s.item4).toList(growable: false);
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
    _athleteWeight = _prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    kayakFirstDisplaySlots.forEachIndexed((index, element) {
      _slotChoices[index] = _prefService.get<int>(element.item2) ?? element.item4;
    });

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

    final List<Widget> listItems = [
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
      SvgPicture.asset(
        "assets/equipment/KayakFirst_banner.svg",
        width: mediaWidth,
        semanticsLabel: "Kayak First Banner",
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
      ElevatedButton(
        onPressed: () async {
          if (_fitnessEquipment == null) {
            return;
          }

          final kayakFirst = _fitnessEquipment!.descriptor as KayakFirstDescriptor;
          final controlPoint = _fitnessEquipment!.getControlPoint()!;
          await kayakFirst.handshake(controlPoint, false, _logLevel);
        },
        child: const Text("Apply Weight"),
      ),
      const Text(kayakFirstDisplay),
    ];

    kayakFirstDisplaySlots.forEachIndexed((index, element) {
      listItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(element.item1),
            DropdownButton<int>(
              value: _slotChoices[index],
              icon: const Icon(Icons.arrow_downward),
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _slotChoices[index] = value;
                  });
                }
              },
              items: getKayakFirstDisplayChoices(),
            ),
          ],
        ),
      );
    });

    listItems.add(
      ElevatedButton(
        onPressed: () async {
          if (_fitnessEquipment == null) {
            return;
          }

          kayakFirstDisplaySlots.forEachIndexed((index, element) {
            _prefService.set<int>(element.item2, _slotChoices[index]);
          });

          final kayakFirst = _fitnessEquipment!.descriptor as KayakFirstDescriptor;
          final controlPoint = _fitnessEquipment!.getControlPoint()!;
          await kayakFirst.configureDisplay(controlPoint, _logLevel);
        },
        child: const Text("Apply Display"),
      ),
    );

    return Scaffold(
      body: ListView(children: listItems),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.close(1)),
    );
  }
}
