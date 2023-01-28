import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieFactorTuneBottomSheet extends StatefulWidget {
  late final String deviceId;
  late final double oldCalorieFactor;
  late final bool hrBased;

  CalorieFactorTuneBottomSheet({Key? key, required CalorieTune calorieTune}) : super(key: key) {
    deviceId = calorieTune.mac;
    oldCalorieFactor = calorieTune.calorieFactor;
    hrBased = calorieTune.hrBased;
  }

  @override
  CalorieFactorTuneBottomSheetState createState() => CalorieFactorTuneBottomSheetState();
}

class CalorieFactorTuneBottomSheetState extends State<CalorieFactorTuneBottomSheet> {
  double _calorieFactorPercent = 100.0;
  TextStyle _largerTextStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _calorieFactorPercent = widget.oldCalorieFactor * 100.0;
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
              final database = Get.find<AppDatabase>();
              final calorieFactor = _calorieFactorPercent / 100.0;
              final calorieTune =
                  await database.findCalorieTuneByMac(widget.deviceId, widget.hrBased);
              if (calorieTune != null) {
                calorieTune.calorieFactor = calorieFactor;
                await database.calorieTuneDao.updateCalorieTune(calorieTune);
              } else {
                final calorieTune = CalorieTune(
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
