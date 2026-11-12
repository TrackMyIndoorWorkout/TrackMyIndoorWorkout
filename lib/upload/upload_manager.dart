import 'package:get/get.dart';
import 'package:isar_community/isar.dart';

import '../persistence/activity.dart';
import '../preferences/log_level.dart';
import '../utils/logging.dart';
import 'constants.dart';
import 'strava/strava_status_code.dart';
import 'upload_service.dart';

enum UploadStatus { idle, uploading, success, failed }

class UploadManager extends GetxService {
  static UploadManager get instance => Get.isRegistered<UploadManager>()
      ? Get.find<UploadManager>()
      : Get.put<UploadManager>(UploadManager(), permanent: true);

  UploadService Function(String portalName) serviceResolver;

  UploadManager({UploadService Function(String portalName)? serviceResolver})
    : serviceResolver = serviceResolver ?? UploadService.getInstance;

  /// Key format: "${activityId}_$portalName"
  final RxMap<String, UploadStatus> _portalStatus = <String, UploadStatus>{}.obs;

  static String _key(int activityId, String portalName) => '${activityId}_$portalName';

  UploadStatus getStatus(int activityId, String portalName) =>
      _portalStatus[_key(activityId, portalName)] ?? UploadStatus.idle;

  bool isUploading(int activityId, [String? portalName]) {
    if (portalName != null) {
      return getStatus(activityId, portalName) == UploadStatus.uploading;
    }
    final prefix = '${activityId}_';
    return _portalStatus.entries.any(
      (e) => e.key.startsWith(prefix) && e.value == UploadStatus.uploading,
    );
  }

  /// Observable access to the status map for reactive UI widgets.
  RxMap<String, UploadStatus> get statusMap => _portalStatus;

  /// Uploads [activity] to [portalName].
  ///
  /// Runs asynchronously without blocking the UI thread or holding local widget state.
  /// Notifies the user via [Get.snackbar] and updates observable status.
  Future<bool> uploadActivity(
    Activity activity,
    String portalName, {
    bool calculateGps = false,
    bool showNotification = true,
  }) async {
    final key = _key(activity.id, portalName);
    if (_portalStatus[key] == UploadStatus.uploading) {
      // Upload is already in flight for this activity and portal
      return false;
    }

    _portalStatus[key] = UploadStatus.uploading;

    try {
      final uploadService = serviceResolver(portalName);
      final loginSuccess = await uploadService.login();
      if (!loginSuccess) {
        _portalStatus[key] = UploadStatus.failed;
        if (showNotification) {
          Get.snackbar("Warning", "$portalName login unsuccessful");
        }
        return false;
      }

      final statusCode = await uploadService.upload(activity, calculateGps);
      final success =
          statusCode == StravaStatusCode.statusOk || (statusCode >= 200 && statusCode < 300);

      _portalStatus[key] = success ? UploadStatus.success : UploadStatus.failed;

      if (showNotification) {
        final resultMessage = success
            ? "Activity ${activity.id} submitted successfully to $portalName"
            : "Activity ${activity.id} upload to $portalName failed (status: $statusCode)";
        Get.snackbar("Upload", resultMessage);
      }

      return success;
    } catch (e, stack) {
      _portalStatus[key] = UploadStatus.failed;
      if (Get.isRegistered<Isar>()) {
        Logging().logException(
          logLevelError,
          "UploadManager",
          "uploadActivity",
          portalName,
          e is Exception ? e : Exception(e.toString()),
          stack,
        );
      }
      if (showNotification) {
        Get.snackbar("Upload", "Error uploading to $portalName: $e");
      }
      return false;
    }
  }

  /// Uploads [activity] concurrently to all portals that have valid credentials.
  Future<Map<String, bool>> uploadToAllEnabled(
    Activity activity, {
    bool calculateGps = false,
  }) async {
    final results = <String, bool>{};
    final List<Future<void>> futures = [];

    for (final portalName in portalNames) {
      final isEnabled = await UploadService.isIntegrationEnabled(portalName);
      if (isEnabled) {
        futures.add(() async {
          final res = await uploadActivity(activity, portalName, calculateGps: calculateGps);
          results[portalName] = res;
        }());
      }
    }

    await Future.wait(futures);
    return results;
  }
}
