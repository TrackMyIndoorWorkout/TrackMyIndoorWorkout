import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import '../../devices/company_registry.dart';
import '../../persistence/preferences.dart';
import '../../utils/scan_result_ex.dart';
import '../../utils/string_ex.dart';
import 'common.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    Key key,
    this.result,
    @required this.onEquipmentTap,
    @required this.onHrmTap,
  })  : assert(onEquipmentTap != null),
        assert(onHrmTap != null),
        super(key: key);

  final ScanResult result;
  final VoidCallback onEquipmentTap;
  final VoidCallback onHrmTap;

  Widget _buildTitle(BuildContext context, TextStyle adjustedCaptionStyle, TextStyle dataStyle) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.device.name,
            style: standOutStyle(adjustedCaptionStyle, FONT_SIZE_FACTOR),
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

  Widget _buildAdvRow(BuildContext context, String title, String value,
      TextStyle adjustedCaptionStyle, TextStyle dataStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: adjustedCaptionStyle),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: dataStyle.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
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
      return null;
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
      return null;
    }

    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.uuidString()}: ${getNiceHexArray(bytes)}');
    });

    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final adjustedCaptionStyle =
        Theme.of(context).textTheme.caption.apply(fontSizeFactor: FONT_SIZE_FACTOR);
    final secondaryStyle = adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY);
    return ExpansionTile(
      title: _buildTitle(context, adjustedCaptionStyle, secondaryStyle),
      leading: Text(
        result.rssi.toString(),
        style: adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY),
      ),
      trailing: FloatingActionButton(
        heroTag: null,
        child: result.isHeartRateMonitor ? Icon(Icons.favorite) : Icon(Icons.play_arrow),
        foregroundColor: Colors.white,
        backgroundColor: result.advertisementData.connectable ? Colors.blue : Colors.grey,
        onPressed: result.advertisementData.connectable
            ? (result.isHeartRateMonitor ? onHrmTap : onEquipmentTap)
            : null,
      ),
      children: [
        _buildAdvRow(
          context,
          'Complete Local Name',
          result.advertisementData.localName,
          adjustedCaptionStyle,
          adjustedCaptionStyle,
        ),
        _buildAdvRow(
          context,
          'Tx Power Level',
          '${result.advertisementData.txPowerLevel ?? 'N/A'}',
          adjustedCaptionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          context,
          'Manufacturer Data',
          getNiceManufacturerData(
                  result.advertisementData.manufacturerData?.keys?.toList(growable: false)) ??
              'N/A',
          adjustedCaptionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          context,
          'Service UUIDs',
          (result.advertisementData.serviceUuids.isNotEmpty)
              ? result.serviceUuids.join(', ').toUpperCase()
              : 'N/A',
          adjustedCaptionStyle,
          secondaryStyle,
        ),
        _buildAdvRow(
          context,
          'Service Data',
          getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A',
          adjustedCaptionStyle,
          secondaryStyle,
        ),
      ],
    );
  }
}
