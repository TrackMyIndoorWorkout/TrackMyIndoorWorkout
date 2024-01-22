import 'package:get/get.dart';

class ProgressState {
  int progressCount = 0;

  ProgressState({this.progressCount = 0});

  static void optionallyCloseProgress() {
    if (!Get.isRegistered<ProgressState>()) {
      return;
    }

    final progressState = Get.find<ProgressState>();
    if (progressState.progressCount > 0) {
      Get.close(progressState.progressCount);
    }

    Get.put<ProgressState>(progressState);
  }
}
