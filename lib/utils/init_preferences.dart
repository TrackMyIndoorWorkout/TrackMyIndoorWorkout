import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../preferences/app_debug_mode.dart';
import '../preferences/athlete_age.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/athlete_gender.dart';
import '../preferences/athlete_vo2max.dart';
import '../preferences/audio_volume.dart';
import '../preferences/auto_connect.dart';
import '../preferences/cadence_data_gap_workaround.dart';
import '../preferences/data_connection_addresses.dart';
import '../preferences/data_stream_gap_sound_effect.dart';
import '../preferences/data_stream_gap_watchdog_time.dart';
import '../preferences/device_filtering.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/enforced_time_zone.dart';
import '../preferences/extend_tuning.dart';
import '../preferences/generic.dart';
import '../preferences/heart_rate_gap_workaround.dart';
import '../preferences/heart_rate_limiting.dart';
import '../preferences/instant_measurement_start.dart';
import '../preferences/instant_scan.dart';
import '../preferences/instant_upload.dart';
import '../preferences/lap_counter.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/measurement_ui_state.dart';
import '../preferences/moving_or_elapsed_time.dart';
import '../preferences/multi_sport_device_support.dart';
import '../preferences/preferences_spec.dart';
import '../preferences/scan_duration.dart';
import '../preferences/simpler_ui.dart';
import '../preferences/stroke_rate_smoothing.dart';
import '../preferences/target_heart_rate.dart';
import '../preferences/theme_selection.dart';
import '../preferences/training_peaks_upload_public.dart';
import '../preferences/two_column_layout.dart';
import '../preferences/unit_system.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
import '../preferences/use_hr_monitor_reported_calories.dart';
import '../preferences/zone_index_display_coloring.dart';
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
    multiSportDeviceSupportTag: multiSportDeviceSupportDefault,
    measurementPanelsExpandedTag: measurementPanelsExpandedDefault,
    measurementDetailSizeTag: measurementDetailSizeDefault,
    appDebugModeTag: appDebugModeDefault,
    dataConnectionAddressesTag: dataConnectionAddressesDefault,
    extendTuningTag: extendTuningDefault,
    strokeRateSmoothingIntTag: strokeRateSmoothingDefault,
    dataStreamGapWatchdogIntTag: dataStreamGapWatchdogDefault,
    dataStreamGapSoundEffectTag: dataStreamGapSoundEffectDefault,
    cadenceGapWorkaroundTag: cadenceGapWorkaroundDefault,
    heartRateGapWorkaroundTag: heartRateGapWorkaroundDefault,
    heartRateUpperLimitIntTag: heartRateUpperLimitDefault,
    heartRateLimitingMethodTag: heartRateLimitingMethodDefault,
    targetHeartRateModeTag: targetHeartRateModeDefault,
    targetHeartRateLowerBpmIntTag: targetHeartRateLowerBpmDefault,
    targetHeartRateUpperBpmIntTag: targetHeartRateUpperBpmDefault,
    targetHeartRateLowerZoneIntTag: targetHeartRateLowerZoneDefault,
    targetHeartRateUpperZoneIntTag: targetHeartRateUpperZoneDefault,
    targetHeartRateAudioTag: targetHeartRateAudioDefault,
    targetHeartRateAudioPeriodIntTag: targetHeartRateAudioPeriodDefault,
    targetHeartRateSoundEffectTag: targetHeartRateSoundEffectDefault,
    audioVolumeIntTag: audioVolumeDefault,
    leaderboardFeatureTag: leaderboardFeatureDefault,
    rankRibbonVisualizationTag: rankRibbonVisualizationDefault,
    rankingForDeviceTag: rankingForDeviceDefault,
    rankingForSportTag: rankingForSportDefault,
    rankTrackVisualizationTag: rankTrackVisualizationDefault,
    rankInfoOnTrackTag: rankInfoOnTrackDefault,
    themeSelectionTag: themeSelectionDefault,
    zoneIndexDisplayColoringTag: zoneIndexDisplayColoringDefault,
    athleteBodyWeightIntTag: athleteBodyWeightDefault,
    rememberAthleteBodyWeightTag: rememberAthleteBodyWeightDefault,
    useHrMonitorReportedCaloriesTag: useHrMonitorReportedCaloriesDefault,
    useHeartRateBasedCalorieCountingTag: useHeartRateBasedCalorieCountingDefault,
    athleteAgeTag: athleteAgeDefault,
    athleteGenderTag: athleteGenderDefault,
    athleteVO2MaxTag: athleteVO2MaxDefault,
    enforcedTimeZoneTag: enforcedTimeZoneDefault,
    displayLapCounterTag: displayLapCounterDefault,
    measurementFontSizeAdjustTag: measurementFontSizeAdjustDefault,
    twoColumnLayoutTag: twoColumnLayoutDefault,
    movingOrElapsedTimeTag: movingOrElapsedTimeDefault,
    trainingPeaksUploadPublicTag: trainingPeaksUploadPublicDefault,
  };

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

  return prefDefaults;
}

Future<BasePrefService> initPreferences() async {
  var prefDefaults = await getPrefDefaults();
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
      strokeRateSmoothingTag,
      strokeRateSmoothingDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      dataStreamGapWatchdogTag,
      dataStreamGapWatchdogDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      heartRateUpperLimitTag,
      heartRateUpperLimitDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      targetHeartRateLowerBpmTag,
      targetHeartRateLowerBpmDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      targetHeartRateUpperBpmTag,
      targetHeartRateUpperBpmDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      targetHeartRateLowerZoneTag,
      targetHeartRateLowerZoneDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      targetHeartRateUpperZoneTag,
      targetHeartRateUpperZoneDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      targetHeartRateAudioPeriodTag,
      targetHeartRateAudioPeriodDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      audioVolumeTag,
      audioVolumeDefault,
      prefService,
    );
    migrateStringIntegerPreference(
      athleteBodyWeightTag,
      athleteBodyWeightDefault,
      prefService,
    );
  }

  String addressesString =
      prefService.get<String>(dataConnectionAddressesTag) ?? dataConnectionAddressesDefault;
  if (prefVersion < preferencesVersionDefaultingDataConnection) {
    if (addressesString == dataConnectionAddressesOldDefault) {
      await prefService.set<String>(
        dataConnectionAddressesTag,
        dataConnectionAddressesDefault,
      );
      addressesString = "";
    }
  }

  if ((prefService.get<int>(scanDurationTag) ?? scanDurationDefault) < scanDurationDefault) {
    await prefService.set<int>(scanDurationTag, scanDurationDefault);
  }

  if (prefVersion < preferencesVersionIncreaseWatchdogDefault) {
    final currentDefault = prefService.get<int>(dataStreamGapWatchdogIntTag);
    if (currentDefault == dataStreamGapWatchdogOldDefault) {
      await prefService.set<int>(dataStreamGapWatchdogIntTag, dataStreamGapWatchdogDefault);
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
