import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../persistence/isar/activity.dart';
import '../../persistence/isar/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieOverrideBottomSheet extends StatefulWidget {
  late final String deviceId;
  late final double oldFactor;
  late final double oldCalories;
  late final bool hrBased;

  CalorieOverrideBottomSheet({Key? key, required Activity activity}) : super(key: key) {
    if (activity.hrBasedCalories) {
      if (activity.hrmId.isNotEmpty) {
        deviceId = activity.hrmId;
        oldFactor = activity.hrmCalorieFactor;
      } else {
        deviceId = activity.deviceId;
        oldFactor = activity.hrCalorieFactor;
      }
    } else {
      deviceId = activity.deviceId;
      oldFactor = activity.calorieFactor;
    }
    oldCalories = activity.calories.toDouble();
    hrBased = activity.hrBasedCalories;
  }

  @override
  CalorieOverrideBottomSheetState createState() => CalorieOverrideBottomSheetState();
}

class CalorieOverrideBottomSheetState extends State<CalorieOverrideBottomSheet> {
  double _newCalorie = 0.0;
  TextStyle _largerTextStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _newCalorie = widget.oldCalories;
    _largerTextStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.clear, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, () async {
              final isar = Get.find<Isar>();
              final calorieFactor = widget.oldFactor * _newCalorie / widget.oldCalories;
              final calorieTune =
                  await isar.findCalorieTuneByMac(widget.deviceId, widget.hrBased);
              if (calorieTune != null) {
                calorieTune.calorieFactor = calorieFactor;
                await isar.calorieTuneDao.updateCalorieTune(calorieTune);
              } else {
                final calorieTune = CalorieTune(
                  mac: widget.deviceId,
                  calorieFactor: calorieFactor,
                  hrBased: widget.hrBased,
                  time: DateTime.now().millisecondsSinceEpoch,
                );
                await isar.calorieTuneDao.insertCalorieTune(calorieTune);
              }
              Get.back(result: calorieFactor);
            }),
          ],
        ),
      ),
    );
  }
}
