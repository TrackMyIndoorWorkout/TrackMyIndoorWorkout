import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic/find_devices_controller.dart';
import 'widgets/connected_device_tile.dart';
import 'widgets/scan_fab_menu.dart';
import 'widgets/scanned_devices_list.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FindDevicesController());

    return GetBuilder<FindDevicesController>(
      builder: (controller) {
        // Update layout state
        controller.updateLayout(Get.mediaQuery.size);

        final captionStyle = Theme.of(context).textTheme.bodySmall!;
        final subtitleStyle = Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: controller.themeManager.getGreyColor());

        return Scaffold(
          appBar: AppBar(
            title: Text(controller.filterDevices ? 'Supported Devices:' : 'Devices'),
            actions: [
              if (controller.isScanning)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: controller.themeManager.getProtagonistColor(),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else if (controller.goingToRecording || controller.pairingHrm)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: controller.themeManager.getProtagonistColor(),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async => await controller.startScan(false),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.startScan(false);
            },
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              children: [
                Column(
                  children: [
                    if (controller.heartRateMonitor != null)
                      ConnectedDeviceTile(
                        device: controller.heartRateMonitor?.device,
                        icon: Icons.favorite,
                        onTap: controller.onConnectedHrmTap,
                        themeManager: controller.themeManager,
                        captionStyle: captionStyle,
                        subtitleStyle: subtitleStyle,
                      ),
                    if (controller.fitnessEquipment != null)
                      ConnectedDeviceTile(
                        device: controller.fitnessEquipment?.device,
                        icon: Icons.open_in_new,
                        onTap: controller.onConnectedEquipmentTap,
                        themeManager: controller.themeManager,
                        captionStyle: captionStyle,
                        subtitleStyle: subtitleStyle,
                      ),
                    if (controller.internalMotion != null)
                      ConnectedDeviceTile(
                        device: controller.internalMotion?.device,
                        icon: Icons.sensors,
                        onTap: controller.onConnectedMotionTap,
                        themeManager: controller.themeManager,
                        captionStyle: captionStyle,
                        subtitleStyle: subtitleStyle,
                      ),
                  ],
                ),
                const Divider(),
                const ScannedDevicesList(),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: const ScanFabMenu(),
        );
      },
    );
  }
}
