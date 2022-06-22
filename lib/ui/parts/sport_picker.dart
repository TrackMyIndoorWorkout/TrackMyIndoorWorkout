import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class SportPickerBottomSheet extends StatefulWidget {
  final List<String> sportChoices;
  final String initialSport;

  const SportPickerBottomSheet({
    Key? key,
    required this.sportChoices,
    required this.initialSport,
  }) : super(key: key);

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
    _largerTextStyle = Get.textTheme.headline4!;
    _selectedTextStyle = _largerTextStyle.apply(color: _themeManager.getProtagonistColor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          getSportIcon(e.value), _largerTextStyle.fontSize!),
                      label: Text(e.value,
                          style: _sportIndex == e.key ? _selectedTextStyle : _largerTextStyle),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(Icons.check, false, false, "", 0,
          () => Get.back(result: widget.sportChoices[_sportIndex])),
    );
  }
}
