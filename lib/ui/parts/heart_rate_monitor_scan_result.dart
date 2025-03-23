import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/gatt/hrm.dart';
import '../../utils/advertisement_data_ex.dart';
import '../../utils/constants.dart';
import '../../utils/scan_result_ex.dart';
import '../../utils/string_ex.dart';
import '../../utils/theme_manager.dart';

extension HeartRateMonitorScanResult on ScanResult {
  bool isWorthy() {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.remoteId.str.isEmpty) {
      return false;
    }

    return isHeartRateMonitor;
  }

  List<String> get serviceUuids => advertisementData.uuids;

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(heartRateServiceUuid);
}

class HeartRateMonitorScanResultTile extends StatelessWidget {
  const HeartRateMonitorScanResultTile({super.key, required this.result, required this.onTap});

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(ThemeManager themeManager, TextStyle captionStyle, TextStyle dataStyle) {
    final deviceIdString = result.device.remoteId.str.shortAddressString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.nonEmptyName,
          style: themeManager.boldStyle(captionStyle, fontSizeFactor: fontSizeFactor),
          overflow: TextOverflow.ellipsis,
        ),
        Text(deviceIdString, style: dataStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final captionStyle = Get.textTheme.bodySmall!.apply(fontSizeFactor: fontSizeFactor);
    final secondaryStyle = captionStyle.apply(fontFamily: fontFamily);
    final themeManager = Get.find<ThemeManager>();

    return ExpansionTile(
      title: _buildTitle(themeManager, captionStyle, secondaryStyle),
      leading: Text(result.rssi.toString(), style: captionStyle.apply(fontFamily: fontFamily)),
      trailing: themeManager.getIconFab(
        (heartRateMonitor?.device?.remoteId.str ?? notAvailable) == result.device.remoteId.str
            ? themeManager.getGreenColor()
            : themeManager.getBlueColor(),
        Icons.favorite,
        onTap,
      ),
    );
  }
}
