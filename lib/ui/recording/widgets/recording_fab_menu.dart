import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../devices/device_fourcc.dart';
import '../../../devices/gadgets/fitness_equipment.dart';
import '../../../preferences/stage_mode.dart';
import '../../../utils/theme_manager.dart';
import '../../activities.dart';
import '../../parts/battery_status.dart';
import '../../parts/kayak_first.dart';
import '../../parts/spin_down.dart';

class RecordingFabMenu extends StatelessWidget {
  const RecordingFabMenu({
    super.key,
    required this.fabKey,
    required this.themeManager,
    required this.isLocked,
    required this.measuring,
    required this.busy,
    required this.circuitWorkout,
    required this.heartRateMonitorWorkout,
    required this.fitnessEquipment,
    required this.instantOnStage,
    required this.onStageStatisticsType,
    required this.onStartStop,
    required this.onUpload,
    required this.onLock,
    required this.onStage,
    required this.onHrmPairing,
  });

  final GlobalKey<FabCircularMenuPlusState> fabKey;
  final ThemeManager themeManager;
  final bool isLocked;
  final bool measuring;
  final bool busy;
  final bool circuitWorkout;
  final bool heartRateMonitorWorkout;
  final FitnessEquipment? fitnessEquipment;
  final bool instantOnStage;
  final String onStageStatisticsType;

  final VoidCallback onStartStop;
  final Future<void> Function() onUpload;
  final VoidCallback onLock;
  final VoidCallback onStage;
  final Future<void> Function() onHrmPairing;

  void _showBatteryStatus() {
    Get.bottomSheet(
      const SafeArea(
        child: Column(
          children: [Expanded(child: Center(child: BatteryStatusBottomSheet()))],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: false,
    );
  }

  void _showCalibration() {
    if (!(fitnessEquipment?.descriptor?.isFitnessMachine ?? false) &&
        fitnessEquipment?.descriptor?.fourCC != kayakFirstFourCC) {
      Get.snackbar("Error", "Not compatible with the calibration method");
    } else {
      Get.bottomSheet(
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: fitnessEquipment?.descriptor?.fourCC == kayakFirstFourCC
                      ? const KayakFirstBottomSheet()
                      : const SpinDownBottomSheet(),
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
        ignoreSafeArea: false,
        isDismissible: false,
        enableDrag: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FabCircularMenuPlus(
      key: fabKey,
      fabOpenIcon: Icon(
        isLocked ? Icons.lock : Icons.menu,
        color: themeManager.getAntagonistColor(),
      ),
      fabOpenColor: themeManager.getBlueColor(),
      fabCloseIcon: Icon(Icons.close, color: themeManager.getAntagonistColor()),
      fabCloseColor: themeManager.getBlueColor(),
      ringColor: themeManager.getBlueColorInverse(),
      children: _buildMenuButtons(),
    );
  }

  List<Widget> _buildMenuButtons() {
    List<Widget> menuButtons = [];

    if (measuring) {
      if (!circuitWorkout) {
        menuButtons.add(themeManager.getGreenFab(Icons.lock_open, onLock));

        if (!instantOnStage && onStageStatisticsType != onStageStatisticsTypeNone) {
          menuButtons.add(themeManager.getBlueFab(Icons.sports_score, onStage));
        }
      }
    } else {
      menuButtons.addAll([
        themeManager.getBlueFab(Icons.cloud_upload, () async {
          await onUpload();
        }),
        themeManager.getBlueFab(Icons.list_alt, () {
          Get.to(() => const ActivitiesScreen());
        }),
        themeManager.getBlueFab(Icons.battery_unknown, _showBatteryStatus),
        themeManager.getBlueFab(Icons.build, _showCalibration),
      ]);
    }

    if (!heartRateMonitorWorkout && !(fitnessEquipment?.descriptor?.isHeartRateMonitor ?? false)) {
      menuButtons.add(
        themeManager.getBlueFab(Icons.favorite, () async {
          await onHrmPairing();
        }),
      );
    }

    menuButtons.add(
      themeManager.getBlueFab(
        busy ? Icons.hourglass_bottom : (measuring ? Icons.stop : Icons.play_arrow),
        () async {
          if (!busy) {
            onStartStop();
          }
        },
      ),
    );

    return menuButtons;
  }
}
