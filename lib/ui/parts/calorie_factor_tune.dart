import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieFactorTuneBottomSheet extends StatefulWidget {
  final String deviceId;
  final double oldCalorieFactor;

  CalorieFactorTuneBottomSheet({Key? key, required this.deviceId, required this.oldCalorieFactor})
      : super(key: key);

  @override
  CalorieFactorTuneBottomSheetState createState() => CalorieFactorTuneBottomSheetState();
}

class CalorieFactorTuneBottomSheetState extends State<CalorieFactorTuneBottomSheet> {
  double _calorieFactorPercent = 100.0;
  TextStyle _largerTextStyle = TextStyle();
  ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _calorieFactorPercent = widget.oldCalorieFactor * 100.0;
    _largerTextStyle = Get.textTheme.headline4!.apply(
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
      floatingActionButton: _themeManager.getGreenFab(Icons.check, false, false, "", () async {
        final database = Get.find<AppDatabase>();
        final calorieFactor = _calorieFactorPercent / 100.0;
        CalorieTune? calorieTune;
        if (await database.hasCalorieTune(widget.deviceId)) {
          calorieTune = await database.calorieTuneDao.findCalorieTuneByMac(widget.deviceId).first;
        }

        if (calorieTune != null) {
          calorieTune.calorieFactor = calorieFactor;
          await database.calorieTuneDao.updateCalorieTune(calorieTune);
        } else {
          calorieTune = CalorieTune(
            mac: widget.deviceId,
            calorieFactor: calorieFactor,
            time: DateTime.now().millisecondsSinceEpoch,
          );
          await database.calorieTuneDao.insertCalorieTune(calorieTune);
        }
        Get.back(result: calorieFactor);
      }),
    );
  }
}
