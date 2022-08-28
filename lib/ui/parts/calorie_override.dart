import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieOverrideBottomSheet extends ConsumerStatefulWidget {
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

class CalorieOverrideBottomSheetState extends ConsumerState<CalorieOverrideBottomSheet> {
  double _newCalorie = 0.0;
  TextStyle _largerTextStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _newCalorie = widget.oldCalories;
    final themeMode = ref.watch(themeModeProvider);
    _largerTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(themeMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
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
            _themeManager.getBlueFab(Icons.clear, themeMode, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, themeMode, () async {
              final database = Get.find<AppDatabase>();
              final calorieFactor = widget.oldFactor * _newCalorie / widget.oldCalories;
              CalorieTune? calorieTune;
              if (await database.hasCalorieTune(widget.deviceId, widget.hrBased)) {
                calorieTune = await database.findCalorieTuneByMac(widget.deviceId, widget.hrBased);
              }

              if (calorieTune != null) {
                calorieTune.calorieFactor = calorieFactor;
                await database.calorieTuneDao.updateCalorieTune(calorieTune);
              } else {
                calorieTune = CalorieTune(
                  mac: widget.deviceId,
                  calorieFactor: calorieFactor,
                  hrBased: widget.hrBased,
                  time: DateTime.now().millisecondsSinceEpoch,
                );
                await database.calorieTuneDao.insertCalorieTune(calorieTune);
              }
              Get.back(result: calorieFactor);
            }),
          ],
        ),
      ),
    );
  }
}
