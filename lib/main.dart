import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:timezone/timezone.dart' as tz;

import 'devices/company_registry.dart';
import 'preferences/database_location.dart';
import 'preferences/log_level.dart';
import 'track_my_indoor_exercise_app.dart';
import 'persistence/isar/activity.dart';
import 'persistence/isar/calorie_tune.dart';
import 'persistence/isar/device_usage.dart';
import 'persistence/isar/floor_migration.dart';
import 'persistence/isar/floor_record_migration.dart';
import 'persistence/isar/log_entry.dart';
import 'persistence/isar/power_tune.dart';
import 'ui/models/advertisement_cache.dart';
import 'ui/models/progress_state.dart';
import 'persistence/isar/record.dart';
import 'persistence/isar/workout_summary.dart';
import 'utils/address_names.dart';
import 'utils/init_preferences.dart';
import 'utils/logging.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final byteData = await rootBundle.load('assets/timezones_10y.tzf');
    tz.initializeDatabase(byteData.buffer.asUint8List());

    final prefService = await initPreferences();
    String dbLocation = prefService.get<String>(databaseLocationTag) ?? databaseLocationDefault;
    if (dbLocation.isEmpty) {
      final dbDirectory = await getApplicationDocumentsDirectory();
      dbLocation = dbDirectory.path;
    }

    final isar = await Isar.open([
      ActivitySchema,
      CalorieTuneSchema,
      DeviceUsageSchema,
      FloorMigrationSchema,
      FloorRecordMigrationSchema,
      LogEntrySchema,
      PowerTuneSchema,
      RecordSchema,
      WorkoutSummarySchema,
    ], directory: dbLocation);
    Get.put<Isar>(isar, permanent: true);

    final companyRegistry = CompanyRegistry();
    await companyRegistry.loadCompanyIdentifiers();
    Get.put<CompanyRegistry>(companyRegistry, permanent: true);

    Get.put<AdvertisementCache>(AdvertisementCache(), permanent: true);
    Get.put<AddressNames>(AddressNames(), permanent: true);
    Get.put<ProgressState>(ProgressState(), permanent: true);

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      Get.put<PackageInfo>(packageInfo, permanent: true);
      Logging().logVersion(packageInfo);
    });

    runApp(TrackMyIndoorExerciseApp(prefService: prefService));
  },
      (error, stack) => error is Exception
          ? Logging().logException(
              Get.isRegistered<BasePrefService>()
                  ? (Get.find<BasePrefService>().get<int>(logLevelTag) ?? logLevelDefault)
                  : logLevelDefault,
              "MAIN",
              "runZonedGuarded",
              "pacman",
              error,
              stack)
          : (error is Error
              ? Logging().log(
                  Get.isRegistered<BasePrefService>()
                      ? (Get.find<BasePrefService>().get<int>(logLevelTag) ?? logLevelDefault)
                      : logLevelDefault,
                  logLevelError,
                  "MAIN",
                  "runZonedGuarded pacman",
                  "$error; ${error.stackTrace}; $stack")
              : Logging().log(
                  Get.isRegistered<BasePrefService>()
                      ? (Get.find<BasePrefService>().get<int>(logLevelTag) ?? logLevelDefault)
                      : logLevelDefault,
                  logLevelError,
                  "MAIN",
                  "runZonedGuarded pacman",
                  error.toString())));
}
