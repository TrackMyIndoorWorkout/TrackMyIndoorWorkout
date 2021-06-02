import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'devices/company_registry.dart';
import 'track_my_indoor_exercise_app.dart';
import 'ui/models/advertisement_cache.dart';
import 'utils/init_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initPreferences();

  final companyRegistry = CompanyRegistry();
  await companyRegistry.loadCompanyIdentifiers();
  Get.put<CompanyRegistry>(companyRegistry);

  Get.put<AdvertisementCache>(AdvertisementCache());

  final blueOn = await FlutterBlue.instance.isAvailable && await FlutterBlue.instance.isOn;
  final bluetoothStateString = await BluetoothEnable.enableBluetooth;
  final permissionState = await Permission.locationWhenInUse.request();

  runApp(TrackMyIndoorExerciseApp(
    blueOn: blueOn,
    bluetoothStateString: bluetoothStateString,
    permissionState: permissionState,
  ));
}
