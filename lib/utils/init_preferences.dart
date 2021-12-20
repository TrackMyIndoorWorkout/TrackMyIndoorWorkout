import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../persistence/preferences.dart';
import '../persistence/preferences_spec.dart';
import '../preferences/auto_connect.dart';
import '../preferences/device_filtering.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/generic.dart';
import '../preferences/instant_measurement_start.dart';
import '../preferences/instant_scan.dart';
import '../preferences/instant_upload.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/scan_duration.dart';
import '../preferences/simpler_ui.dart';
import '../preferences/unit_system.dart';
import 'constants.dart';

void migrateStringIntegerPreference(String tag, int defaultInt, BasePrefService prefService) {
  final valueString = prefService.get<String>(tag) ?? "$defaultInt";
  final intValue = int.tryParse(valueString);
  if (intValue != null && intValue != defaultInt) {
    prefService.set<int>(tag + intTagPostfix, intValue);
  }
}

Future<Map<String, dynamic>> getPrefDefaults() async {
  Map<String, dynamic> prefDefaults = {
    preferencesVersionTag: preferencesVersionNext,
    unitSystemTag: unitSystemDefault,
    distanceResolutionTag: distanceResolutionDefault,
    instantScanTag: instantScanDefault,
    scanDurationTag: scanDurationDefault,
    autoConnectTag: autoConnectDefault,
    instantMeasurementStartTag: instantMeasurementStartDefault,
    instantUploadTag: instantUploadDefault,
    simplerUiTag: await getSimplerUiDefault(),
    deviceFilteringTag: deviceFilteringDefault,
    MULTI_SPORT_DEVICE_SUPPORT_TAG: MULTI_SPORT_DEVICE_SUPPORT_DEFAULT,
    MEASUREMENT_PANELS_EXPANDED_TAG: MEASUREMENT_PANELS_EXPANDED_DEFAULT,
    MEASUREMENT_DETAIL_SIZE_TAG: MEASUREMENT_DETAIL_SIZE_DEFAULT,
    APP_DEBUG_MODE_TAG: APP_DEBUG_MODE_DEFAULT,
    DATA_CONNECTION_ADDRESSES_TAG: DATA_CONNECTION_ADDRESSES_DEFAULT,
    EXTEND_TUNING_TAG: EXTEND_TUNING_DEFAULT,
    STROKE_RATE_SMOOTHING_INT_TAG: STROKE_RATE_SMOOTHING_DEFAULT,
    DATA_STREAM_GAP_WATCHDOG_INT_TAG: DATA_STREAM_GAP_WATCHDOG_DEFAULT,
    DATA_STREAM_GAP_SOUND_EFFECT_TAG: DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT,
    CADENCE_GAP_WORKAROUND_TAG: CADENCE_GAP_WORKAROUND_DEFAULT,
    HEART_RATE_GAP_WORKAROUND_TAG: HEART_RATE_GAP_WORKAROUND_DEFAULT,
    HEART_RATE_UPPER_LIMIT_INT_TAG: HEART_RATE_UPPER_LIMIT_DEFAULT,
    HEART_RATE_LIMITING_METHOD_TAG: HEART_RATE_LIMITING_METHOD_DEFAULT,
    TARGET_HEART_RATE_MODE_TAG: TARGET_HEART_RATE_MODE_DEFAULT,
    TARGET_HEART_RATE_LOWER_BPM_INT_TAG: TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
    TARGET_HEART_RATE_UPPER_BPM_INT_TAG: TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
    TARGET_HEART_RATE_LOWER_ZONE_INT_TAG: TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
    TARGET_HEART_RATE_UPPER_ZONE_INT_TAG: TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
    TARGET_HEART_RATE_AUDIO_TAG: TARGET_HEART_RATE_AUDIO_DEFAULT,
    TARGET_HEART_RATE_AUDIO_PERIOD_INT_TAG: TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
    TARGET_HEART_RATE_SOUND_EFFECT_TAG: TARGET_HEART_RATE_SOUND_EFFECT_DEFAULT,
    AUDIO_VOLUME_INT_TAG: AUDIO_VOLUME_DEFAULT,
    LEADERBOARD_FEATURE_TAG: LEADERBOARD_FEATURE_DEFAULT,
    RANK_RIBBON_VISUALIZATION_TAG: RANK_RIBBON_VISUALIZATION_DEFAULT,
    RANKING_FOR_DEVICE_TAG: RANKING_FOR_DEVICE_DEFAULT,
    RANKING_FOR_SPORT_TAG: RANKING_FOR_SPORT_DEFAULT,
    RANK_TRACK_VISUALIZATION_TAG: RANK_TRACK_VISUALIZATION_DEFAULT,
    RANK_INFO_ON_TRACK_TAG: RANK_INFO_ON_TRACK_DEFAULT,
    THEME_SELECTION_TAG: THEME_SELECTION_DEFAULT,
    ZONE_INDEX_DISPLAY_COLORING_TAG: ZONE_INDEX_DISPLAY_COLORING_DEFAULT,
    ATHLETE_BODY_WEIGHT_INT_TAG: ATHLETE_BODY_WEIGHT_DEFAULT,
    REMEMBER_ATHLETE_BODY_WEIGHT_TAG: REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT,
    USE_HR_MONITOR_REPORTED_CALORIES_TAG: USE_HR_MONITOR_REPORTED_CALORIES_DEFAULT,
    USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG: USE_HEART_RATE_BASED_CALORIE_COUNTING_DEFAULT,
    ATHLETE_AGE_TAG: ATHLETE_AGE_DEFAULT,
    ATHLETE_GENDER_TAG: ATHLETE_GENDER_DEFAULT,
    ATHLETE_VO2MAX_TAG: ATHLETE_VO2MAX_DEFAULT,
    ENFORCED_TIME_ZONE_TAG: ENFORCED_TIME_ZONE_DEFAULT,
    DISPLAY_LAP_COUNTER_TAG: DISPLAY_LAP_COUNTER_DEFAULT,
  };
  return prefDefaults;
}

