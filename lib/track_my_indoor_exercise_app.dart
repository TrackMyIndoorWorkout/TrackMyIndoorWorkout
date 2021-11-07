import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pref/pref.dart';
import 'ui/bluetooth_issue.dart';
import 'ui/find_devices.dart';
import 'utils/theme_manager.dart';

class TrackMyIndoorExerciseApp extends StatefulWidget {
  final BasePrefService prefService;
  final bool blueOn;
  final String bluetoothStateString;
  final PermissionStatus permissionState;

  const TrackMyIndoorExerciseApp({
    key,
    required this.prefService,
    required this.blueOn,
    required this.bluetoothStateString,
    required this.permissionState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrackMyIndoorExerciseAppState();
}

class TrackMyIndoorExerciseAppState extends State<TrackMyIndoorExerciseApp> {
  Future<PermissionStatus>? permissionFuture;
  ThemeManager? _themeManager;

  @override
  void initState() {
    super.initState();
    _themeManager = Get.put<ThemeManager>(ThemeManager(), permanent: true);
    permissionFuture = Permission.locationWhenInUse.request();
  }

  @override
  Widget build(BuildContext context) {
    return PrefService(
      service: widget.prefService,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        color: _themeManager!.getHeaderColor(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _themeManager!.getThemeMode(),
        home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: widget.blueOn ? BluetoothState.on : BluetoothState.unknown,
          builder: (streamContext, streamSnapshot) {
            return FutureBuilder<PermissionStatus>(
              future: permissionFuture,
              builder: (BuildContext futureContext, futureSnapshot) {
                final bluetoothState = streamSnapshot.data;
                final locationState = futureSnapshot.data ?? widget.permissionState;
                if (bluetoothState == BluetoothState.on &&
                    locationState == PermissionStatus.granted) {
                  return const FindDevicesScreen();
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
      ),
    );
  }
}
