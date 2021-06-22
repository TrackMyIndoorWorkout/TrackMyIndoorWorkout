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
      PrefCheckbox(
        title: Text(PREFER_HRM_BASED_CALORIES),
        subtitle: Text(PREFER_HRM_BASED_CALORIES_DESCRIPTION),
        pref: PREFER_HRM_BASED_CALORIES_TAG,
      ),
      PrefSlider<int>(
        title: Text(STROKE_RATE_SMOOTHING),
        subtitle: Text(STROKE_RATE_SMOOTHING_DESCRIPTION),
        pref: STROKE_RATE_SMOOTHING_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: STROKE_RATE_SMOOTHING_MIN,
        max: STROKE_RATE_SMOOTHING_MAX,
      ),
      PrefTitle(title: Text(WORKAROUND_PREFERENCES)),
      PrefSlider<int>(
        title: Text(DATA_STREAM_GAP_WATCHDOG),
        subtitle: Text(DATA_STREAM_GAP_WATCHDOG_DESCRIPTION),
        pref: DATA_STREAM_GAP_WATCHDOG_INT_TAG,
        trailing: (num value) => Text("$value s"),
        min: DATA_STREAM_GAP_WATCHDOG_MIN,
        max: DATA_STREAM_GAP_WATCHDOG_MAX,
      ),
      PrefLabel(
        title: Text(DATA_STREAM_GAP_SOUND_EFFECT),
        subtitle: Text(DATA_STREAM_GAP_SOUND_EFFECT_DESCRIPTION),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_NONE_DESCRIPTION),
        value: SOUND_EFFECT_NONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_ONE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_ONE_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_TWO_TONE_DESCRIPTION),
        value: SOUND_EFFECT_TWO_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_THREE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_THREE_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
      ),
      PrefRadio<String>(
        title: Text(SOUND_EFFECT_BLEEP_DESCRIPTION),
        value: SOUND_EFFECT_BLEEP,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
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
      PrefCheckbox(
        title: Text(CADENCE_GAP_WORKAROUND),
        subtitle: Text(CADENCE_GAP_WORKAROUND_DESCRIPTION),
        pref: CADENCE_GAP_WORKAROUND_TAG,
      ),
      PrefLabel(title: Text(HEART_RATE_GAP_WORKAROUND_SELECTION)),
      PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_NO_WORKAROUND,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: Text(HEART_RATE_UPPER_LIMIT),
        subtitle: Text(HEART_RATE_UPPER_LIMIT_DESCRIPTION),
        pref: HEART_RATE_UPPER_LIMIT_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: HEART_RATE_UPPER_LIMIT_MIN,
        max: HEART_RATE_UPPER_LIMIT_MAX,
      ),
      PrefLabel(title: Text(HEART_RATE_LIMITING_METHOD)),
      PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION),
        value: HEART_RATE_LIMITING_WRITE_ZERO,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION),
        value: HEART_RATE_LIMITING_WRITE_NOTHING,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION),
        value: HEART_RATE_LIMITING_CAP_AT_LIMIT,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_NO_LIMIT_DESCRIPTION),
        value: HEART_RATE_LIMITING_NO_LIMIT,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: dataPreferences),
    );
  }
}
