import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'ui/bluetooth_off.dart';
import 'ui/find_devices.dart';

class TrackMyIndoorExerciseApp extends StatefulWidget {
  TrackMyIndoorExerciseApp({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TrackMyIndoorExerciseAppState();
  }
}

class TrackMyIndoorExerciseAppState extends State<TrackMyIndoorExerciseApp> {
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
    return GetMaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
