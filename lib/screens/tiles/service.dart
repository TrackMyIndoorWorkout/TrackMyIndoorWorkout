import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'characteristic.dart';

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key key, this.service, this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.length > 0) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Service'),
            Text('0x${service.uuid.toString().substring(4, 8).toUpperCase()}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).textTheme.caption.color))
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().substring(4, 8).toUpperCase()}'),
      );
    }
  }
}
