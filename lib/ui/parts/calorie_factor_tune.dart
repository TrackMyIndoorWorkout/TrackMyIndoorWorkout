import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieFactorTuneBottomSheet extends StatefulWidget {
  final String deviceId;
  final double calorieFactor;

  CalorieFactorTuneBottomSheet({Key key, @required this.deviceId, @required this.calorieFactor})
      : assert(deviceId != null),
        assert(calorieFactor != null),
        super(key: key);

  @override
  CalorieFactorTuneBottomSheetState createState() =>
      CalorieFactorTuneBottomSheetState(deviceId: deviceId, oldCalorieFactor: calorieFactor);
}

class CalorieFactorTuneBottomSheetState extends State<CalorieFactorTuneBottomSheet> {
  CalorieFactorTuneBottomSheetState({@required this.deviceId, @required this.oldCalorieFactor})
      : assert(deviceId != null),
        assert(oldCalorieFactor != null);

  final String deviceId;
  final double oldCalorieFactor;
  double _calorieFactorPercent;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;
  ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _calorieFactorPercent = oldCalorieFactor * 100.0;
    _themeManager = Get.find<ThemeManager>();
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Calorie Factor %", style: _largerTextStyle),
            SpinBox(
              min: 1,
              max: 1000,
              value: _calorieFactorPercent,
              onChanged: (value) => _calorieFactorPercent = value,
              textStyle: _largerTextStyle,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(Icons.check, () async {
        final database = Get.find<AppDatabase>();
        final calorieFactor = _calorieFactorPercent / 100.0;
        if (await database?.hasCalorieTune(deviceId) ?? false) {
          var calorieTune = await database?.calorieTuneDao?.findCalorieTuneByMac(deviceId)?.first;
          calorieTune.calorieFactor = calorieFactor;
          await database?.calorieTuneDao?.updateCalorieTune(calorieTune);
        } else {
          final calorieTune = CalorieTune(mac: deviceId, calorieFactor: calorieFactor);
          await database?.calorieTuneDao?.insertCalorieTune(calorieTune);
        }
        Get.back(result: calorieFactor);
      }),
    );
  }
}
