import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'devices/company_registry.dart';
import 'track_my_indoor_exercise_app.dart';
import 'ui/models/advertisement_cache.dart';
import 'utils/init_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await initPreferences();

  final companyRegistry = CompanyRegistry();
  // TODO: fully async this
  await companyRegistry.loadCompanyIdentifiers();
  Get.put<CompanyRegistry>(companyRegistry, permanent: true);

  Get.put<AdvertisementCache>(AdvertisementCache(), permanent: true);

  // TODO: move it to about and CSV on demand
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    Get.put<PackageInfo>(packageInfo, permanent: true);
  });

  runApp(
    ProviderScope(
      child: TrackMyIndoorExerciseApp(prefService: prefService),
    ),
  );
}
