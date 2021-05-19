import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';

class SportPickerBottomSheet extends StatefulWidget {
  final String initialSport;
  final bool allSports;

  SportPickerBottomSheet({
    Key key,
    @required this.initialSport,
    @required this.allSports,
  })  : assert(initialSport != null),
        assert(allSports != null),
        super(key: key);

  @override
  SportPickerBottomSheetState createState() => SportPickerBottomSheetState(
        initialSport: initialSport,
        allSports: allSports,
      );
}

class SportPickerBottomSheetState extends State<SportPickerBottomSheet> {
  SportPickerBottomSheetState({
    @required this.initialSport,
    @required this.allSports,
  })  : assert(initialSport != null),
        assert(allSports != null);

  final String initialSport;
  final bool allSports;
  int _sportIndex;
  List<String> _sportChoices;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;

  @override
  void initState() {
    super.initState();

    _sportChoices = allSports
        ? [
            ActivityType.Ride,
            ActivityType.Run,
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
    _sportIndex = max(0, _sportChoices.indexOf(initialSport));
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 10;
      _selectedTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
      _largerTextStyle = _selectedTextStyle.apply(color: Colors.black);
    }

    return Scaffold(
      body: Column(
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
                          _sportIndex = value;
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
                    icon: Icon(
                      getIcon(e.value),
                      color: Colors.indigo,
                      size: _largerTextStyle.fontSize,
                    ),
                    label: Text(e.value,
                        style: _sportIndex == e.key ? _selectedTextStyle : _largerTextStyle),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        child: Icon(Icons.check),
        onPressed: () => Get.back(result: _sportChoices[_sportIndex]),
      ),
    );
  }
}
