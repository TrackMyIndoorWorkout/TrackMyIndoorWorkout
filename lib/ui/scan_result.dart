import 'package:charts_flutter/flutter.dart' hide TextStyle;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);
  static const fontSizeFactor = 2.0;

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context, TextStyle adjustedCaptionStyle) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            style: adjustedCaptionStyle.apply(
              fontSizeFactor: fontSizeFactor,
              color: Colors.black,
              fontWeightDelta: 3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: adjustedCaptionStyle.apply(fontFamily: 'DSEG14'),
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
        children: <Widget>[
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
    final byteStrings =
        bytes.map((i) => i.toRadixString(16).toUpperCase().padLeft(2, '0'));
    return '[${byteStrings.join(', ')}]';
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final adjustedCaptionStyle = Theme.of(context)
        .textTheme
        .caption
        .apply(fontSizeFactor: fontSizeFactor);
    final dseg14 = adjustedCaptionStyle.apply(fontFamily: 'DSEG14');
    return ExpansionTile(
      title: _buildTitle(context, adjustedCaptionStyle),
      leading: Text(
        result.rssi.toString(),
        style: adjustedCaptionStyle.apply(fontFamily: 'DSEG7'),
      ),
      trailing: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.play_arrow),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
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
          dseg14,
        ),
        _buildAdvRow(
          context,
          'Manufacturer Data',
          getNiceManufacturerData(result.advertisementData.manufacturerData) ??
              'N/A',
          adjustedCaptionStyle,
          dseg14,
        ),
        _buildAdvRow(
          context,
          'Service UUIDs',
          (result.advertisementData.serviceUuids.isNotEmpty)
              ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
              : 'N/A',
          adjustedCaptionStyle,
          dseg14,
        ),
        _buildAdvRow(
          context,
          'Service Data',
          getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A',
          adjustedCaptionStyle,
          dseg14,
        ),
      ],
    );
  }
}
