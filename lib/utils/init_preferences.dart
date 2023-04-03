import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/preferences/bike_color.dart';
import 'package:track_my_indoor_exercise/preferences/boat_weight.dart';
import '../preferences/air_temperature.dart';
import '../preferences/app_debug_mode.dart';
import '../preferences/athlete_age.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/athlete_gender.dart';
import '../preferences/athlete_vo2max.dart';
import '../preferences/audio_volume.dart';
import '../preferences/auto_connect.dart';
import '../preferences/bike_weight.dart';
import '../preferences/block_signal_start_stop.dart';
import '../preferences/cadence_data_gap_workaround.dart';
import '../preferences/calculate_gps.dart';
import '../preferences/data_connection_addresses.dart';
import '../preferences/data_stream_gap_sound_effect.dart';
import '../preferences/data_stream_gap_watchdog_time.dart';
import '../preferences/device_filtering.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/drag_force_tune.dart';
import '../preferences/drive_train_loss.dart';
import '../preferences/enable_asserts.dart';
import '../preferences/enforced_time_zone.dart';
import '../preferences/extend_tuning.dart';
import '../preferences/generic.dart';
import '../preferences/has_logged_messages.dart';
import '../preferences/heart_rate_gap_workaround.dart';
import '../preferences/heart_rate_limiting.dart';
import '../preferences/heart_rate_monitor_priority.dart';
import '../preferences/instant_export.dart';
import '../preferences/instant_measurement_start.dart';
import '../preferences/instant_scan.dart';
import '../preferences/instant_upload.dart';
import '../preferences/lap_counter.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/log_level.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/measurement_sink_address.dart';
import '../preferences/measurement_ui_state.dart';
import '../preferences/metric_spec.dart';
import '../preferences/multi_sport_device_support.dart';
import '../preferences/paddling_with_cycling_sensors.dart';
import '../preferences/palette_spec.dart';
import '../preferences/scan_duration.dart';
import '../preferences/simpler_ui.dart';
import '../preferences/show_pacer.dart';
import '../preferences/speed_spec.dart';
import '../preferences/sport_spec.dart';
import '../preferences/stage_mode.dart';
import '../preferences/stroke_rate_smoothing.dart';
import '../preferences/target_heart_rate.dart';
import '../preferences/theme_selection.dart';
import '../preferences/time_display_mode.dart';
import '../preferences/training_peaks_upload_public.dart';
import '../preferences/two_column_layout.dart';
import '../preferences/unit_system.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
import '../preferences/use_hr_monitor_reported_calories.dart';
import '../preferences/water_wheel_circumference.dart';
import '../preferences/welcome_presented.dart';
import '../preferences/wheel_circumference.dart';
import '../preferences/workout_mode.dart';
import '../preferences/zone_index_display_coloring.dart';
import '../utils/logging.dart';
import '../utils/preferences.dart';
import '../utils/time_zone.dart';
import 'constants.dart';

Future<void> migrateStringIntegerPreference(
    String tag, int defaultInt, BasePrefService prefService) async {
  final valueString = prefService.get<String>(tag) ?? "$defaultInt";
  final intValue = int.tryParse(valueString);
  if (intValue != null && intValue != defaultInt) {
    await prefService.set<int>(tag + intTagPostfix, intValue);
  }
}

