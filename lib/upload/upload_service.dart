import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks_service.dart';

import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import 'strava/strava_service.dart';
import 'suunto/suunto_service.dart';
import 'under_armour/under_armour_service.dart';

abstract class UploadService {
  Future<bool> login();

  Future<bool> hasValidToken();

  Future<int> deAuthorize();

  Future<int> upload(Activity activity, List<Record> records);

  static UploadService getInstance(String portalType) {
    switch (portalType.toLowerCase()) {
      case "suunto":
        {
          return Get.isRegistered<SuuntoService>()
              ? Get.find<SuuntoService>()
              : Get.put<SuuntoService>(SuuntoService(), permanent: true);
        }
      case "mapmyfitness":
        {
          return Get.isRegistered<UnderArmourService>()
              ? Get.find<UnderArmourService>()
              : Get.put<UnderArmourService>(UnderArmourService(), permanent: true);
        }
      case "trainingpeaks":
        {
          return Get.isRegistered<TrainingPeaksService>()
              ? Get.find<TrainingPeaksService>()
              : Get.put<TrainingPeaksService>(TrainingPeaksService(), permanent: true);
        }
      case "strava":
      default:
        {
          return Get.isRegistered<StravaService>()
              ? Get.find<StravaService>()
              : Get.put<StravaService>(StravaService(), permanent: true);
        }
    }
  }
}
