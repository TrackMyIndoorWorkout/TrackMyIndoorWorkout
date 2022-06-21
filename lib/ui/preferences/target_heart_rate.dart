import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/audio_volume.dart';
import '../../preferences/metric_spec.dart';
import '../../preferences/sound_effects.dart';
import '../../preferences/target_heart_rate.dart';
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
        title: Text(targetHeartRateMode),
        subtitle: Text(targetHeartRateModeDescription),
      ),
      const PrefRadio<String>(
        title: Text(targetHeartRateModeNoneDescription),
        value: targetHeartRateModeNone,
        pref: targetHeartRateModeTag,
      ),
      const PrefRadio<String>(
        title: Text(targetHeartRateModeBpmDescription),
        value: targetHeartRateModeBpm,
        pref: targetHeartRateModeTag,
      ),
      const PrefRadio<String>(
        title: Text(targetHeartRateModeZonesDescription),
        value: targetHeartRateModeZones,
        pref: targetHeartRateModeTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(targetHeartRateLowerBpm),
        subtitle: const Text(targetHeartRateLowerBpmDescription),
        pref: targetHeartRateLowerBpmIntTag,
        trailing: (num value) => Text("$value"),
        min: targetHeartRateLowerBpmMin,
        max: targetHeartRateUpperBpmMax,
        direction: Axis.vertical,
        onChange: (num value) {
          final upperLimit = PrefService.of(context).get<int>(targetHeartRateUpperBpmIntTag) ??
              targetHeartRateUpperBpmDefault;
          if (value >= upperLimit) {
            PrefService.of(context).set<int>(targetHeartRateLowerBpmIntTag, upperLimit - 1);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(targetHeartRateUpperBpm),
        subtitle: const Text(targetHeartRateUpperBpmDescription),
        pref: targetHeartRateUpperBpmIntTag,
        trailing: (num value) => Text("$value"),
        min: targetHeartRateLowerBpmMin,
        max: targetHeartRateUpperBpmMax,
        direction: Axis.vertical,
        onChange: (num value) {
          final lowerLimit = PrefService.of(context).get<int>(targetHeartRateLowerBpmIntTag) ??
              targetHeartRateLowerBpmDefault;
          if (value <= lowerLimit) {
            PrefService.of(context).set<int>(targetHeartRateUpperBpmIntTag, lowerLimit + 1);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(targetHeartRateLowerZone),
        subtitle: const Text(targetHeartRateLowerZoneDescription),
        pref: targetHeartRateLowerZoneIntTag,
        trailing: (num value) => Text("$value"),
        min: targetHeartRateLowerZoneMin,
        max: targetHeartRateUpperZoneMax,
        direction: Axis.vertical,
        onChange: (num value) {
          final upperLimit = PrefService.of(context).get<int>(targetHeartRateUpperZoneIntTag) ??
              targetHeartRateUpperZoneDefault;
          if (value > upperLimit) {
            PrefService.of(context).set<int>(targetHeartRateLowerZoneIntTag, upperLimit);
          }
        },
      ),
      PrefSlider<int>(
        title: const Text(targetHeartRateUpperZone),
        subtitle: const Text(targetHeartRateUpperZoneDescription),
        pref: targetHeartRateUpperZoneIntTag,
        trailing: (num value) => Text("$value"),
        min: targetHeartRateLowerZoneMin,
        max: targetHeartRateUpperZoneMax,
        direction: Axis.vertical,
        onChange: (num value) {
          final lowerLimit = PrefService.of(context).get<int>(targetHeartRateLowerZoneIntTag) ??
              targetHeartRateLowerZoneDefault;
          if (value < lowerLimit) {
            PrefService.of(context).set<int>(targetHeartRateUpperZoneIntTag, lowerLimit);
          }
        },
      ),
      const PrefCheckbox(
        title: Text(targetHeartRateAudio),
        subtitle: Text(targetHeartRateAudioDescription),
        pref: targetHeartRateAudioTag,
      ),
      PrefSlider<int>(
        title: const Text(targetHeartRateAudioPeriod),
        subtitle: const Text(targetHeartRateAudioPeriodDescription),
        pref: targetHeartRateAudioPeriodIntTag,
        trailing: (num value) => Text("$value s"),
        min: targetHeartRateAudioPeriodMin,
        max: targetHeartRateAudioPeriodMax,
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
