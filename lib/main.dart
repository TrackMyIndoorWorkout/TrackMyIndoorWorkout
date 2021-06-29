import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'devices/company_registry.dart';
import 'track_my_indoor_exercise_app.dart';
import 'ui/models/advertisement_cache.dart';
import 'utils/delays.dart';
import 'utils/init_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await initPreferences();

  final companyRegistry = CompanyRegistry();
  await companyRegistry.loadCompanyIdentifiers();
  Get.put<CompanyRegistry>(companyRegistry);

  Get.put<AdvertisementCache>(AdvertisementCache());

  var blueAvailable = await FlutterBlue.instance.isAvailable;
  var blueOn = await FlutterBlue.instance.isOn;

  await Future.delayed(Duration(milliseconds: STARTUP_INTERMITTENT_DELAY));

  final bluetoothStateString = await BluetoothEnable.enableBluetooth;

  await Future.delayed(Duration(milliseconds: STARTUP_INTERMITTENT_DELAY));

  final permissionState = await Permission.locationWhenInUse.request();

  await Future.delayed(Duration(milliseconds: STARTUP_INTERMITTENT_DELAY));

  blueAvailable = await FlutterBlue.instance.isAvailable;
  blueOn = await FlutterBlue.instance.isOn;

  runApp(TrackMyIndoorExerciseApp(
    prefService: prefService,
    blueOn: blueAvailable && blueOn,
    bluetoothStateString: bluetoothStateString,
    permissionState: permissionState,
  ));
}
