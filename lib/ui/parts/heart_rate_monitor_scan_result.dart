import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/gatt_constants.dart';
import '../../persistence/preferences.dart';
import '../../utils/string_ex.dart';
import '../find_devices.dart';

extension HeartRateMonitorScanResult on ScanResult {
  bool isWorthy() {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name == null || device.name.length <= 0) {
      return false;
    }

    if (device.id.id == null || device.id.id.length <= 0) {
      return false;
    }

    return isHeartRateMonitor;
  }

  List<String> get serviceUuids => advertisementData.serviceUuids.isEmpty
      ? []
      : advertisementData.serviceUuids.map((x) => x.uuidString()).toList();

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(HEART_RATE_SERVICE_ID);
}

class HeartRateMonitorScanResultTile extends StatelessWidget {
  const HeartRateMonitorScanResultTile({
    Key key,
    this.result,
  }) : super(key: key);

  final ScanResult result;

  Widget _buildTitle(BuildContext context, TextStyle adjustedCaptionStyle, TextStyle dataStyle) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.device.name,
            style: standOutStyle(
              adjustedCaptionStyle,
              FindDevicesState.fontSizeFactor,
            ),
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
    final adjustedCaptionStyle =
        Theme.of(context).textTheme.caption.apply(fontSizeFactor: FindDevicesState.fontSizeFactor);
    final secondaryStyle = adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY);
    return ExpansionTile(
      title: _buildTitle(context, adjustedCaptionStyle, secondaryStyle),
      leading: Text(
        result.rssi.toString(),
        style: adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY),
      ),
      trailing: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.favorite),
        foregroundColor: Colors.white,
        backgroundColor: result.advertisementData.connectable ? Colors.blue : Colors.grey,
        onPressed: () async {
          var heartRateMonitor =
              Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
          if (heartRateMonitor != null && heartRateMonitor.device.id.id != result.device.id.id) {
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
          if (heartRateMonitor != null && heartRateMonitor.device.id.id != result.device.id.id) {
            await heartRateMonitor.detach();
            await heartRateMonitor.disconnect();
          }
          if (heartRateMonitor == null || heartRateMonitor.device?.id?.id != result.device.id.id) {
            heartRateMonitor = new HeartRateMonitor(result.device);
            Get.put<HeartRateMonitor>(heartRateMonitor);
            await heartRateMonitor.connect();
            await heartRateMonitor.discover();
          }
          await heartRateMonitor.attach();
        },
      ),
    );
  }
}
