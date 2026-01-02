import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../../../utils/scan_result_ex.dart';
import '../../parts/scan_result.dart';
import '../logic/find_devices_controller.dart';

class ScannedDevicesList extends GetView<FindDevicesController> {
  const ScannedDevicesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: controller.scanStreamController.stream,
      initialData: const [],
      builder: (c, snapshot) {
        if (snapshot.data == null) {
          return Container();
        }

        return Column(
          children: snapshot.data!
              .where((d) => d.isWorthy(controller.filterDevices))
              .map((r) {
                return ScanResultTile(
                  result: r,
                  deviceSport: controller.deviceSport[r.device.remoteId.str] ?? "",
                  mediaWidth: controller.mediaSizeMin,
                  onEquipmentTap: () => controller.onEquipmentTap(r),
                  onHrmTap: () => controller.onHrmTap(r),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}
