import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_my_indoor_exercise/upload/background/upload_queue.dart';
import 'package:track_my_indoor_exercise/upload/background/workmanager_dispatcher.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/secure_token_storage.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  group('Workmanager dispatcher tests', () {
    test('constants have expected values', () {
      expect(backgroundUploadTaskKey, equals("com.trackmyindoorworkout.background_upload"));
      expect(maxBackgroundUploadAttempts, equals(5));
    });

    test('ensureBackgroundServicesInitialized registers BasePrefService, PackageInfo, and SecureTokenStorage', () async {
      expect(Get.isRegistered<BasePrefService>(), isFalse);
      expect(Get.isRegistered<PackageInfo>(), isFalse);
      expect(Get.isRegistered<SecureTokenStorage>(), isFalse);

      await ensureBackgroundServicesInitialized();

      expect(Get.isRegistered<BasePrefService>(), isTrue);
      expect(Get.isRegistered<PackageInfo>(), isTrue);
      expect(Get.isRegistered<SecureTokenStorage>(), isTrue);
    });

    test('executeBackgroundUploadTask returns true when queue is empty', () async {
      final queue = BackgroundUploadQueue();
      expect(await queue.getItems(), isEmpty);

      final result = await executeBackgroundUploadTask(queueOverride: queue);
      expect(result, isTrue);
    });

    test('executeBackgroundUploadTask drops items that exceeded max attempts', () async {
      final queue = BackgroundUploadQueue();
      await queue.enqueue(42, stravaChoice);

      // Simulate 5 prior failed attempts
      for (int i = 0; i < maxBackgroundUploadAttempts; i++) {
        await queue.recordAttempt(42, stravaChoice, "HTTP 500");
      }

      var items = await queue.getItems();
      expect(items.length, equals(1));
      expect(items.first.attempts, equals(5));

      final result = await executeBackgroundUploadTask(queueOverride: queue);
      expect(result, isTrue);

      // Verify the item was dequeued / dropped
      expect(await queue.hasPendingUploads(), isFalse);
    });
  });
}
