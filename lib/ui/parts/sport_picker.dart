import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class SportPickerBottomSheet extends StatefulWidget {
  final List<String> sportChoices;
  final String initialSport;

  const SportPickerBottomSheet({super.key, required this.sportChoices, required this.initialSport});

  @override
  SportPickerBottomSheetState createState() => SportPickerBottomSheetState();
}

class SportPickerBottomSheetState extends State<SportPickerBottomSheet> {
  int _sportIndex = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _selectedTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();

    _sportIndex = max(0, widget.sportChoices.indexOf(widget.initialSport));
    _largerTextStyle = Get.textTheme.headlineMedium!;
    _selectedTextStyle = _largerTextStyle.apply(color: _themeManager.getProtagonistColor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: widget.sportChoices
            .asMap()
            .entries
            .map(
              (e) => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 2,
                    child: Radio(
                      value: e.key,
                      groupValue: _sportIndex,
                      onChanged: (value) {
                        setState(() {
                          _sportIndex = value as int;
                        });
                      },
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _sportIndex = e.key;
                      });
                    },
                    icon: _themeManager.getBlueIcon(
                      getSportIcon(e.value),
                      _largerTextStyle.fontSize!,
                    ),
                    label: TextOneLine(
                      e.value,
                      style: _sportIndex == e.key ? _selectedTextStyle : _largerTextStyle,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(
        Icons.check,
        () => Get.back(result: widget.sportChoices[_sportIndex]),
      ),
    );
  }
}
