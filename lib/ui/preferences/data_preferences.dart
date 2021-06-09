import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class DataPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Data";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> dataPreferences = [
      PrefTitle(title: Text(TUNING_PREFERENCES)),
      PrefCheckbox(
        title: Text(EXTEND_TUNING),
        subtitle: Text(EXTEND_TUNING_DESCRIPTION),
        pref: EXTEND_TUNING_TAG,
      ),
      PrefLabel(title: Text(STROKE_RATE_SMOOTHING_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: STROKE_RATE_SMOOTHING,
        pref: STROKE_RATE_SMOOTHING_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 1, 50)) {
            return "Invalid window size (should be integer: 1 <= size <= 50)";
          }

          return null;
        },
      ),
      PrefTitle(title: Text(WORKAROUND_PREFERENCES)),
      PrefLabel(title: Text(DATA_STREAM_GAP_WATCHDOG_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: DATA_STREAM_GAP_WATCHDOG,
        pref: DATA_STREAM_GAP_WATCHDOG_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 0, 50)) {
            return "Invalid timeout (should be integer 0s <= time <= 50s)";
          }

          return null;
        },
      ),
      PrefDropdown<String>(
        title: Text(DATA_STREAM_GAP_SOUND_EFFECT),
        subtitle: Text(DATA_STREAM_GAP_SOUND_EFFECT_DESCRIPTION),
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        items: [
          DropdownMenuItem(value: SOUND_EFFECT_NONE, child: Text(SOUND_EFFECT_NONE_DESCRIPTION)),
          DropdownMenuItem(
            value: SOUND_EFFECT_ONE_TONE,
            child: Text(SOUND_EFFECT_ONE_TONE_DESCRIPTION),
            onTap: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
          ),
          DropdownMenuItem(
            value: SOUND_EFFECT_TWO_TONE,
            child: Text(SOUND_EFFECT_TWO_TONE_DESCRIPTION),
            onTap: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
          ),
          DropdownMenuItem(
            value: SOUND_EFFECT_THREE_TONE,
            child: Text(SOUND_EFFECT_THREE_TONE_DESCRIPTION),
            onTap: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
          ),
          DropdownMenuItem(
            value: SOUND_EFFECT_BLEEP,
            child: Text(SOUND_EFFECT_BLEEP_DESCRIPTION),
            onTap: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_BLEEP),
          ),
        ],
      ),
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
      PrefCheckbox(
        title: Text(CADENCE_GAP_WORKAROUND),
        subtitle: Text(CADENCE_GAP_WORKAROUND_DESCRIPTION),
        pref: CADENCE_GAP_WORKAROUND_TAG,
      ),
      PrefDropdown<String>(
        title: Text(HEART_RATE_GAP_WORKAROUND_SELECTION),
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
        items: [
          DropdownMenuItem(
            value: DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE,
            child: Text(DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION),
          ),
          DropdownMenuItem(
            value: DATA_GAP_WORKAROUND_NO_WORKAROUND,
            child: Text(DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION),
          ),
          DropdownMenuItem(
            value: DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS,
            child: Text(DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION),
          ),
        ],
      ),
      PrefLabel(title: Text(HEART_RATE_UPPER_LIMIT_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: HEART_RATE_UPPER_LIMIT,
        pref: HEART_RATE_UPPER_LIMIT_TAG,
        validator: (str) {
          if (str == null || !isInteger(str, 0, 300)) {
            return "Invalid heart rate limit (should be 0 <= size <= 300)";
          }

          return null;
        },
      ),
      PrefDropdown<String>(
        title: Text(HEART_RATE_LIMITING_METHOD),
        pref: HEART_RATE_LIMITING_METHOD_TAG,
        items: [
          DropdownMenuItem(
            value: HEART_RATE_LIMITING_WRITE_ZERO,
            child: Text(HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION),
          ),
          DropdownMenuItem(
            value: HEART_RATE_LIMITING_WRITE_NOTHING,
            child: Text(HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION),
          ),
          DropdownMenuItem(
            value: HEART_RATE_LIMITING_CAP_AT_LIMIT,
            child: Text(HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION),
          ),
          DropdownMenuItem(
            value: HEART_RATE_LIMITING_NO_LIMIT,
            child: Text(HEART_RATE_LIMITING_NO_LIMIT_DESCRIPTION),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: dataPreferences),
    );
  }
}
