import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_manager.dart';

class DataFormatPickerBottomSheet extends StatefulWidget {
  @override
  DataFormatPickerBottomSheetState createState() => DataFormatPickerBottomSheetState();
}

class DataFormatPickerBottomSheetState extends State<DataFormatPickerBottomSheet> {
  late int _formatIndex;
  late List<String> _formatChoices;
  late ThemeManager _themeManager;
  late TextStyle _largerTextStyle;
  late TextStyle _selectedTextStyle;

  @override
  void initState() {
    super.initState();
    _formatChoices = ["FIT", "TCX"];
    _formatIndex = max(0, _formatChoices.indexOf("FIT"));
    _themeManager = Get.find<ThemeManager>();
    _largerTextStyle = Get.textTheme.headline3!;
    _selectedTextStyle = _largerTextStyle.apply(color: _themeManager.getProtagonistColor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _formatChoices
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
                        groupValue: _formatIndex,
                        onChanged: (value) {
                          setState(() {
                            _formatIndex = value as int;
                          });
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _formatIndex = e.key;
                        });
                      },
                      child: Text(e.value,
                          style: _formatIndex == e.key ? _selectedTextStyle : _largerTextStyle),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(
          Icons.check, () => Get.back(result: _formatChoices[_formatIndex])),
    );
  }
}
