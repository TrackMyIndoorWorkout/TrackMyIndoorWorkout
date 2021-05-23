import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class DataPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Data";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> dataPreferences = [
      PreferenceTitle(TUNING_PREFERENCES),
      SwitchPreference(
        EXTEND_TUNING,
        EXTEND_TUNING_TAG,
        defaultVal: EXTEND_TUNING_DEFAULT,
        desc: EXTEND_TUNING_DESCRIPTION,
      ),
      PreferenceTitle(STROKE_RATE_SMOOTHING_DESCRIPTION),
      TextFieldPreference(
        STROKE_RATE_SMOOTHING,
        STROKE_RATE_SMOOTHING_TAG,
        defaultVal: STROKE_RATE_SMOOTHING_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 1, 50)) {
            return "Invalid window size (should be integer: 1 <= size <= 50)";
          }
          return null;
        },
      ),
      PreferenceTitle(WORKAROUND_PREFERENCES),
      PreferenceTitle(DATA_STREAM_GAP_WATCHDOG_DESCRIPTION),
      TextFieldPreference(
        DATA_STREAM_GAP_WATCHDOG,
        DATA_STREAM_GAP_WATCHDOG_TAG,
        defaultVal: DATA_STREAM_GAP_WATCHDOG_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 50)) {
            return "Invalid timeout (should be integer 0s <= time <= 50s)";
          }
          return null;
        },
      ),
      SwitchPreference(
        DATA_STREAM_GAP_ACTIVITY_AUTO_STOP,
        DATA_STREAM_GAP_ACTIVITY_AUTO_STOP_TAG,
        defaultVal: DATA_STREAM_GAP_ACTIVITY_AUTO_STOP_DEFAULT,
        desc: DATA_STREAM_GAP_ACTIVITY_AUTO_STOP_DESCRIPTION,
      ),
      PreferenceTitle(DATA_STREAM_GAP_SOUND_EFFECT_DESCRIPTION),
      PreferenceDialogLink(
        DATA_STREAM_GAP_SOUND_EFFECT,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              SOUND_EFFECT_NONE_DESCRIPTION,
              SOUND_EFFECT_NONE,
              DATA_STREAM_GAP_SOUND_EFFECT_TAG,
            ),
            RadioPreference(
              SOUND_EFFECT_ONE_TONE_DESCRIPTION,
              SOUND_EFFECT_ONE_TONE,
              DATA_STREAM_GAP_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_TWO_TONE_DESCRIPTION,
              SOUND_EFFECT_TWO_TONE,
              DATA_STREAM_GAP_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_THREE_TONE_DESCRIPTION,
              SOUND_EFFECT_THREE_TONE,
              DATA_STREAM_GAP_SOUND_EFFECT_TAG,
              onSelect: () =>
                  Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
            ),
            RadioPreference(
              SOUND_EFFECT_BLEEP_DESCRIPTION,
              SOUND_EFFECT_BLEEP,
              DATA_STREAM_GAP_SOUND_EFFECT_TAG,
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
      SwitchPreference(
        CADENCE_GAP_WORKAROUND,
        CADENCE_GAP_WORKAROUND_TAG,
        defaultVal: CADENCE_GAP_WORKAROUND_DEFAULT,
        desc: CADENCE_GAP_WORKAROUND_DESCRIPTION,
      ),
      PreferenceDialogLink(
        HEART_RATE_GAP_WORKAROUND,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION,
              DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
            RadioPreference(
              DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION,
              DATA_GAP_WORKAROUND_NO_WORKAROUND,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
            RadioPreference(
              DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION,
              DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS,
              HEART_RATE_GAP_WORKAROUND_TAG,
            ),
          ],
          title: 'Select workaround type',
          cancelText: 'Close',
        ),
      ),
      PreferenceTitle(HEART_RATE_UPPER_LIMIT_DESCRIPTION),
      TextFieldPreference(
        HEART_RATE_UPPER_LIMIT,
        HEART_RATE_UPPER_LIMIT_TAG,
        defaultVal: HEART_RATE_UPPER_LIMIT_DEFAULT,
        validator: (str) {
          if (!isInteger(str, 0, 300)) {
            return "Invalid heart rate limit (should be 0 <= size <= 300)";
          }
          return null;
        },
      ),
      PreferenceDialogLink(
        HEART_RATE_LIMITING_METHOD,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION,
              HEART_RATE_LIMITING_WRITE_ZERO,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION,
              HEART_RATE_LIMITING_WRITE_NOTHING,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION,
              HEART_RATE_LIMITING_CAP_AT_LIMIT,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
            RadioPreference(
              HEART_RATE_LIMITING_NO_LIMIT_DESCRIPTION,
              HEART_RATE_LIMITING_NO_LIMIT,
              HEART_RATE_LIMITING_METHOD_TAG,
            ),
          ],
          title: 'Select HR Limiting Method',
          cancelText: 'Close',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(dataPreferences),
    );
  }
}
