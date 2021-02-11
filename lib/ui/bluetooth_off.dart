import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({
    key,
    @required this.state,
  })  : assert(state != null),
        super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    final btState = state != null ? state.toString().substring(15) : 'not available';
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is $btState.',
              style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
