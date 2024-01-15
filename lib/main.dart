import 'dart:async';
import 'dart:developer';

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
    log("WidgetsFlutterBinding.ensureInitialized");
    WidgetsFlutterBinding.ensureInitialized();

    log("rootBundle.load");
    final byteData = await rootBundle.load('assets/timezones_10y.tzf');
    log("tz.initializeDatabase");
    tz.initializeDatabase(byteData.buffer.asUint8List());

    log("initPreferences");
    final prefService = await initPreferences();
    log("dbLocation...");
    String dbLocation = prefService.get<String>(databaseLocationTag) ?? databaseLocationDefault;
    log("dbLocation: $dbLocation");
    if (dbLocation.isEmpty) {
      log("dbLocation.isEmpty");
      final dbDirectory = await getApplicationDocumentsDirectory();
      dbLocation = dbDirectory.path;
      log("dbLocation: $dbLocation");
    }

    log("Isar.open");
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
    log("Get.put<Isar>");
    Get.put<Isar>(isar, permanent: true);

    final companyRegistry = CompanyRegistry();
    log("companyRegistry.loadCompanyIdentifiers");
    await companyRegistry.loadCompanyIdentifiers();
    log("Get.put<CompanyRegistry>");
    Get.put<CompanyRegistry>(companyRegistry, permanent: true);

    log("Get.put<AdvertisementCache>");
    Get.put<AdvertisementCache>(AdvertisementCache(), permanent: true);
    log("Get.put<AddressNames>");
    Get.put<AddressNames>(AddressNames(), permanent: true);
    log("Get.put<ProgressState>");
    Get.put<ProgressState>(ProgressState(), permanent: true);

    log("PackageInfo.fromPlatform()");
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      log("Get.put<PackageInfo>");
      Get.put<PackageInfo>(packageInfo, permanent: true);
      log("Logging().logVersion");
      Logging().logVersion(packageInfo);
    });

    log("runApp");
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
