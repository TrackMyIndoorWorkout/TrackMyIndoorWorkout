import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/company_registry.dart';
import '../../utils/constants.dart';
import '../../utils/scan_result_ex.dart';
import '../../utils/string_ex.dart';
import '../../utils/theme_manager.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    Key? key,
    required this.result,
    required this.onEquipmentTap,
    required this.onHrmTap,
  }) : super(key: key);

  final ScanResult result;
  final VoidCallback onEquipmentTap;
  final VoidCallback onHrmTap;

  Widget _buildTitle(ThemeManager themeManger, TextStyle captionStyle, TextStyle dataStyle) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.device.name,
            style: themeManger.boldStyle(captionStyle, fontSizeFactor: FONT_SIZE_FACTOR),
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

  Widget _buildAdvRow(String title, String value, TextStyle captionStyle, TextStyle dataStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: captionStyle),
          SizedBox(width: 12.0),
          Expanded(child: Text(value, softWrap: true)),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    final byteStrings = bytes.map((i) => i.toRadixString(16).toUpperCase().padLeft(2, '0'));

    return '[${byteStrings.join(', ')}]';
  }

  String getNiceManufacturerData(List<int> companyIds) {
    if (companyIds.isEmpty) {
      return 'N/A';
    }

    final companyRegistry = Get.find<CompanyRegistry>();
    List<String> nameStrings = [];
    companyIds.forEach((companyId) {
      nameStrings.add(companyRegistry.nameForId(companyId));
    });

    return nameStrings.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }

    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.uuidString()}: ${getNiceHexArray(bytes)}');
    });

    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final captionStyle = Get.textTheme.headline6!;
    final secondaryStyle = captionStyle.apply(fontFamily: FONT_FAMILY);
    final themeManager = Get.find<ThemeManager>();

    return ExpansionTile(
      title: _buildTitle(themeManager, captionStyle, secondaryStyle),
      leading: Text(
        result.rssi.toString(),
        style: captionStyle.apply(fontFamily: FONT_FAMILY),
      ),
      trailing: themeManager.getIconFab(
        result.advertisementData.connectable
            ? themeManager.getBlueColor()
            : themeManager.getGreyColor(),
        result.isHeartRateMonitor ? Icons.favorite : Icons.play_arrow,
        result.advertisementData.connectable
            ? (result.isHeartRateMonitor ? onHrmTap : onEquipmentTap)
            : null,
      ),
      children: [
        _buildAdvRow(
          'Complete Local Name',
          result.advertisementData.localName,
          captionStyle,
          captionStyle,
        ),
        _buildAdvRow(
          'Tx Power Level',
          '${result.advertisementData.txPowerLevel ?? 'N/A'}',
          captionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Manufacturer Data',
          getNiceManufacturerData(
                  result.advertisementData.manufacturerData.keys.toList(growable: false)),
          captionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Service UUIDs',
          (result.advertisementData.serviceUuids.isNotEmpty)
              ? result.serviceUuids.join(', ').toUpperCase()
              : 'N/A',
          captionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Service Data',
          getNiceServiceData(result.advertisementData.serviceData),
          captionStyle,
          secondaryStyle,
        ),
      ],
    );
  }
}
