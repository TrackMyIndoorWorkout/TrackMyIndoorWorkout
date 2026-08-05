import 'package:get/get.dart';

import '../persistence/activity.dart';
import 'constants.dart';
import 'strava/strava_service.dart';
import 'suunto/suunto_service.dart';
import 'training_peaks/training_peaks_service.dart';
import 'under_armour/under_armour_service.dart';

abstract class UploadService {
  Future<bool> login();

  Future<bool> hasValidToken();

  Future<int> logout();

  Future<int> upload(Activity activity, bool calculateGps);

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

  /// Whether [portalType] currently has a usable (non-empty) access token.
  ///
  /// Delegates to the portal's own [hasValidToken], which reads from the
  /// [SecureTokenStorage]-backed store (transparently migrating any value
  /// still sitting in the legacy `pref`/`shared_preferences` store). This
  /// must stay async since secure storage access is inherently async - do
  /// not reintroduce a synchronous legacy-only read here.
  static Future<bool> isIntegrationEnabled(String portalType) {
    return getInstance(portalType).hasValidToken();
  }
}
