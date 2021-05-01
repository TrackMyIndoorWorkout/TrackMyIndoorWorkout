import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothOffScreen extends StatefulWidget {
  final BluetoothState state;

  const BluetoothOffScreen({key, @required this.state}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BluetoothOffScreenState(state: state);
  }
}

class BluetoothOffScreenState extends State<BluetoothOffScreen> {
  final BluetoothState state;

  BluetoothOffScreenState({@required this.state}) : assert(state != null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BluetoothEnable.enableBluetooth.then((result) {
        debugPrint(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final btState = state?.toString()?.substring(15) ?? 'not available';
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
