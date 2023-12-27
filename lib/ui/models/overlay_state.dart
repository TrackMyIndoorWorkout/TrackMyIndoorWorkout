import 'package:get/get.dart';

class ProgressState {
  bool progressVisible = false;

  ProgressState({this.progressVisible = false});

  static void optionallyCloseProgress() {
    bool isProgressVisible = Get.isRegistered<ProgressState>();
    if (isProgressVisible) {
      final progressState = Get.find<ProgressState>();
      isProgressVisible = progressState.progressVisible;
    }

    if (isProgressVisible) {
      Get.close(1);
    }
  }
}
