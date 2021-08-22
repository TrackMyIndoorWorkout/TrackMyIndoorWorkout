import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../utils/theme_manager.dart';

class UploadPortalPickerBottomSheet extends StatefulWidget {
  @override
  UploadPortalPickerBottomSheetState createState() => UploadPortalPickerBottomSheetState();
}

class UploadPortalPickerBottomSheetState extends State<UploadPortalPickerBottomSheet> {
  int _portalIndex = 0;
  List<String> _portalNames = [
    "Strava",
    "SUUNTO",
  ];
  List<Tuple2<String, String>> _portalChoices = [
    Tuple2<String, String>("Strava", "assets/strava.svg"),
    Tuple2<String, String>("SUUNTO", "assets/suunto.svg"),
  ];
  ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = TextStyle();
  TextStyle _selectedTextStyle = TextStyle();

  @override
  void initState() {
    super.initState();
    _portalIndex = max(0, _portalNames.indexOf("Strava"));
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
          children: _portalChoices
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
                        groupValue: _portalIndex,
                        onChanged: (value) {
                          setState(() {
                            _portalIndex = value as int;
                          });
                        },
                      ),
                    ),
                    SvgPicture.asset(
                      e.value.item2,
                      semanticsLabel: '${e.value.item1} Logo',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _portalIndex = e.key;
                        });
                      },
                      child: Text(e.value.item1,
                          style: _portalIndex == e.key ? _selectedTextStyle : _largerTextStyle),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(
          Icons.check, false, false, "", 0, () => Get.back(result: _portalNames[_portalIndex])),
    );
  }
}
