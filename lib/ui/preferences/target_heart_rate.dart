import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
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
      PreferenceTitle(TARGET_HEART_RATE_MODE_DESCRIPTION),
      PreferenceDialogLink(
        TARGET_HEART_RATE_MODE,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              TARGET_HEART_RATE_MODE_NONE_DESCRIPTION,
              TARGET_HEART_RATE_MODE_NONE,
              TARGET_HEART_RATE_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_MODE_BPM_DESCRIPTION,
              TARGET_HEART_RATE_MODE_BPM,
              TARGET_HEART_RATE_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_MODE_ZONES_DESCRIPTION,
              TARGET_HEART_RATE_MODE_ZONES,
              TARGET_HEART_RATE_MODE_TAG,
            ),
          ],
          title: 'Select Target HR Method',
          cancelText: 'Close',
        ),
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_LOWER_BPM,
        TARGET_HEART_RATE_LOWER_BPM_TAG,
        defaultVal: TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
        validator: (str) {
          final upperLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_UPPER_BPM_TAG,
            TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
            TARGET_HEART_RATE_UPPER_BPM_DEFAULT_INT,
          );
          if (!isInteger(str, 0, upperLimit)) {
            return "Invalid lower target HR (should be 0 <= size <= $upperLimit)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_UPPER_BPM,
        TARGET_HEART_RATE_UPPER_BPM_TAG,
        defaultVal: TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
        validator: (str) {
          final lowerLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_LOWER_BPM_TAG,
            TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
            TARGET_HEART_RATE_LOWER_BPM_DEFAULT_INT,
          );
          if (!isInteger(str, lowerLimit, 300)) {
            return "Invalid heart rate limit (should be $lowerLimit <= size <= 300)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_LOWER_ZONE,
        TARGET_HEART_RATE_LOWER_ZONE_TAG,
        defaultVal: TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
        validator: (str) {
          final upperLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_UPPER_ZONE_TAG,
            TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
            TARGET_HEART_RATE_UPPER_ZONE_DEFAULT_INT,
          );
          if (!isInteger(str, 0, upperLimit)) {
            return "Invalid lower zone (should be 0 <= size <= $upperLimit)";
          }
          return null;
        },
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_UPPER_ZONE,
        TARGET_HEART_RATE_UPPER_ZONE_TAG,
        defaultVal: TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
        validator: (str) {
          final lowerLimit = getStringIntegerPreference(
            TARGET_HEART_RATE_LOWER_ZONE_TAG,
            TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
            TARGET_HEART_RATE_LOWER_ZONE_DEFAULT_INT,
          );
          if (!isInteger(str, lowerLimit, 7)) {
            return "Invalid upper zone (should be $lowerLimit <= size <= 300)";
          }
          return null;
        },
      ),
      SwitchPreference(
        TARGET_HEART_RATE_AUDIO,
        TARGET_HEART_RATE_AUDIO_TAG,
        defaultVal: TARGET_HEART_RATE_AUDIO_DEFAULT,
        desc: TARGET_HEART_RATE_AUDIO_DESCRIPTION,
      ),
      TextFieldPreference(
        TARGET_HEART_RATE_AUDIO_PERIOD,
        TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
        defaultVal: TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 10)) {
            return "Invalid periodicity: should be 0 <= period <= 10)";
          }
          return null;
        },
      ),
      PreferenceTitle(TARGET_HEART_RATE_SOUND_EFFECT_DESCRIPTION),
      PreferenceDialogLink(
        TARGET_HEART_RATE_SOUND_EFFECT,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              SOUND_EFFECT_ONE_TONE_DESCRIPTION,
              SOUND_EFFECT_ONE_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_TWO_TONE_DESCRIPTION,
              SOUND_EFFECT_TWO_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_THREE_TONE_DESCRIPTION,
              SOUND_EFFECT_THREE_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_BLEEP_DESCRIPTION,
              SOUND_EFFECT_BLEEP,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
              onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_BLEEP),
            ),
          ],
          title: 'Select Target HR Sound Effect',
          cancelText: 'Close',
        ),
      ),
      TextFieldPreference(
        AUDIO_VOLUME,
        AUDIO_VOLUME_TAG,
        defaultVal: AUDIO_VOLUME_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 100)) {
            return "Invalid, has to be: 0% <= volume <= 100%)";
          }
          return null;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(targetHrPreferences),
    );
  }
}