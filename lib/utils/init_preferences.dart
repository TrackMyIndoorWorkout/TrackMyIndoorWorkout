import 'dart:io';

import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pref/pref.dart';
import '../persistence/preferences.dart';
import 'constants.dart';
import 'preferences.dart';

Future<BasePrefService> initPreferences() async {
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
  PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
    PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
      prefDefaults.addAll({
        prefSpec.thresholdTag(sport): prefSpec.thresholdDefault(sport),
        prefSpec.zonesTag(sport): prefSpec.zonesDefault(sport),
      });
    });
    prefDefaults.addAll({LAST_EQUIPMENT_ID_TAG_PREFIX + sport: LAST_EQUIPMENT_ID_DEFAULT});
    if (sport != ActivityType.Ride) {
      prefDefaults.addAll(
          {PreferencesSpec.slowSpeedTag(sport): PreferencesSpec.slowSpeeds[sport].toString()});
    }
  });
  PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
    prefDefaults.addAll({
      "${prefSpec.metric}_${PreferencesSpec.ZONE_INDEX_DISPLAY_TAG_POSTFIX}":
          prefSpec.indexDisplayDefault
    });
  });

  final prefService =
      await PrefServiceShared.init(prefix: PREFERENCES_PREFIX, defaults: prefDefaults);
  Get.put<PrefServiceShared>(prefService);

  final prefVersion =
      prefService.sharedPreferences.getInt(PREFERENCES_VERSION_TAG) ?? PREFERENCES_VERSION_NEXT;
  if (prefVersion < PREFERENCES_VERSION_SPORT_THRESHOLDS) {
    PreferencesSpec.preferencesSpecs.forEach((prefSpec) async {
      final thresholdTag = PreferencesSpec.THRESHOLD_PREFIX + prefSpec.metric;
      var thresholdString = prefService.sharedPreferences.getString(thresholdTag) ?? "";
      if (prefSpec.metric == "speed") {
        final threshold = double.tryParse(thresholdString) ?? EPS;
        thresholdString = decimalRound(threshold * MI2KM).toString();
      }
      await prefService.sharedPreferences
          .setString(prefSpec.thresholdTag(ActivityType.Ride), thresholdString);
      final zoneTag = prefSpec.metric + PreferencesSpec.ZONES_POSTFIX;
      await prefService.sharedPreferences.setString(prefSpec.zonesTag(ActivityType.Ride),
          prefService.sharedPreferences.getString(zoneTag) ?? "55,75,90,105,120,150");
    });
  }

  if (prefVersion < PREFERENCES_VERSION_EQUIPMENT_REMEMBRANCE_PER_SPORT) {
    final lastEquipmentId = prefService.sharedPreferences.getString(LAST_EQUIPMENT_ID_TAG) ?? "";
    if (lastEquipmentId.trim().length > 0) {
      await prefService.sharedPreferences
          .setString(LAST_EQUIPMENT_ID_TAG_PREFIX + ActivityType.Ride, lastEquipmentId);
    }
  }
  await prefService.sharedPreferences.setInt(PREFERENCES_VERSION_TAG, PREFERENCES_VERSION_NEXT);

  PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
    if (sport != ActivityType.Ride) {
      final slowSpeedString =
          prefService.sharedPreferences.getString(PreferencesSpec.slowSpeedTag(sport)) ?? "";
      PreferencesSpec.slowSpeeds[sport] = double.tryParse(slowSpeedString) ?? EPS;
    }
  });

  final addressesString = prefService.sharedPreferences.getString(DATA_CONNECTION_ADDRESSES) ?? "";
  if (addressesString.trim().isNotEmpty) {
    final addressTuples = parseIpAddresses(addressesString);
    if (addressTuples.length > 0) {
      InternetConnectionChecker().addresses = addressTuples
          .map((addressTuple) => AddressCheckOptions(
                InternetAddress(addressTuple.item1),
                port: addressTuple.item2,
              ))
          .toList(growable: false);
    }
  }

  return prefService;
}
