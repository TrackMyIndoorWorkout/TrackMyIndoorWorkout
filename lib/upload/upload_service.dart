import 'package:get/get.dart';

import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import 'strava/strava_service.dart';
import 'suunto/suunto_service.dart';

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
              : Get.put<SuuntoService>(SuuntoService());
        }
      case "strava":
      default:
        {
          return Get.isRegistered<StravaService>()
              ? Get.find<StravaService>()
              : Get.put<StravaService>(StravaService());
        }
    }
  }
}
