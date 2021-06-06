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

  CalorieFactorTuneBottomSheet({Key? key, required this.deviceId, required this.calorieFactor}) : super(key: key);

  @override
  CalorieFactorTuneBottomSheetState createState() =>
      CalorieFactorTuneBottomSheetState(deviceId: deviceId, oldCalorieFactor: calorieFactor);
}

class CalorieFactorTuneBottomSheetState extends State<CalorieFactorTuneBottomSheet> {
  CalorieFactorTuneBottomSheetState({required this.deviceId, required this.oldCalorieFactor});

  final String deviceId;
  final double oldCalorieFactor;
  late double _calorieFactorPercent;
  late TextStyle _largerTextStyle;
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _calorieFactorPercent = oldCalorieFactor * 100.0;
    _themeManager = Get.find<ThemeManager>();
    _largerTextStyle = Get.textTheme.headline3!.apply(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getProtagonistColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        CalorieTune? calorieTune;
        if (await database.hasCalorieTune(deviceId)) {
          calorieTune = await database.calorieTuneDao.findCalorieTuneByMac(deviceId).first;
        }

        if (calorieTune != null) {
          calorieTune.calorieFactor = calorieFactor;
          await database.calorieTuneDao.updateCalorieTune(calorieTune);
        } else {
          calorieTune = CalorieTune(mac: deviceId, calorieFactor: calorieFactor, time: DateTime.now().millisecondsSinceEpoch,);
          await database.calorieTuneDao.insertCalorieTune(calorieTune);
        }
        Get.back(result: calorieFactor);
      }),
    );
  }
}
