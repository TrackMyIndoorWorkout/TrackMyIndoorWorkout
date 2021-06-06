import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui/bluetooth_issue.dart';
import 'ui/find_devices.dart';
import 'utils/theme_manager.dart';

class TrackMyIndoorExerciseApp extends StatefulWidget {
  final bool blueOn;
  final String bluetoothStateString;
  final PermissionStatus permissionState;

  const TrackMyIndoorExerciseApp({
    key,
    required this.blueOn,
    required this.bluetoothStateString,
    required this.permissionState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TrackMyIndoorExerciseAppState(
      blueOn: blueOn,
      bluetoothStateString: bluetoothStateString,
      permissionState: permissionState,
    );
  }
}

class TrackMyIndoorExerciseAppState extends State<TrackMyIndoorExerciseApp> {
  final bool blueOn;
  final String bluetoothStateString;
  PermissionStatus permissionState;
  late Future<PermissionStatus> permissionFuture;
  late ThemeManager _themeManager;

  TrackMyIndoorExerciseAppState({
    required this.blueOn,
    required this.bluetoothStateString,
    required this.permissionState,
  });

  @override
  void initState() {
    super.initState();
    _themeManager = Get.put<ThemeManager>(ThemeManager());
    permissionFuture = Permission.locationWhenInUse.request();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      color: _themeManager.getHeaderColor(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeManager.getThemeMode(),
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: blueOn ? BluetoothState.on : BluetoothState.unknown,
        builder: (streamContext, streamSnapshot) {
          return FutureBuilder<PermissionStatus>(
            future: permissionFuture,
            builder: (BuildContext futureContext, futureSnapshot) {
              final bluetoothState = streamSnapshot.data;
              final locationState = futureSnapshot.data ?? permissionState;
              if (bluetoothState == BluetoothState.on &&
                  locationState == PermissionStatus.granted) {
                return FindDevicesScreen();
              } else {
                return BluetoothIssueScreen(
                  bluetoothState: bluetoothState,
                  locationState: locationState,
                );
              }
            },
          );
        },
      ),
    );
  }
}
