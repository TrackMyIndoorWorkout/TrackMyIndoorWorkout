import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../devices/company_registry.dart';
import '../../utils/constants.dart';
import '../../utils/scan_result_ex.dart';
import '../../utils/string_ex.dart';
import '../../utils/theme_manager.dart';

class ScanResultTile extends StatelessWidget {
  static RegExp colonRegex = RegExp(r'\:');

  const ScanResultTile({
    Key? key,
    required this.result,
    required this.deviceSport,
    required this.onEquipmentTap,
    required this.onHrmTap,
  }) : super(key: key);

  final ScanResult result;
  final String deviceSport;
  final VoidCallback onEquipmentTap;
  final VoidCallback onHrmTap;

  Widget _buildTitle(ThemeManager themeManger, TextStyle captionStyle, TextStyle dataStyle) {
    final deviceIdString = result.device.id.id.replaceAll(colonRegex, '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.device.nonEmptyName,
          style: themeManger.boldStyle(captionStyle, fontSizeFactor: fontSizeFactor),
          overflow: TextOverflow.ellipsis,
        ),
        Text(deviceIdString, style: dataStyle),
      ],
    );
  }

  Widget _buildAdvRow(String title, String value, TextStyle captionStyle, TextStyle dataStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: captionStyle),
          const SizedBox(width: 12.0),
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
    for (var companyId in companyIds) {
      nameStrings.add(companyRegistry.nameForId(companyId));
    }

    return nameStrings.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }

    List<String> res = [];
    for (var entry in data.entries) {
      res.add('${entry.key.uuidString()}: ${getNiceHexArray(entry.value)}');
    }

    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final captionStyle = Get.textTheme.titleLarge!;
    final detailStyle = captionStyle.apply(fontSizeFactor: 1 / fontSizeFactor);
    final secondaryStyle = captionStyle.apply(fontFamily: fontFamily);
    final themeManager = Get.find<ThemeManager>();

    final deviceIcon = result.getIcon([], deviceSport);
    return ExpansionTile(
      title: _buildTitle(themeManager, captionStyle, secondaryStyle),
      leading: Icon(
        deviceIcon,
        size: captionStyle.fontSize! * 2.5,
        color: themeManager.getProtagonistColor(),
      ),
      trailing: themeManager.getIconFab(
        result.advertisementData.connectable
            ? themeManager.getBlueColor()
            : themeManager.getGreyColor(),
        deviceIcon == Icons.favorite ? Icons.favorite : Icons.play_arrow,
        result.advertisementData.connectable
            ? (deviceIcon == Icons.favorite ? onHrmTap : onEquipmentTap)
            : null,
      ),
      children: [
        _buildAdvRow(
          'Complete Name',
          result.advertisementData.localName,
          detailStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Tx Power Level',
          '${result.advertisementData.txPowerLevel ?? 'N/A'}',
          detailStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Manufacturer Data',
          getNiceManufacturerData(
              result.advertisementData.manufacturerData.keys.toList(growable: false)),
          detailStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Service UUIDs',
          result.advertisementData.serviceUuids.isNotEmpty
              ? result.serviceUuids.join(', ').toUpperCase()
              : 'N/A',
          detailStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          'Service Data',
          getNiceServiceData(result.advertisementData.serviceData),
          detailStyle,
          secondaryStyle,
        ),
      ],
    );
  }
}
