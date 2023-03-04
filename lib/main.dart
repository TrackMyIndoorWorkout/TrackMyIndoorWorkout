import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/timezone.dart' as tz;

import 'devices/company_registry.dart';
import 'track_my_indoor_exercise_app.dart';
import 'devices/company_registry.dart';
import 'persistence/isar/activity.dart';
import 'persistence/isar/calorie_tune.dart';
import 'persistence/isar/device_usage.dart';
import 'persistence/isar/power_tune.dart';
import 'ui/models/advertisement_cache.dart';
import 'persistence/isar/record.dart';
import 'persistence/isar/workout_summary.dart';
import 'utils/init_preferences.dart';
import 'utils/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await Isar.open([
    ActivitySchema,
    CalorieTuneSchema,
    DeviceUsageSchema,
    PowerTuneSchema,
    RecordSchema,
    WorkoutSummarySchema,
  ]);
  Get.put<Isar>(isar, permanent: true);

  final prefService = await initPreferences();

  final companyRegistry = CompanyRegistry();
  await companyRegistry.loadCompanyIdentifiers();
  Get.put<CompanyRegistry>(companyRegistry, permanent: true);

  Get.put<AdvertisementCache>(AdvertisementCache(), permanent: true);

  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    Get.put<PackageInfo>(packageInfo, permanent: true);
    Logging.logVersion(packageInfo);
  });

  rootBundle
      .load('assets/timezones_10y.tzf')
      .then((byteData) => {tz.initializeDatabase(byteData.buffer.asUint8List())});

  runApp(TrackMyIndoorExerciseApp(prefService: prefService));
}
