import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class TargetHrPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = TARGET_HR_SHORT_TITLE;
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> targetHrPreferences = [
      PrefLabel(
        title: Text(TARGET_HEART_RATE_MODE),
        subtitle: Text(TARGET_HEART_RATE_MODE_DESCRIPTION),
      ),
      PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_NONE_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_NONE,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_BPM_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_BPM,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      PrefRadio<String>(
        title: Text(TARGET_HEART_RATE_MODE_ZONES_DESCRIPTION),
        value: TARGET_HEART_RATE_MODE_ZONES,
        pref: TARGET_HEART_RATE_MODE_TAG,
      ),
      PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: Text(TARGET_HEART_RATE_LOWER_BPM),
        subtitle: Text(TARGET_HEART_RATE_LOWER_BPM_DESCRIPTION),
        pref: TARGET_HEART_RATE_LOWER_BPM_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_BPM_MIN,
        max: TARGET_HEART_RATE_UPPER_BPM_MAX,
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
        title: Text(TARGET_HEART_RATE_UPPER_BPM),
        subtitle: Text(TARGET_HEART_RATE_UPPER_BPM_DESCRIPTION),
        pref: TARGET_HEART_RATE_UPPER_BPM_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_BPM_MIN,
        max: TARGET_HEART_RATE_UPPER_BPM_MAX,
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
        title: Text(TARGET_HEART_RATE_LOWER_ZONE),
        subtitle: Text(TARGET_HEART_RATE_LOWER_ZONE_DESCRIPTION),
        pref: TARGET_HEART_RATE_LOWER_ZONE_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_ZONE_MIN,
        max: TARGET_HEART_RATE_UPPER_ZONE_MAX,
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
        title: Text(TARGET_HEART_RATE_UPPER_ZONE),
        subtitle: Text(TARGET_HEART_RATE_UPPER_ZONE_DESCRIPTION),
        pref: TARGET_HEART_RATE_UPPER_ZONE_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: TARGET_HEART_RATE_LOWER_ZONE_MIN,
        max: TARGET_HEART_RATE_UPPER_ZONE_MAX,
        onChange: (num value) {
          final lowerLimit =
              PrefService.of(context).get<int>(TARGET_HEART_RATE_LOWER_ZONE_INT_TAG) ??
                  TARGET_HEART_RATE_LOWER_ZONE_DEFAULT;
          if (value < lowerLimit) {
            PrefService.of(context).set<int>(TARGET_HEART_RATE_UPPER_ZONE_INT_TAG, lowerLimit);
          }
        },
      ),
      PrefCheckbox(
        title: Text(TARGET_HEART_RATE_AUDIO),
        subtitle: Text(TARGET_HEART_RATE_AUDIO_DESCRIPTION),
        pref: TARGET_HEART_RATE_AUDIO_TAG,
      ),
      PrefSlider<int>(
        title: Text(TARGET_HEART_RATE_AUDIO_PERIOD),
        subtitle: Text(TARGET_HEART_RATE_AUDIO_PERIOD_DESCRIPTION),
        pref: TARGET_HEART_RATE_AUDIO_PERIOD_INT_TAG,
        trailing: (num value) => Text("$value s"),
        min: TARGET_HEART_RATE_AUDIO_PERIOD_MIN,
        max: TARGET_HEART_RATE_AUDIO_PERIOD_MAX,
      ),
      PrefLabel(
        title: Text(TARGET_HEART_RATE_SOUND_EFFECT),
        subtitle: Text(TARGET_HEART_RATE_SOUND_EFFECT_DESCRIPTION),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_ONE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_ONE_TONE,
        pref: TARGET_HEART_RATE_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_TWO_TONE_DESCRIPTION),
        value: SOUND_EFFECT_TWO_TONE,
        pref: TARGET_HEART_RATE_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_THREE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_THREE_TONE,
        pref: TARGET_HEART_RATE_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_BLEEP_DESCRIPTION),
        value: SOUND_EFFECT_BLEEP,
        pref: TARGET_HEART_RATE_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_BLEEP),
      ),
      PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: Text(AUDIO_VOLUME),
        subtitle: Text(AUDIO_VOLUME_DESCRIPTION),
        pref: AUDIO_VOLUME_INT_TAG,
        trailing: (num value) => Text("$value %"),
        min: AUDIO_VOLUME_MIN,
        max: AUDIO_VOLUME_MAX,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: targetHrPreferences),
    );
  }
}
