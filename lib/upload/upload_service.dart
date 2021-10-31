import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import 'strava/constants.dart';
import 'strava/strava_service.dart';
import 'suunto/constants.dart';
import 'suunto/suunto_service.dart';
import 'training_peaks/constants.dart';
import 'training_peaks/training_peaks_service.dart';
import 'under_armour/constants.dart';
import 'under_armour/under_armour_service.dart';
import 'constants.dart';

abstract class UploadService {
  Future<bool> login();

  Future<bool> hasValidToken();

  Future<int> logout();

  Future<int> upload(Activity activity, List<Record> records);

  static UploadService getInstance(String portalType) {
    switch (portalType) {
      case suuntoChoice:
        {
          return Get.isRegistered<SuuntoService>()
              ? Get.find<SuuntoService>()
              : Get.put<SuuntoService>(SuuntoService(), permanent: true);
        }
      case underArmourChoice:
        {
          return Get.isRegistered<UnderArmourService>()
              ? Get.find<UnderArmourService>()
              : Get.put<UnderArmourService>(UnderArmourService(), permanent: true);
        }
      case trainingPeaksChoice:
        {
          return Get.isRegistered<TrainingPeaksService>()
              ? Get.find<TrainingPeaksService>()
              : Get.put<TrainingPeaksService>(TrainingPeaksService(), permanent: true);
        }
      case stravaChoice:
      default:
        {
          return Get.isRegistered<StravaService>()
              ? Get.find<StravaService>()
              : Get.put<StravaService>(StravaService(), permanent: true);
        }
    }
  }

  static bool isIntegrationEnabled(String portalType) {
    final prefService = Get.find<BasePrefService>();
    switch (portalType) {
      case suuntoChoice:
        {
          return prefService.get<String>(SUUNTO_ACCESS_TOKEN_TAG)?.isNotEmpty ?? false;
        }
      case underArmourChoice:
        {
          return prefService.get<String>(UNDER_ARMOUR_ACCESS_TOKEN_TAG)?.isNotEmpty ?? false;
        }
      case trainingPeaksChoice:
        {
          return prefService.get<String>(TRAINING_PEAKS_ACCESS_TOKEN_TAG)?.isNotEmpty ?? false;
        }
      case stravaChoice:
      default:
        {
          return prefService.get<String>(STRAVA_ACCESS_TOKEN_TAG)?.isNotEmpty ?? false;
        }
    }
  }
}
