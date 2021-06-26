import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/gatt_constants.dart';
import '../../utils/advertisement_data_ex.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

extension HeartRateMonitorScanResult on ScanResult {
  bool isWorthy() {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name.isEmpty) {
      return false;
    }

    if (device.id.id.isEmpty) {
      return false;
    }

    return isHeartRateMonitor;
  }

  List<String> get serviceUuids => advertisementData.uuids;

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(HEART_RATE_SERVICE_ID);
}

class HeartRateMonitorScanResultTile extends StatelessWidget {
  const HeartRateMonitorScanResultTile({
    Key? key,
    required this.result,
  }) : super(key: key);

  final ScanResult result;

  Widget _buildTitle(ThemeManager themeManager, TextStyle captionStyle, TextStyle dataStyle) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.device.name,
            style: themeManager.boldStyle(captionStyle, fontSizeFactor: FONT_SIZE_FACTOR),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: dataStyle,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final captionStyle = Get.textTheme.caption!.apply(fontSizeFactor: FONT_SIZE_FACTOR);
    final secondaryStyle = captionStyle.apply(fontFamily: FONT_FAMILY);
    final themeManager = Get.find<ThemeManager>();

    return ExpansionTile(
      title: _buildTitle(themeManager, captionStyle, secondaryStyle),
      leading: Text(
        result.rssi.toString(),
        style: captionStyle.apply(fontFamily: FONT_FAMILY),
      ),
      trailing: themeManager.getIconFab(
          (heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE) == result.device.id.id
              ? themeManager.getGreenColor()
              : themeManager.getBlueColor(),
          Icons.favorite, () async {
        final existingId = heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE;
        if (existingId != NOT_AVAILABLE && existingId != result.device.id.id) {
          if (!(await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('You are connected to a HRM right now'),
                  content: Text('Disconnect from that HRM to connect the selected one?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.close(1),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              ) ??
              false)) {
            return;
          }
        }
        if (heartRateMonitor != null && heartRateMonitor!.device?.id.id != result.device.id.id) {
          heartRateMonitor!.detach();
          heartRateMonitor!.disconnect();
        }
        if (heartRateMonitor == null || heartRateMonitor!.device?.id.id != result.device.id.id) {
          heartRateMonitor = new HeartRateMonitor(result.device);
          if (Get.isRegistered<HeartRateMonitor>()) {
            Get.delete<HeartRateMonitor>();
          }
          Get.put<HeartRateMonitor>(heartRateMonitor!);
          await heartRateMonitor!.connect();
          await heartRateMonitor!.discover();
        }
        await heartRateMonitor?.attach();
      }),
    );
  }
}
