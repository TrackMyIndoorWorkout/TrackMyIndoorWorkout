import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothIssueScreen extends StatefulWidget {
  final BluetoothState bluetoothState;
  final bool locationGranted;

  const BluetoothIssueScreen({
    key,
    @required this.bluetoothState,
    @required this.locationGranted,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BluetoothIssueScreenState(
        bluetoothState: bluetoothState, locationGranted: locationGranted);
  }
}

class BluetoothIssueScreenState extends State<BluetoothIssueScreen> {
  final BluetoothState bluetoothState;
  bool locationGranted;
  String bluetoothStateString;

  BluetoothIssueScreenState({
    @required this.bluetoothState,
    @required this.locationGranted,
  })  : assert(bluetoothState != null);

  void initLocationGranted() async {
    if (locationGranted == null) {
      final locationTake2 = await Permission.locationWhenInUse.request().isGranted;
      setState(() {
        locationGranted = locationTake2;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BluetoothEnable.enableBluetooth.then((result) {
        bluetoothStateString = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothDisplay = bluetoothState?.toString()?.substring(15) ?? 'N/A';
    final locationDisplay = (locationGranted ?? false) ? "Granted" : "Denied";
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
                  'Bluetooth Adapter is $bluetoothDisplay.\n' +
                      'Location permission is $locationDisplay',
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
