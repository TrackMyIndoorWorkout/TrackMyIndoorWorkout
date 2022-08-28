import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/power_tune.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PowerFactorTuneBottomSheet extends ConsumerStatefulWidget {
  final String deviceId;
  final double oldPowerFactor;

  const PowerFactorTuneBottomSheet({Key? key, required this.deviceId, required this.oldPowerFactor})
      : super(key: key);

  @override
  PowerFactorTuneBottomSheetState createState() => PowerFactorTuneBottomSheetState();
}

class PowerFactorTuneBottomSheetState extends ConsumerState<PowerFactorTuneBottomSheet> {
  double _powerFactorPercent = 100.0;
  TextStyle _largerTextStyle = const TextStyle();
  final ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _powerFactorPercent = widget.oldPowerFactor * 100.0;
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
            _themeManager.getBlueFab(Icons.clear, themeMode, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, themeMode, () async {
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
          ],
        ),
      ),
    );
  }
}
