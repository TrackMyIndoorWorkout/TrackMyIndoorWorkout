import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../persistence/power_tune.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PowerFactorTuneBottomSheet extends ConsumerStatefulWidget {
  final String deviceId;
  final double oldPowerFactor;

  const PowerFactorTuneBottomSheet({
    super.key,
    required this.deviceId,
    required this.oldPowerFactor,
  });

  @override
  PowerFactorTuneBottomSheetState createState() => PowerFactorTuneBottomSheetState();
}

class PowerFactorTuneBottomSheetState extends ConsumerState<PowerFactorTuneBottomSheet> {
  double _powerFactorPercent = 100.0;

  @override
  void initState() {
    super.initState();
    _powerFactorPercent = widget.oldPowerFactor * 100.0;
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
          Text("Power Factor %", style: largerTextStyle),
          SpinBox(
            min: 1,
            max: 1000,
            value: _powerFactorPercent,
            onChanged: (value) => _powerFactorPercent = value,
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
              final powerFactor = _powerFactorPercent / 100.0;
              final powerTune = await database.powerTunes
                  .where()
                  .filter()
                  .macEqualTo(widget.deviceId)
                  .sortByTimeDesc()
                  .findFirst();
              if (powerTune != null) {
                powerTune.powerFactor = powerFactor;
                database.writeTxnSync(() {
                  database.powerTunes.putSync(powerTune);
                });
              } else {
                final powerTune = PowerTune(
                  mac: widget.deviceId,
                  powerFactor: powerFactor,
                  time: DateTime.now(),
                );
                database.writeTxnSync(() {
                  database.powerTunes.putSync(powerTune);
                });
              }

              Get.back(result: powerFactor);
            }),
          ],
        ),
      ),
    );
  }
}
