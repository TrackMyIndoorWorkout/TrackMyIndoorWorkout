import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/theme_manager.dart';

class BluetoothIssueScreen extends StatefulWidget {
  final BluetoothState? bluetoothState;
  final PermissionStatus locationState;

  const BluetoothIssueScreen({
    key,
    this.bluetoothState,
    required this.locationState,
  }) : super(key: key);

  @override
  BluetoothIssueScreenState createState() => BluetoothIssueScreenState();
}

class BluetoothIssueScreenState extends State<BluetoothIssueScreen> {
  late PermissionStatus locationState = PermissionStatus.denied;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    locationState = widget.locationState;
    _textStyle = Get.textTheme.headline6!.apply(color: Colors.white);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // TODO: Android does not need this any more
      if (locationState != PermissionStatus.granted && locationState != PermissionStatus.limited) {
        final locationTake2 = await Permission.locationWhenInUse.request();
        setState(() {
          locationState = locationTake2;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothDisplay = widget.bluetoothState?.toString().substring(15) ?? 'N/A';
    final locationDisplay =
        locationState.isGranted ? "Granted" : (locationState.isLimited ? "Limited" : "Denied");
    return Scaffold(
      backgroundColor: _themeManager.getHeaderColor(),
      body: GestureDetector(
        onLongPress: () => Get.snackbar("Warning",
            "Make sure you turn on your Bluetooth Adapter and location permission is required for Bluetooth functionality!"),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white,
              ),
              Flexible(
                child: Text(
                  'Bluetooth Adapter is $bluetoothDisplay.\nLocation permission is $locationDisplay',
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
