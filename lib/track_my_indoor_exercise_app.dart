import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui/bluetooth_issue.dart';
import 'ui/find_devices.dart';

class TrackMyIndoorExerciseApp extends StatefulWidget {
  TrackMyIndoorExerciseApp({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TrackMyIndoorExerciseAppState();
  }
}

class TrackMyIndoorExerciseAppState extends State<TrackMyIndoorExerciseApp> {
  Future<bool> locationGrantedFuture;

  @override
  void initState() {
    super.initState();
    if (locationGrantedFuture == null) {
      locationGrantedFuture = Permission.locationWhenInUse.request().isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (streamContext, streamSnapshot) {
            final bluetoothState = streamSnapshot.data;
            return FutureBuilder(
                future: locationGrantedFuture,
                builder: (futureContext, futureSnapshot) {
                  final locationGranted = futureSnapshot.data;
                  if (bluetoothState == BluetoothState.on && locationGranted) {
                    return FindDevicesScreen();
                  } else {
                    return BluetoothIssueScreen(
                      bluetoothState: bluetoothState,
                      locationGranted: locationGranted,
                    );
                  }
                });
          }),
    );
  }
}
