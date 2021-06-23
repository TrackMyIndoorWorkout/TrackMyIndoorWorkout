import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieOverrideBottomSheet extends StatefulWidget {
  final String deviceId;
  final double oldCalories;

  CalorieOverrideBottomSheet({Key? key, required this.deviceId, required this.oldCalories})
      : super(key: key);

  @override
  CalorieOverrideBottomSheetState createState() => CalorieOverrideBottomSheetState();
}

class CalorieOverrideBottomSheetState extends State<CalorieOverrideBottomSheet> {
  double _newCalorie = 0.0;
  TextStyle _largerTextStyle = TextStyle();
  ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _newCalorie = widget.oldCalories;
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
        final calorieFactor = _newCalorie / widget.oldCalories;
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
