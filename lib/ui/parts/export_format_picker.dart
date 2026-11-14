import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../export/virtual_sport.dart';
import '../../preferences/virtual_workout.dart';
import '../../utils/theme_manager.dart';

class ExportFormatResult {
  final String format;
  final bool virtualWorkout;

  const ExportFormatResult({required this.format, required this.virtualWorkout});
}

class ExportFormatPickerBottomSheet extends StatefulWidget {
  final String? sport;

  const ExportFormatPickerBottomSheet({super.key, this.sport});

  @override
  ExportFormatPickerBottomSheetState createState() => ExportFormatPickerBottomSheetState();
}

class ExportFormatPickerBottomSheetState extends State<ExportFormatPickerBottomSheet> {
  int _formatIndex = 0;
  final List<String> _formatChoices = ["FIT", "TCX", "CSV"];
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _selectedTextStyle = const TextStyle();
  bool _virtualWorkout = virtualWorkoutDefault;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _formatChoices.add("JSON");
    }
    _formatIndex = max(0, _formatChoices.indexOf("FIT"));
    _largerTextStyle = Get.textTheme.headlineMedium!;
    _selectedTextStyle = _largerTextStyle.apply(color: _themeManager.getProtagonistColor());
    if (Get.isRegistered<BasePrefService>()) {
      final prefService = Get.find<BasePrefService>();
      _virtualWorkout = prefService.get<bool>(virtualWorkoutTag) ?? virtualWorkoutDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVirtual = widget.sport != null && VirtualSport.hasVirtualCounterpart(widget.sport!);

    final listChildren = <Widget>[
      ..._formatChoices.asMap().entries.map(
        (e) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(scale: 2, child: Radio(value: e.key)),
            TextButton(
              onPressed: () {
                setState(() {
                  _formatIndex = e.key;
                });
              },
              child: Text(
                e.value,
                style: _formatIndex == e.key ? _selectedTextStyle : _largerTextStyle,
              ),
            ),
          ],
        ),
      ),
    ];

    if (hasVirtual) {
      listChildren.add(const Divider());
      listChildren.add(
        SwitchListTile(
          title: const Text("Virtual Workout"),
          subtitle: Text("Export as ${VirtualSport.getVirtualSport(widget.sport!)}"),
          value: _virtualWorkout,
          activeTrackColor: _themeManager.getProtagonistColor(),
          onChanged: (bool value) {
            setState(() {
              _virtualWorkout = value;
            });
          },
        ),
      );
    }

    return Scaffold(
      body: RadioGroup(
        groupValue: _formatIndex,
        onChanged: (value) {
          setState(() {
            _formatIndex = value as int;
          });
        },
        child: ListView(children: listChildren),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.clear, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(
              Icons.check,
              () => Get.back(
                result: ExportFormatResult(
                  format: _formatChoices[_formatIndex],
                  virtualWorkout: _virtualWorkout,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
