import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class BluetoothIssueScreen extends StatefulWidget {
  final BluetoothState blueToothState;
  final bool locationGranted;

  const BluetoothIssueScreen({
    key,
    @required this.blueToothState,
    @required this.locationGranted,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BluetoothIssueScreenState(
        blueToothState: blueToothState, locationGranted: locationGranted);
  }
}

class BluetoothIssueScreenState extends State<BluetoothIssueScreen> {
  final BluetoothState blueToothState;
  final bool locationGranted;

  BluetoothIssueScreenState({
    @required this.blueToothState,
    @required this.locationGranted,
  })  : assert(blueToothState != null),
        assert(locationGranted != null);

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
    final bluetoothState = blueToothState?.toString()?.substring(15) ?? 'N/A';
    final locationState = (locationGranted ?? false) ? "Granted" : "Denied";
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: GestureDetector(
        onLongPress: () => Get.snackbar(
            "Warning",
            "Make sure you turn on your Bluetooth Adapter and " +
                "location permission is required for Bluetooth functionality!"),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white54,
              ),
              Flexible(
                child: Text(
                  'Bluetooth Adapter is $bluetoothState.\n' +
                      'Location permission is $locationState',
                  style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(color: Colors.white),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