Future<Map<String, dynamic>> getPrefDefaults() async {
  Map<String, dynamic> prefDefaults = {
    preferencesVersionTag: preferencesVersionNext,
    unitSystemTag: getUnitSystemDefault(),
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
    measurementSinkAddressTag: measurementSinkAddressDefault,
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
    rankingForSportOrDeviceTag: rankingForSportOrDeviceDefault,
    rankTrackVisualizationTag: rankTrackVisualizationDefault,
    rankInfoOnTrackTag: rankInfoOnTrackDefault,
    themeSelectionTag: themeSelectionDefault,
    athleteBodyWeightIntTag: athleteBodyWeightDefault,
    useHrMonitorReportedCaloriesTag: useHrMonitorReportedCaloriesDefault,
    useHeartRateBasedCalorieCountingTag: useHeartRateBasedCalorieCountingDefault,
    athleteAgeTag: athleteAgeDefault,
    athleteGenderTag: athleteGenderDefault,
    athleteVO2MaxTag: athleteVO2MaxDefault,
    enforcedTimeZoneTag: enforcedTimeZoneDefault,
    displayLapCounterTag: displayLapCounterDefault,
    measurementFontSizeAdjustTag: measurementFontSizeAdjustDefault,
    twoColumnLayoutTag: twoColumnLayoutDefault,
    trainingPeaksUploadPublicTag: trainingPeaksUploadPublicDefault,
    logLevelTag: logLevelDefault,
    calculateGpsTag: calculateGpsDefault,
    avgSpeedOnTrackTag: avgSpeedOnTrackDefault,
    showPacerTag: showPacerDefault,
    workoutModeTag: workoutModeDefault,
    bikeWeightTag: bikeWeightDefault,
    driveTrainLossTag: driveTrainLossDefault,
    airTemperatureTag: airTemperatureDefault,
    blockSignalStartStopTag: blockSignalStartStopDefault,
    timeDisplayModeTag: timeDisplayModeDefault,
    welcomePresentedTag: welcomePresentedDefault,
    hasLoggedMessagesTag: hasLoggedMessagesDefault,
    instantExportTag: instantExportDefault,
    instantExportLocationTag: instantExportLocationDefault,
    enableAssertsTag: enableAssertsDefault,
    dragForceTuneTag: dragForceTuneDefault,
    heartRateMonitorPriorityTag: heartRateMonitorPriorityDefault,
    wheelCircumferenceTag: wheelCircumferenceDefault,
    waterWheelCircumferenceTag: waterWheelCircumferenceDefault,
    paddlingWithCyclingSensorsTag: paddlingWithCyclingSensorsDefault,
    instantOnStageTag: instantOnStageDefault,
    onStageStatisticsTypeTag: onStageStatisticsTypeDefault,
    onStageStatisticsAlternationPeriodTag: onStageStatisticsAlternationPeriodDefault,
    averageChartColorTag: averageChartColorDefault,
    maximumChartColorTag: maximumChartColorDefault,
    boatWeightTag: boatWeightDefault,
    bikeColorOnConsoleTag: bikeColorOnConsoleDefault,
  };

  for (var sport in SportSpec.sportPrefixes) {
    for (var prefSpec in MetricSpec.preferencesSpecs) {
      prefDefaults.addAll({
        prefSpec.thresholdTag(sport): prefSpec.thresholdDefault(sport),
        prefSpec.zonesTag(sport): prefSpec.zonesDefault(sport),
      });
    }

    prefDefaults.addAll({lastEquipmentIdTagPrefix + sport: lastEquipmentIdDefault});
    if (sport != ActivityType.ride) {
      prefDefaults
          .addAll({SpeedSpec.slowSpeedTag(sport): SpeedSpec.slowSpeedDefaults[sport].toString()});
    }

    prefDefaults
        .addAll({SpeedSpec.pacerSpeedTag(sport): SpeedSpec.pacerSpeedDefaults[sport].toString()});
  }

  for (var prefSpec in MetricSpec.preferencesSpecs) {
    prefDefaults.addAll({prefSpec.zoneIndexTag: prefSpec.indexDisplayDefault});
    prefDefaults.addAll({prefSpec.coloringByZoneTag: prefSpec.coloringByZoneDefault});
  }

  for (final lightOrDark in [false, true]) {
    for (final fgOrBg in [false, true]) {
      for (final paletteSize in [5, 6, 7]) {
        prefDefaults.addAll({
          PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize):
              PaletteSpec.getDefaultPaletteString(lightOrDark, fgOrBg, paletteSize)
        });
      }
    }
  }

  return prefDefaults;
}