Future<BasePrefService> initPreferences() async {
  var prefDefaults = await getPrefDefaults();
  for (var sport in PreferencesSpec.sportPrefixes) {
    for (var prefSpec in PreferencesSpec.preferencesSpecs) {
      prefDefaults.addAll({
        prefSpec.thresholdTag(sport): prefSpec.thresholdDefault(sport),
        prefSpec.zonesTag(sport): prefSpec.zonesDefault(sport),
      });
    }

    prefDefaults.addAll({lastEquipmentIdTagPrefix + sport: lastEquipmentIdDefault});
    if (sport != ActivityType.ride) {
      prefDefaults.addAll(
          {PreferencesSpec.slowSpeedTag(sport): PreferencesSpec.slowSpeeds[sport].toString()});
    }
  }

  for (var prefSpec in PreferencesSpec.preferencesSpecs) {
    prefDefaults.addAll({
      "${prefSpec.metric}_${PreferencesSpec.zoneIndexDisplayTagPostfix}":
          prefSpec.indexDisplayDefault
    });
  }

  final prefService =
      await PrefServiceShared.init(prefix: preferencesPrefix, defaults: prefDefaults);
  Get.put<BasePrefService>(prefService, permanent: true);

  final prefVersion = prefService.get<int>(preferencesVersionTag) ?? preferencesVersionNext;
  if (prefVersion < preferencesVersionSportThresholds) {
    for (var prefSpec in PreferencesSpec.preferencesSpecs) {
      final thresholdTag = PreferencesSpec.thresholdPrefix + prefSpec.metric;
      var thresholdString = prefService.get<String>(thresholdTag) ?? "";
      if (prefSpec.metric == "speed") {
        final threshold = double.tryParse(thresholdString) ?? eps;
        thresholdString = decimalRound(threshold * mi2km).toString();
      }

      await prefService.set<String>(prefSpec.thresholdTag(ActivityType.ride), thresholdString);
      final zoneTag = prefSpec.metric + PreferencesSpec.zonesPostfix;
      await prefService.set<String>(
        prefSpec.zonesTag(ActivityType.ride),
        prefService.get<String>(zoneTag) ?? "55,75,90,105,120,150",
      );
    }
  }

  if (prefVersion < preferencesVersionEquipmentRemembrancePerSport) {
    final lastEquipmentId = prefService.get<String>(lastEquipmentIdTag) ?? "";
    if (lastEquipmentId.trim().isNotEmpty) {
      await prefService.set<String>(
        lastEquipmentIdTagPrefix + ActivityType.ride,
        lastEquipmentId,
      );
    }
  }

  if (prefVersion < preferencesVersionSpinners) {
    migrateStringIntegerPreference(
      STROKE_RATE_SMOOTHING_TAG,
      STROKE_RATE_SMOOTHING_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      DATA_STREAM_GAP_WATCHDOG_TAG,
      DATA_STREAM_GAP_WATCHDOG_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      HEART_RATE_UPPER_LIMIT_TAG,
      HEART_RATE_UPPER_LIMIT_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      TARGET_HEART_RATE_LOWER_BPM_TAG,
      TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      TARGET_HEART_RATE_UPPER_BPM_TAG,
      TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      TARGET_HEART_RATE_LOWER_ZONE_TAG,
      TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      TARGET_HEART_RATE_UPPER_ZONE_TAG,
      TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
      TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      AUDIO_VOLUME_TAG,
      AUDIO_VOLUME_DEFAULT,
      prefService,
    );
    migrateStringIntegerPreference(
      ATHLETE_BODY_WEIGHT_TAG,
      ATHLETE_BODY_WEIGHT_DEFAULT,
      prefService,
    );
  }

  String addressesString =
      prefService.get<String>(DATA_CONNECTION_ADDRESSES_TAG) ?? DATA_CONNECTION_ADDRESSES_DEFAULT;
  if (prefVersion < preferencesVersionDefaultingDataConnection) {
    if (addressesString == DATA_CONNECTION_ADDRESSES_OLD_DEFAULT) {
      await prefService.set<String>(
        DATA_CONNECTION_ADDRESSES_TAG,
        DATA_CONNECTION_ADDRESSES_DEFAULT,
      );
      addressesString = "";
    }
  }

  if ((prefService.get<int>(scanDurationTag) ?? scanDurationDefault) < scanDurationDefault) {
    await prefService.set<int>(scanDurationTag, scanDurationDefault);
  }

  if (prefVersion < preferencesVersionIncreaseWatchdogDefault) {
    final currentDefault = prefService.get<int>(DATA_STREAM_GAP_WATCHDOG_INT_TAG);
    if (currentDefault == DATA_STREAM_GAP_WATCHDOG_OLD_DEFAULT) {
      await prefService.set<int>(
          DATA_STREAM_GAP_WATCHDOG_INT_TAG, DATA_STREAM_GAP_WATCHDOG_DEFAULT);
    }
  }

  await prefService.set<int>(preferencesVersionTag, preferencesVersionNext);

  for (var sport in PreferencesSpec.sportPrefixes) {
    if (sport != ActivityType.ride) {
      final slowSpeedString = prefService.get<String>(PreferencesSpec.slowSpeedTag(sport)) ?? "";
      PreferencesSpec.slowSpeeds[sport] = double.tryParse(slowSpeedString) ?? eps;
    }
  }

  return prefService;
}
