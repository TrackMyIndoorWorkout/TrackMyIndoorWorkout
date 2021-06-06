import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieOverrideBottomSheet extends StatefulWidget {
  final String deviceId;
  final int calories;

  CalorieOverrideBottomSheet({Key? key, required this.deviceId, required this.calories}) : super(key: key);

  @override
  CalorieOverrideBottomSheetState createState() =>
      CalorieOverrideBottomSheetState(deviceId: deviceId, oldCalories: calories.toDouble());
}

class CalorieOverrideBottomSheetState extends State<CalorieOverrideBottomSheet> {
  CalorieOverrideBottomSheetState({required this.deviceId, required this.oldCalories});

  final String deviceId;
  final double oldCalories;
  late double _newCalorie;
  late TextStyle _largerTextStyle;
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _newCalorie = oldCalories;
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
            Text("Expected Calories", style: _largerTextStyle),
            SpinBox(
              min: 1,
              max: 100000,
              value: _newCalorie,
              onChanged: (value) => _newCalorie = value,
              textStyle: _largerTextStyle,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(Icons.check, () async {
        final database = Get.find<AppDatabase>();
        final calorieFactor = _newCalorie / oldCalories;
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