Future<BasePrefService> initPreferences() async {
  var prefDefaults = await getPrefDefaults();
  final prefService =
      await PrefServiceShared.init(prefix: preferencesPrefix, defaults: prefDefaults);
  Get.put<BasePrefService>(prefService, permanent: true);

  final prefVersion = prefService.get<int>(preferencesVersionTag) ?? preferencesVersionNext;
  if (prefVersion <= preferencesVersionSportThresholds) {
    for (var prefSpec in MetricSpec.preferencesSpecs) {
      final thresholdTag = MetricSpec.thresholdPrefix + prefSpec.metric;
      var thresholdString = prefService.get<String>(thresholdTag) ?? "";
      if (prefSpec.metric == "speed") {
        final threshold = double.tryParse(thresholdString) ?? eps;
        thresholdString = decimalRound(threshold * mi2km).toString();
      }

      await prefService.set<String>(prefSpec.thresholdTag(ActivityType.ride), thresholdString);
      final zoneTag = prefSpec.metric + MetricSpec.zonesPostfix;
      await prefService.set<String>(
        prefSpec.zonesTag(ActivityType.ride),
        prefService.get<String>(zoneTag) ?? MetricSpec.veryOldZoneBoundaries,
      );
    }
  }

  if (prefVersion <= preferencesVersionEquipmentRemembrancePerSport) {
    final lastEquipmentId = prefService.get<String>(lastEquipmentIdTag) ?? "";
    if (lastEquipmentId.trim().isNotEmpty) {
      await prefService.set<String>(
        lastEquipmentIdTagPrefix + ActivityType.ride,
        lastEquipmentId,
      );
    }
  }

  if (prefVersion <= preferencesVersionSpinners) {
    await migrateStringIntegerPreference(
      strokeRateSmoothingTag,
      strokeRateSmoothingDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      dataStreamGapWatchdogTag,
      dataStreamGapWatchdogDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      heartRateUpperLimitTag,
      heartRateUpperLimitDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      targetHeartRateLowerBpmTag,
      targetHeartRateLowerBpmDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      targetHeartRateUpperBpmTag,
      targetHeartRateUpperBpmDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      targetHeartRateLowerZoneTag,
      targetHeartRateLowerZoneDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      targetHeartRateUpperZoneTag,
      targetHeartRateUpperZoneDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      targetHeartRateAudioPeriodTag,
      targetHeartRateAudioPeriodDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      audioVolumeTag,
      audioVolumeDefault,
      prefService,
    );
    await migrateStringIntegerPreference(
      athleteBodyWeightTag,
      athleteBodyWeightDefault,
      prefService,
    );
  }

  String addressesString =
      prefService.get<String>(dataConnectionAddressesTag) ?? dataConnectionAddressesDefault;
  if (prefVersion <= preferencesVersionDefaultingDataConnection) {
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

  if (prefVersion <= preferencesVersionIncreaseWatchdogDefault) {
    final currentDefault = prefService.get<int>(dataStreamGapWatchdogIntTag);
    if (currentDefault == dataStreamGapWatchdogOldDefault) {
      await prefService.set<int>(dataStreamGapWatchdogIntTag, dataStreamGapWatchdogDefault);
    }
  }

  if (prefVersion <= preferencesVersionZoneRefinementDefault) {
    for (var sport in SportSpec.sportPrefixes) {
      for (var prefSpec in MetricSpec.preferencesSpecs) {
        final thresholdTag = prefSpec.thresholdTag(sport);
        final oldThresholdDefault = prefSpec.oldThresholdDefault(sport);
        final newThresholdDefault = prefSpec.thresholdDefault(sport);
        final thresholdStr = prefService.get<String>(thresholdTag) ?? oldThresholdDefault;
        final zonesTag = prefSpec.zonesTag(sport);
        final oldZoneDefault = prefSpec.oldZoneDefault(sport);
        final newZonesDefault = prefSpec.zonesDefault(sport);
        final zonesStr = prefService.get<String>(zonesTag) ?? oldZoneDefault;
        if (thresholdStr == oldThresholdDefault && zonesStr == oldZoneDefault) {
          if (thresholdStr != newThresholdDefault) {
            await prefService.set<String>(thresholdTag, newThresholdDefault);
          }
          if (zonesStr != newZonesDefault) {
            await prefService.set<String>(zonesTag, newZonesDefault);
          }
        }
      }
    }
  }

  if (prefVersion <= preferencesVersionExclusiveSportOrDeviceLeaderboard) {
    final rankingForSport =
        prefService.get<bool>(rankingForSportOldTag) ?? rankingForSportOldDefault;
    final rankingForDevice =
        prefService.get<bool>(rankingForDeviceOldTag) ?? rankingForDeviceOldDefault;
    if (rankingForDevice && !rankingForSport) {
      await prefService.set<bool>(rankingForSportOrDeviceTag, !rankingForSportOrDeviceDefault);
    }
  }

  if (prefVersion <= preferencesVersionTimeDisplayMode) {
    final movingOrElapsedTime =
        prefService.get<bool>(movingOrElapsedTimeTag) ?? movingOrElapsedTimeDefault;
    if (!movingOrElapsedTime) {
      await prefService.set<String>(timeDisplayModeTag, timeDisplayModeElapsed);
    }
  }

  // Remove white space from data connection string
  if (prefVersion <= preferencesVersionNoWhitespaceInNetworkAddresses) {
    final oldDataConnectionAddresses =
        prefService.get<String>(dataConnectionAddressesTag) ?? dataConnectionAddressesDefault;
    if (oldDataConnectionAddresses.isNotEmpty) {
      final newAddresses = oldDataConnectionAddresses.removeAllWhitespace
          .split(",")
          .map((address) => addDefaultPortIfMissing(address))
          .join(",");
      if (oldDataConnectionAddresses.length != newAddresses.length) {
        prefService.set<String>(dataConnectionAddressesTag, newAddresses);
      }
    }
  }

  // Convert the single zone coloring setting to per metric
  if (prefVersion <= preferencesVersionPerMetricColoringByZone) {
    final deprecatedZoneIndexColoring =
        prefService.get<bool>(zoneIndexDisplayColoringTag) ?? zoneIndexDisplayColoringDefault;
    for (var prefSpec in MetricSpec.preferencesSpecs) {
      bool perMetricDefault = deprecatedZoneIndexColoring;
      if (prefSpec.metric != "speed") {
        bool zoneIndexDisplay =
            prefService.get<bool>(prefSpec.zoneIndexTag) ?? prefSpec.indexDisplayDefault;
        perMetricDefault = perMetricDefault && zoneIndexDisplay;
      }

      prefService.set<bool>(prefSpec.coloringByZoneTag, perMetricDefault);
    }
  }

  if (prefVersion <= preferencesVersionDefaultingOldTimeZone) {
    final enforcedTimeZone =
        prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;

    if (enforcedTimeZone != enforcedTimeZoneDefault) {
      final closestTimeZone = getClosestTimeZone(enforcedTimeZone);
      if (closestTimeZone != enforcedTimeZone) {
        prefService.set<String>(enforcedTimeZoneTag, closestTimeZone);
      }
    }

    // Activities have stored timeZone, but we would need to convert those
    // only if TrackManager.getTrack would get the timeZone besides the sport
  }

  await prefService.set<int>(preferencesVersionTag, preferencesVersionNext);

  for (var sport in SportSpec.sportPrefixes) {
    if (sport != ActivityType.ride) {
      final slowSpeedString = prefService.get<String>(SpeedSpec.slowSpeedTag(sport)) ??
          SpeedSpec.slowSpeedDefaults[sport].toString();
      SpeedSpec.slowSpeeds[sport] =
          double.tryParse(slowSpeedString) ?? SpeedSpec.slowSpeedDefaults[sport];
    }

    final pacerSpeedString = prefService.get<String>(SpeedSpec.pacerSpeedTag(sport)) ??
        SpeedSpec.pacerSpeedDefaults[sport].toString();
    SpeedSpec.pacerSpeeds[sport] =
        double.tryParse(pacerSpeedString) ?? SpeedSpec.pacerSpeedDefaults[sport];
  }

  final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
  if (logLevel != logLevelNone) {
    await Logging.init(logLevel);
  }

  return prefService;
}

Future<void> initPrefServiceForTest() async {
  var prefDefaults = await getPrefDefaults();
  final prefService = PrefServiceCache(defaults: prefDefaults);
  Get.put<BasePrefService>(prefService);
}
