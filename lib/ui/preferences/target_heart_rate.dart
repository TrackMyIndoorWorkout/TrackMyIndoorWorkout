import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../persistence/preferences_spec.dart';
import '../../preferences/audio_volume.dart';
import '../../preferences/sound_effects.dart';
import '../../preferences/target_heart_rate_sound_effect.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class TargetHrPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = targetHrShortTitle;
  static String title = "$shortTitle Preferences";

  const TargetHrPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> targetHrPreferences = [
      const PrefLabel(
        title: Text(TARGET_HEART_RATE_MODE),
        subtitle: Text(TARGET_HEART_RATE_MODE_DESCRIPTION),
      ),
      const PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_NONE_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_NONE,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      const PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_BPM_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_BPM,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      const PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_ZONES_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_ZONES,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(TARGET_HEART_RATE_LOWER_BPM),
        subtitle: const Text(TARGET_HEART_RATE_LOWER_BPM_DESCRIPTION),
        pref: TARGET_HEART_RATE_LOWER_BPM_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_BPM_MIN,
        max: TARGET_HEART_RATE_UPPER_BPM_MAX,
        direction: Axis.vertical,
        onChange: (num value) {
          final upperLimit =
              PrefService.of(context).get<int>(TARGET_HEART_RATE_UPPER_BPM_INT_TAG) ??
                  TARGET_HEART_RATE_UPPER_BPM_DEFAULT;
          if (value >= upperLimit) {
            PrefService.of(context).set<int>(TARGET_HEART_RATE_LOWER_BPM_INT_TAG, upperLimit - 1);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(TARGET_HEART_RATE_UPPER_BPM),
        subtitle: const Text(TARGET_HEART_RATE_UPPER_BPM_DESCRIPTION),
        pref: TARGET_HEART_RATE_UPPER_BPM_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_BPM_MIN,
        max: TARGET_HEART_RATE_UPPER_BPM_MAX,
        direction: Axis.vertical,
        onChange: (num value) {
          final lowerLimit =
              PrefService.of(context).get<int>(TARGET_HEART_RATE_LOWER_BPM_INT_TAG) ??
                  TARGET_HEART_RATE_LOWER_BPM_DEFAULT;
          if (value <= lowerLimit) {
            PrefService.of(context).set<int>(TARGET_HEART_RATE_UPPER_BPM_INT_TAG, lowerLimit + 1);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(TARGET_HEART_RATE_LOWER_ZONE),
        subtitle: const Text(TARGET_HEART_RATE_LOWER_ZONE_DESCRIPTION),
        pref: TARGET_HEART_RATE_LOWER_ZONE_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_ZONE_MIN,
        max: TARGET_HEART_RATE_UPPER_ZONE_MAX,
        direction: Axis.vertical,
        onChange: (num value) {
          final upperLimit =
              PrefService.of(context).get<int>(TARGET_HEART_RATE_UPPER_ZONE_INT_TAG) ??
                  TARGET_HEART_RATE_UPPER_ZONE_DEFAULT;
          if (value > upperLimit) {
            PrefService.of(context).set<int>(TARGET_HEART_RATE_LOWER_ZONE_INT_TAG, upperLimit);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(TARGET_HEART_RATE_UPPER_ZONE),
        subtitle: const Text(TARGET_HEART_RATE_UPPER_ZONE_DESCRIPTION),
        pref: TARGET_HEART_RATE_UPPER_ZONE_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_ZONE_MIN,
        max: TARGET_HEART_RATE_UPPER_ZONE_MAX,
        direction: Axis.vertical,
        onChange: (num value) {
          final lowerLimit =
              PrefService.of(context).get<int>(TARGET_HEART_RATE_LOWER_ZONE_INT_TAG) ??
                  TARGET_HEART_RATE_LOWER_ZONE_DEFAULT;
          if (value < lowerLimit) {
            PrefService.of(context).set<int>(TARGET_HEART_RATE_UPPER_ZONE_INT_TAG, lowerLimit);
          }
        },
      ),
      const PrefCheckbox(
        title: Text(TARGET_HEART_RATE_AUDIO),
        subtitle: Text(TARGET_HEART_RATE_AUDIO_DESCRIPTION),
        pref: TARGET_HEART_RATE_AUDIO_TAG,
      ),
      PrefSlider<int>(
        title: const Text(TARGET_HEART_RATE_AUDIO_PERIOD),
        subtitle: const Text(TARGET_HEART_RATE_AUDIO_PERIOD_DESCRIPTION),
        pref: TARGET_HEART_RATE_AUDIO_PERIOD_INT_TAG,
        trailing: (num value) => Text("$value s"),
        min: TARGET_HEART_RATE_AUDIO_PERIOD_MIN,
        max: TARGET_HEART_RATE_AUDIO_PERIOD_MAX,
        direction: Axis.vertical,
      ),
      const PrefLabel(
        title: Text(targetHeartRateSoundEffect),
        subtitle: Text(targetHeartRateSoundEffectDescription),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectOneToneDescription),
        value: soundEffectOneTone,
        pref: targetHeartRateSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectOneTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectTwoToneDescription),
        value: soundEffectTwoTone,
        pref: targetHeartRateSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectTwoTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectThreeToneDescription),
        value: soundEffectThreeTone,
        pref: targetHeartRateSoundEffectTag,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(soundEffectThreeTone),
      ),
      PrefRadio<String>(
        title: const Text(soundEffectBleepDescription),
        value: soundEffectBleep,
        pref: targetHeartRateSoundEffectTag,
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
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: targetHrPreferences),
    );
  }
}
