import 'package:get/get.dart';
import 'package:pref/pref.dart';

const measurementPanelsExpandedTag = "measurement_panels_expanded";
const measurementPanelsExpandedDefault = "00001";

Future<void> applyExpandedStates(List<bool> expandedState) async {
  final expandedStateStr = List<String>.generate(
    expandedState.length,
    (index) => expandedState[index] ? "1" : "0",
  ).join("");
  final prefService = Get.find<BasePrefService>();
  await prefService.set<String>(measurementPanelsExpandedTag, expandedStateStr);
}

// 0: 1/4, 1: 1/3, 2: 1/2
const measurementDetailSizeTag = "measurement_detail_size";
const measurementDetailSizeDefault = "00000";

Future<void> applyDetailSizes(List<int> expandedHeights) async {
  final expandedHeightStr = List<String>.generate(
    expandedHeights.length,
    (index) => expandedHeights[index].toString(),
  ).join("");
  final prefService = Get.find<BasePrefService>();
  prefService.set<String>(measurementDetailSizeTag, expandedHeightStr);
}
