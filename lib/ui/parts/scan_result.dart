import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../../devices/device_map.dart';
import '../../devices/gatt_constants.dart';
import '../../persistence/preferences.dart';
import '../../utils/string_ex.dart';
import '../find_devices.dart';

extension EnhancedScanResult on ScanResult {
  bool isWorthy(bool filterDevices) {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name == null || device.name.length <= 0) {
      return false;
    }

    if (device.id.id == null || device.id.id.length <= 0) {
      return false;
    }

    if (!filterDevices) {
      return true;
    }

    for (var dev in deviceMap.values) {
      if (device.name.startsWith(dev.namePrefix)) {
        return true;
      }
      if (advertisementData.serviceUuids.isNotEmpty) {
        final serviceUuids = advertisementData.serviceUuids.map((x) => x.uuidString()).toList();
        if (serviceUuids.contains(FITNESS_MACHINE_ID) ||
            serviceUuids.contains(PRECOR_SERVICE_ID) ||
            serviceUuids.contains(HEART_RATE_SERVICE_ID)) {
          return true;
        }
      }
    }

    return false;
  }

  List<String> get serviceUuids => advertisementData.serviceUuids.isEmpty
      ? []
      : advertisementData.serviceUuids.map((x) => x.uuidString()).toList();

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(HEART_RATE_SERVICE_ID);
}

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

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
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
          getNiceManufacturerData(result.advertisementData.manufacturerData) ?? 'N/A',
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
