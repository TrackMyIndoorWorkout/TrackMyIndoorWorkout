import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
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
      PrefText(
        label: TARGET_HEART_RATE_LOWER_BPM,
        pref: TARGET_HEART_RATE_LOWER_BPM_TAG,
        validator: (str) {
          final upperLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_UPPER_BPM_TAG,
            TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
            TARGET_HEART_RATE_UPPER_BPM_DEFAULT_INT,
            null,
          );
          if (str == null || !isInteger(str, 0, upperLimit)) {
            return "Invalid lower target HR (should be 0 <= size <= $upperLimit)";
          }

          return null;
        },
      ),
      PrefText(
        label: TARGET_HEART_RATE_UPPER_BPM,
        pref: TARGET_HEART_RATE_UPPER_BPM_TAG,
        validator: (str) {
          final lowerLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_LOWER_BPM_TAG,
            TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
            TARGET_HEART_RATE_LOWER_BPM_DEFAULT_INT,
            null,
          );
          if (str == null || !isInteger(str, lowerLimit, 300)) {
            return "Invalid heart rate limit (should be $lowerLimit <= size <= 300)";
          }

          return null;
        },
      ),
      PrefText(
        label: TARGET_HEART_RATE_LOWER_ZONE,
        pref: TARGET_HEART_RATE_LOWER_ZONE_TAG,
        validator: (str) {
          final upperLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_UPPER_ZONE_TAG,
            TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
            TARGET_HEART_RATE_UPPER_ZONE_DEFAULT_INT,
            null,
          );
          if (str == null || !isInteger(str, 0, upperLimit)) {
            return "Invalid lower zone (should be 0 <= size <= $upperLimit)";
          }

          return null;
        },
      ),
      PrefText(
        label: TARGET_HEART_RATE_UPPER_ZONE,
        pref: TARGET_HEART_RATE_UPPER_ZONE_TAG,
        validator: (str) {
          final lowerLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_LOWER_ZONE_TAG,
            TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
            TARGET_HEART_RATE_LOWER_ZONE_DEFAULT_INT,
            null,
          );
          if (str == null || !isInteger(str, lowerLimit, 7)) {
            return "Invalid upper zone (should be $lowerLimit <= size <= 300)";
          }

          return null;
        },
      ),
      PrefCheckbox(
        title: Text(TARGET_HEART_RATE_AUDIO),
        subtitle: Text(TARGET_HEART_RATE_AUDIO_DESCRIPTION),
        pref: TARGET_HEART_RATE_AUDIO_TAG,
      ),
      PrefText(
        label: TARGET_HEART_RATE_AUDIO_PERIOD,
        pref: TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 0, 10)) {
            return "Invalid periodicity: should be 0 <= period <= 10)";
          }

          return null;
        },
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
      PrefText(
        label: AUDIO_VOLUME,
        pref: AUDIO_VOLUME_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 0, 100)) {
            return "Invalid, has to be: 0% <= volume <= 100%)";
          }

          return null;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: targetHrPreferences),
    );
  }
}
