import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:pref/pref.dart';
import '../../preferences/audio_volume.dart';
import '../../preferences/cadence_data_gap_workaround.dart';
import '../../preferences/calculate_gps.dart';
import '../../preferences/data_stream_gap_sound_effect.dart';
import '../../preferences/data_stream_gap_watchdog_time.dart';
import '../../preferences/extend_tuning.dart';
import '../../preferences/sound_effects.dart';
import '../../preferences/stroke_rate_smoothing.dart';
import '../../utils/sound.dart';
import 'pref_integer.dart';
import 'preferences_screen_mixin.dart';

class DataPreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
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
      PrefSlider<int>(
        title: const Text(strokeRateSmoothing),
        subtitle: const Text(strokeRateSmoothingDescription),
        pref: strokeRateSmoothingIntTag,
        trailing: (num value) => Text("$value"),
        min: strokeRateSmoothingMin,
        max: strokeRateSmoothingMax,
        divisions: strokeRateSmoothingDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: strokeRateSmoothingIntTag,
        min: strokeRateSmoothingMin,
        max: strokeRateSmoothingMax,
      ),
      const PrefTitle(title: Text("Workarounds")),
      PrefSlider<int>(
        title: const Text(dataStreamGapWatchdog),
        subtitle: const Text(dataStreamGapWatchdogDescription),
        pref: dataStreamGapWatchdogIntTag,
        trailing: (num value) => Text("$value s"),
        min: dataStreamGapWatchdogMin,
        max: dataStreamGapWatchdogMax,
        divisions: dataStreamGapWatchdogDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: dataStreamGapWatchdogIntTag,
        min: dataStreamGapWatchdogMin,
        max: dataStreamGapWatchdogMax,
      ),
      PrefButton(
        title: const Text("Empty workout after connection loss workaround"),
        subtitle: const Text("Sometimes in case of data connection loss the auto-stopped and "
            "auto-closed workouts could show all 0s. That's a bug and the data "
            "is still there under the hood. Use the button bellow to fix those "
            "activities."),
        onTap: () async {
          final database = Get.find<Isar>();
          final unfinished = await database.activitys.findUnfinishedActivities();
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
        title: Text(dataStreamGapSoundEffect, style: Get.textTheme.headlineSmall!, maxLines: 3),
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
        divisions: audioVolumeDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: audioVolumeIntTag,
        min: audioVolumeMin,
        max: audioVolumeMax,
      ),
      const PrefCheckbox(
        title: Text(cadenceGapWorkaround),
        subtitle: Text(cadenceGapWorkaroundDescription),
        pref: cadenceGapWorkaroundTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: dataPreferences),
    );
  }
}
