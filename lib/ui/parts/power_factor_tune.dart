import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../persistence/power_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PowerFactorTuneBottomSheet extends StatefulWidget {
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

class PowerFactorTuneBottomSheetState extends State<PowerFactorTuneBottomSheet> {
  double _powerFactorPercent = 100.0;
  TextStyle _largerTextStyle = const TextStyle();
  final ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _powerFactorPercent = widget.oldPowerFactor * 100.0;
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
          Text("Power Factor %", style: _largerTextStyle),
          SpinBox(
            min: 1,
            max: 1000,
            value: _powerFactorPercent,
            onChanged: (value) => _powerFactorPercent = value,
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
