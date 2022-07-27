import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/audio_volume.dart';
import '../../preferences/cadence_data_gap_workaround.dart';
import '../../preferences/calculate_gps.dart';
import '../../persistence/database.dart';
import '../../preferences/data_stream_gap_sound_effect.dart';
import '../../preferences/data_stream_gap_watchdog_time.dart';
import '../../preferences/extend_tuning.dart';
import '../../preferences/heart_rate_gap_workaround.dart';
import '../../preferences/heart_rate_limiting.dart';
import '../../preferences/sound_effects.dart';
import '../../preferences/stroke_rate_smoothing.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/use_hr_monitor_reported_calories.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class DataPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Data";
  static String title = "$shortTitle Preferences";

  const DataPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> dataPreferences = [
      const PrefTitle(title: Text("Workout")),
      const PrefCheckbox(
        title: Text(calculateGps),
        subtitle: Text(calculateGpsDescription),
        pref: calculateGpsTag,
      ),
      const PrefTitle(title: Text("Tuning")),
      const PrefCheckbox(
        title: Text(extendTuning),
        subtitle: Text(extendTuningDescription),
        pref: extendTuningTag,
      ),
      const PrefCheckbox(
        title: Text(useHrMonitorReportedCalories),
        subtitle: Text(useHrMonitorReportedCaloriesDescription),
        pref: useHrMonitorReportedCaloriesTag,
      ),
      const PrefCheckbox(
        title: Text(useHeartRateBasedCalorieCounting),
        subtitle: Text(useHeartRateBasedCalorieCountingDescription),
        pref: useHeartRateBasedCalorieCountingTag,
      ),
      PrefSlider<int>(
        title: const Text(strokeRateSmoothing),
        subtitle: const Text(strokeRateSmoothingDescription),
        pref: strokeRateSmoothingIntTag,
        trailing: (num value) => Text("$value"),
        min: strokeRateSmoothingMin,
        max: strokeRateSmoothingMax,
        direction: Axis.vertical,
      ),
      const PrefTitle(title: Text("Workarounds")),
      PrefSlider<int>(
        title: const Text(dataStreamGapWatchdog),
        subtitle: const Text(dataStreamGapWatchdogDescription),
        pref: dataStreamGapWatchdogIntTag,
        trailing: (num value) => Text("$value s"),
        min: dataStreamGapWatchdogMin,
        max: dataStreamGapWatchdogMax,
        direction: Axis.vertical,
      ),
      PrefButton(
        title: const Text("Empty workout after connection loss workaround"),
        subtitle: const Text("Sometimes in case of data connection loss the auto-stopped and "
            "auto-closed workouts could show all 0s. That's a bug and the data "
            "is still there under the hood. Use the button bellow to fix those "
            "activities."),
        onTap: () async {
          final database = Get.find<AppDatabase>();
          final unfinished = await database.activityDao.findUnfinishedActivities();
          var counter = 0;
          for (final activity in unfinished) {
            final finalized = await database.finalizeActivity(activity);
            if (finalized) {
              counter++;
            }
          }

          if (counter > 0) {
            Get.snackbar("Activity finalization", "Finalized $counter unfinished activities");
          } else {
            Get.snackbar("Activity finalization", "Didn't find any unfinished activities");
          }
        },
        child: const Text("Fix empty workouts"),
      ),
      PrefLabel(
        title: Text(dataStreamGapSoundEffect, style: Get.textTheme.headline5!, maxLines: 3),
        subtitle: const Text(dataStreamGapSoundEffectDescription),
      ),
      const PrefRadio<String>(
        title: Text(soundEffectNoneDescription),
        value: soundEffectNone,
        pref: dataStreamGapSoundEffectTag,
      ),
      PrefRadio<String>(
        title: const Text(soundEffectOneToneDescription),
        value: soundEffectOneTone,
        pref: dataStreamGapSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectOneTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectTwoToneDescription),
        value: soundEffectTwoTone,
        pref: dataStreamGapSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectTwoTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectThreeToneDescription),
        value: soundEffectThreeTone,
        pref: dataStreamGapSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectThreeTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectBleepDescription),
        value: soundEffectBleep,
        pref: dataStreamGapSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectBleep),
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(audioVolume),
        subtitle: const Text(audioVolumeDescription),
        pref: audioVolumeIntTag,
        trailing: (num value) => Text("$value %"),
        min: audioVolumeMin,
        max: audioVolumeMax,
        direction: Axis.vertical,
      ),
      const PrefCheckbox(
        title: Text(cadenceGapWorkaround),
        subtitle: Text(cadenceGapWorkaroundDescription),
        pref: cadenceGapWorkaroundTag,
      ),
      PrefLabel(
        title: Text(
          heartRateGapWorkaroundSelection,
          style: Get.textTheme.headline5!,
          maxLines: 3,
        ),
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundLastPositiveValueDescription),
        value: dataGapWorkaroundLastPositiveValue,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundNoWorkaroundDescription),
        value: dataGapWorkaroundNoWorkaround,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundDoNotWriteZerosDescription),
        value: dataGapWorkaroundDoNotWriteZeros,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(heartRateUpperLimit),
        subtitle: const Text(heartRateUpperLimitDescription),
        pref: heartRateUpperLimitIntTag,
        trailing: (num value) => Text("$value"),
        min: heartRateUpperLimitMin,
        max: heartRateUpperLimitMax,
        direction: Axis.vertical,
      ),
      PrefLabel(title: Text(heartRateLimitingMethod, style: Get.textTheme.headline5!, maxLines: 3)),
      const PrefRadio<String>(
        title: Text(heartRateLimitingWriteZeroDescription),
        value: heartRateLimitingWriteZero,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingWriteNothingDescription),
        value: heartRateLimitingWriteNothing,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingCapAtLimitDescription),
        value: heartRateLimitingCapAtLimit,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingNoLimitDescription),
        value: heartRateLimitingNoLimit,
        pref: heartRateLimitingMethodTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: dataPreferences),
    );
  }
}
