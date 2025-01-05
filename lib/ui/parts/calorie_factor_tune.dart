import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../persistence/calorie_tune.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CalorieFactorTuneBottomSheet extends ConsumerStatefulWidget {
  late final String deviceId;
  late final double oldCalorieFactor;
  late final bool hrBased;

  CalorieFactorTuneBottomSheet({super.key, required CalorieTune calorieTune}) {
    deviceId = calorieTune.mac;
    oldCalorieFactor = calorieTune.calorieFactor;
    hrBased = calorieTune.hrBased;
  }

  @override
  CalorieFactorTuneBottomSheetState createState() => CalorieFactorTuneBottomSheetState();
}

class CalorieFactorTuneBottomSheetState extends ConsumerState<CalorieFactorTuneBottomSheet> {
  double _calorieFactorPercent = 100.0;

  @override
  void initState() {
    super.initState();
    _calorieFactorPercent = widget.oldCalorieFactor * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeManager = Get.find<ThemeManager>();
    final largerTextStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: themeManager.getProtagonistColor(themeMode),
        );
    return Scaffold(
      body: ListView(
        children: [
          Text("Calorie Factor %", style: largerTextStyle),
          SpinBox(
            min: 1,
            max: 1000,
            value: _calorieFactorPercent,
            onChanged: (value) => _calorieFactorPercent = value,
            textStyle: largerTextStyle,
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
            themeManager.getBlueFab(Icons.clear, themeMode, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            themeManager.getGreenFab(Icons.check, themeMode, () async {
              final database = Get.find<Isar>();
              final calorieFactor = _calorieFactorPercent / 100.0;
              final calorieTune = await database.calorieTunes
                  .where()
                  .filter()
                  .macEqualTo(widget.deviceId)
                  .and()
                  .hrBasedEqualTo(widget.hrBased)
                  .sortByTimeDesc()
                  .findFirst();
              if (calorieTune != null) {
                calorieTune.calorieFactor = calorieFactor;
                database.writeTxnSync(() {
                  database.calorieTunes.putSync(calorieTune);
                });
              } else {
                final calorieTune = CalorieTune(
                  mac: widget.deviceId,
                  calorieFactor: calorieFactor,
                  hrBased: widget.hrBased,
                  time: DateTime.now(),
                );
                database.writeTxnSync(() {
                  database.calorieTunes.putSync(calorieTune);
                });
              }

              Get.back(result: calorieFactor);
            }),
          ],
        ),
      ),
    );
  }
}
