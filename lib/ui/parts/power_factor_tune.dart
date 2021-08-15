import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/power_tune.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PowerFactorTuneBottomSheet extends StatefulWidget {
  final String deviceId;
  final double oldPowerFactor;

  PowerFactorTuneBottomSheet({Key? key, required this.deviceId, required this.oldPowerFactor})
      : super(key: key);

  @override
  PowerFactorTuneBottomSheetState createState() => PowerFactorTuneBottomSheetState();
}

class PowerFactorTuneBottomSheetState extends State<PowerFactorTuneBottomSheet> {
  double _powerFactorPercent = 100.0;
  TextStyle _largerTextStyle = TextStyle();
  ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _powerFactorPercent = widget.oldPowerFactor * 100.0;
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(Icons.check, false, false, "", 0, () async {
        final database = Get.find<AppDatabase>();
        final powerFactor = _powerFactorPercent / 100.0;
        PowerTune? powerTune;
        if (await database.hasPowerTune(widget.deviceId)) {
          powerTune = await database.powerTuneDao.findPowerTuneByMac(widget.deviceId).first;
        }

        if (powerTune != null) {
          powerTune.powerFactor = powerFactor;
          await database.powerTuneDao.updatePowerTune(powerTune);
        } else {
          final powerTune = PowerTune(
            mac: widget.deviceId,
            powerFactor: powerFactor,
            time: DateTime.now().millisecondsSinceEpoch,
          );
          await database.powerTuneDao.insertPowerTune(powerTune);
        }
        Get.back(result: powerFactor);
      }),
    );
  }
}
