import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class SportPickerBottomSheet extends StatefulWidget {
  final String initialSport;
  final bool allSports;

  SportPickerBottomSheet({
    Key? key,
    required this.initialSport,
    required this.allSports,
  }) : super(key: key);

  @override
  SportPickerBottomSheetState createState() => SportPickerBottomSheetState();
}

class SportPickerBottomSheetState extends State<SportPickerBottomSheet> {
  int _sportIndex = 0;
  List<String> _sportChoices = [];
  ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = TextStyle();
  TextStyle _selectedTextStyle = TextStyle();

  @override
  void initState() {
    super.initState();

    _sportChoices = widget.allSports
        ? [
            ActivityType.Ride,
            ActivityType.Run,
            ActivityType.Elliptical,
            ActivityType.Kayaking,
            ActivityType.Canoeing,
            ActivityType.Rowing,
            ActivityType.Swim,
          ]
        : [
            ActivityType.Kayaking,
            ActivityType.Canoeing,
            ActivityType.Rowing,
            ActivityType.Swim,
          ];
    _sportIndex = max(0, _sportChoices.indexOf(widget.initialSport));
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
          children: _sportChoices
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
                      icon: _themeManager.getBlueIcon(getIcon(e.value), _largerTextStyle.fontSize!),
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
      floatingActionButton: _themeManager.getGreenFab(
          Icons.check, false, false, "", () => Get.back(result: _sportChoices[_sportIndex])),
    );
  }
}
