import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  Get.put<CompanyRegistry>(companyRegistry, permanent: true);

  Get.put<AdvertisementCache>(AdvertisementCache(), permanent: true);

  var blueAvailable = await FlutterBlue.instance.isAvailable;
  var blueOn = await FlutterBlue.instance.isOn;

  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    Get.put<PackageInfo>(packageInfo, permanent: true);
  });

  await Future.delayed(const Duration(milliseconds: startupIntermittentDelay));

  final bluetoothStateString = await BluetoothEnable.enableBluetooth;

  // TODO: Android 12 does not need location permission any more
  // Maybe even we can completely eliminate permission handler
  // if (Platform.isAndroid) {
  //   var androidInfo = await DeviceInfoPlugin().androidInfo;
  //   if (androidInfo.version.sdkInt < 31) {
  await Future.delayed(const Duration(milliseconds: startupIntermittentDelay));

  final permissionState = await Permission.locationWhenInUse.request();
  //   }
  // }

  await Future.delayed(const Duration(milliseconds: startupIntermittentDelay));

  blueAvailable = await FlutterBlue.instance.isAvailable;
  blueOn = await FlutterBlue.instance.isOn;

  runApp(
    TrackMyIndoorExerciseApp(
      prefService: prefService,
      blueOn: blueAvailable && blueOn,
      bluetoothStateString: bluetoothStateString,
      permissionState: permissionState,
    ),
  );
}
