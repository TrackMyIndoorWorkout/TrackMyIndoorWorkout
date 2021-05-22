import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/theme_manager.dart';

class BluetoothIssueScreen extends StatefulWidget {
  final BluetoothState bluetoothState;
  final PermissionStatus locationState;

  const BluetoothIssueScreen({
    key,
    @required this.bluetoothState,
    @required this.locationState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BluetoothIssueScreenState(
      bluetoothState: bluetoothState,
      locationState: locationState,
    );
  }
}

class BluetoothIssueScreenState extends State<BluetoothIssueScreen> {
  final BluetoothState bluetoothState;
  PermissionStatus locationState;
  ThemeManager _themeManager;
  TextStyle _textStyle;

  BluetoothIssueScreenState({
    @required this.bluetoothState,
    @required this.locationState,
  })  : assert(bluetoothState != null),
        assert(locationState != null);

  @override
  void initState() {
    super.initState();
    _themeManager = Get.find<ThemeManager>();
    _textStyle = Get.textTheme.headline6.apply(color: Colors.white);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (locationState == null) {
        final locationTake2 = await Permission.locationWhenInUse.request();
        setState(() {
          locationState = locationTake2;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothDisplay = bluetoothState?.toString()?.substring(15) ?? 'N/A';
    final locationDisplay = (locationState.isGranted ?? false) ? "Granted" : "Denied";
    return Scaffold(
      backgroundColor: _themeManager.getHeaderColor(),
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
                color: Colors.white,
              ),
              Flexible(
                child: Text(
                  'Bluetooth Adapter is $bluetoothDisplay.\n' +
                      'Location permission is $locationDisplay',
                  style: _textStyle,
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
