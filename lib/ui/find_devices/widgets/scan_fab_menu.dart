import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../activities.dart';
import '../../donation.dart';
import '../../parts/legend_dialog.dart';
import '../../preferences/preferences_hub.dart';
import '../logic/find_devices_controller.dart';

class ScanFabMenu extends GetView<FindDevicesController> {
  const ScanFabMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FindDevicesController>(
      builder: (controller) {
        return FabCircularMenuPlus(
          fabOpenIcon: Icon(Icons.menu, color: controller.themeManager.getAntagonistColor()),
          fabOpenColor: controller.themeManager.getBlueColor(),
          fabCloseIcon: Icon(Icons.close, color: controller.themeManager.getAntagonistColor()),
          fabCloseColor: controller.themeManager.getBlueColor(),
          ringColor: controller.themeManager.getBlueColorInverse(),
          children: [
            controller.themeManager.getTutorialFab(
              () => legendDialog([
                const Tuple2<IconData, String>(Icons.favorite, "HRM"),
                const Tuple2<IconData, String>(Icons.search, "Start Scanning"),
                const Tuple2<IconData, String>(Icons.stop, "Stop Scanning"),
                const Tuple2<IconData, String>(Icons.refresh, "Scan Again"),
                const Tuple2<IconData, String>(Icons.play_arrow, "Start Workout"),
                const Tuple2<IconData, String>(Icons.open_in_new, "Workout Again"),
                const Tuple2<IconData, String>(Icons.list_alt, "Workout List"),
                const Tuple2<IconData, String>(Icons.settings, "Preferences"),
                const Tuple2<IconData, String>(Icons.coffee, "Donation"),
                const Tuple2<IconData, String>(Icons.help, "About"),
                const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
              ]),
            ),
            controller.themeManager.getAboutFab(),
            controller.themeManager.getBlueFab(Icons.coffee, () async {
              Get.to(() => const DonationScreen());
            }),
            controller.themeManager.getBlueFab(Icons.list_alt, () {
              Get.to(() => const ActivitiesScreen());
            }),
            controller.isScanning
                ? controller.themeManager.getBlueFab(Icons.stop, () async {
                    await controller.onScanToggle(false);
                  })
                : controller.themeManager.getGreenFab(
                    Icons.search,
                    () async => await controller.onScanToggle(true),
                  ),
            controller.themeManager.getBlueFab(
              Icons.settings,
              () async => Get.to(() => const PreferencesHubScreen()),
            ),
          ],
        );
      },
    );
  }
}
