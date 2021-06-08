import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/persistence/preferences.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

const SMALL_REPETITION = 10;
const REPETITION = 50;

const SPORTS = [
  ActivityType.Ride,
  ActivityType.Run,
  ActivityType.Kayaking,
  ActivityType.Canoeing,
  ActivityType.Rowing,
  ActivityType.Swim,
  ActivityType.Elliptical,
];

extension RangeExtension on int {
  List<int> to(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

List<int> getRandomInts(int count, int max, Random source) {
  return List<int>.generate(count, (index) => source.nextInt(max));
}

List<double> getRandomDoubles(int count, double max, Random source) {
  return List<double>.generate(count, (index) => source.nextDouble() * max);
}

String getRandomSport() {
  return SPORTS[Random().nextInt(SPORTS.length)];
}

class ExportModelForTests extends ExportModel {
  ExportModelForTests({
    sport,
    totalDistance,
    totalTime,
    calories,
    dateActivity,
    descriptor,
    deviceId,
    versionMajor,
    versionMinor,
    buildMajor,
    buildMinor,
    author,
    name,
    swVersionMajor,
    swVersionMinor,
    buildVersionMajor,
    buildVersionMinor,
    langID,
    partNumber,
    records,
  }) : super(
    sport: sport ?? ActivityType.Ride,
    totalDistance: totalDistance ?? 0.0,
    totalTime: totalTime ?? 0,
    calories: calories ?? 0,
    dateActivity: dateActivity ?? DateTime.now(),
    descriptor: descriptor ?? deviceMap["SAP+"]!,
    deviceId: deviceId ?? MPOWER_IMPORT_DEVICE_ID,
    versionMajor: versionMajor ?? 1,
    versionMinor: versionMinor ?? 0,
    buildMajor: buildMajor ?? 1,
    buildMinor: buildMinor ?? 0,
    author: author ?? 'Csaba Consulting',
    name: name ?? 'Track My Indoor Exercise',
    swVersionMajor: swVersionMajor ?? 1,
    swVersionMinor: swVersionMinor ?? 0,
    buildVersionMajor: buildVersionMajor ?? 1,
    buildVersionMinor: buildVersionMinor ?? 0,
    langID: langID ?? 'en-US',
    partNumber: partNumber ?? '0',
    records: records ?? [],
  );
}

Future<void> initPrefServiceForTest() async {
  Map<String, dynamic> prefDefaults = {
    PREFERENCES_VERSION_TAG: PREFERENCES_VERSION_NEXT,
    UNIT_SYSTEM_TAG: UNIT_SYSTEM_DEFAULT,
    INSTANT_SCAN_TAG: INSTANT_SCAN_DEFAULT,
    SCAN_DURATION_TAG: SCAN_DURATION_DEFAULT,
    AUTO_CONNECT_TAG: AUTO_CONNECT_DEFAULT,
    INSTANT_MEASUREMENT_START_TAG: INSTANT_MEASUREMENT_START_DEFAULT,
    INSTANT_UPLOAD_TAG: INSTANT_UPLOAD_DEFAULT,
    SIMPLER_UI_TAG: await getSimplerUiDefault(),
    DEVICE_FILTERING_TAG: DEVICE_FILTERING_DEFAULT,
    MULTI_SPORT_DEVICE_SUPPORT_TAG: MULTI_SPORT_DEVICE_SUPPORT_DEFAULT,
    MEASUREMENT_PANELS_EXPANDED_TAG: MEASUREMENT_PANELS_EXPANDED_DEFAULT,
    MEASUREMENT_DETAIL_SIZE_TAG: MEASUREMENT_DETAIL_SIZE_DEFAULT,
    APP_DEBUG_MODE_TAG: APP_DEBUG_MODE_DEFAULT,
    EXTEND_TUNING_TAG: EXTEND_TUNING_DEFAULT,
    STROKE_RATE_SMOOTHING_TAG: STROKE_RATE_SMOOTHING_DEFAULT,
    DATA_STREAM_GAP_WATCHDOG_TAG: DATA_STREAM_GAP_WATCHDOG_DEFAULT,
    DATA_STREAM_GAP_SOUND_EFFECT_TAG: DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT,
    CADENCE_GAP_WORKAROUND_TAG: CADENCE_GAP_WORKAROUND_DEFAULT,
    HEART_RATE_GAP_WORKAROUND_TAG: HEART_RATE_GAP_WORKAROUND_DEFAULT,
    HEART_RATE_UPPER_LIMIT_TAG: HEART_RATE_UPPER_LIMIT_DEFAULT,
    HEART_RATE_LIMITING_METHOD_TAG: HEART_RATE_LIMITING_METHOD_DEFAULT,
    TARGET_HEART_RATE_MODE_TAG: TARGET_HEART_RATE_MODE_DEFAULT,
    TARGET_HEART_RATE_LOWER_BPM_TAG: TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
    TARGET_HEART_RATE_UPPER_BPM_TAG: TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
    TARGET_HEART_RATE_LOWER_ZONE_TAG: TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
    TARGET_HEART_RATE_UPPER_ZONE_TAG: TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
    TARGET_HEART_RATE_AUDIO_TAG: TARGET_HEART_RATE_AUDIO_DEFAULT,
    TARGET_HEART_RATE_AUDIO_PERIOD_TAG: TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
    TARGET_HEART_RATE_SOUND_EFFECT_TAG: TARGET_HEART_RATE_SOUND_EFFECT_DEFAULT,
    AUDIO_VOLUME_TAG: AUDIO_VOLUME_DEFAULT,
    LEADERBOARD_FEATURE_TAG: LEADERBOARD_FEATURE_DEFAULT,
    RANK_RIBBON_VISUALIZATION_TAG: RANK_RIBBON_VISUALIZATION_DEFAULT,
    RANKING_FOR_DEVICE_TAG: RANKING_FOR_DEVICE_DEFAULT,
    RANKING_FOR_SPORT_TAG: RANKING_FOR_SPORT_DEFAULT,
    RANK_TRACK_VISUALIZATION_TAG: RANK_TRACK_VISUALIZATION_DEFAULT,
    RANK_INFO_ON_TRACK_TAG: RANK_INFO_ON_TRACK_DEFAULT,
    THEME_SELECTION_TAG: THEME_SELECTION_DEFAULT,
    ZONE_INDEX_DISPLAY_COLORING_TAG: ZONE_INDEX_DISPLAY_COLORING_DEFAULT,
    ATHLETE_BODY_WEIGHT_TAG: ATHLETE_BODY_WEIGHT_DEFAULT,
    REMEMBER_ATHLETE_BODY_WEIGHT_TAG: REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT,
  };
  final prefService =
      await PrefServiceShared.init(prefix: PREFERENCES_PREFIX, defaults: prefDefaults);
  Get.put<PrefServiceShared>(prefService);
}
