import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/database.dart';
import '../../persistence/preferences.dart';
import '../../utils/sound.dart';
import 'preferences_base.dart';

class DataPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Data";
  static String title = "$shortTitle Preferences";

  const DataPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> dataPreferences = [
      const PrefTitle(title: Text("Tuning")),
      const PrefCheckbox(
        title: Text(EXTEND_TUNING),
        subtitle: Text(EXTEND_TUNING_DESCRIPTION),
        pref: EXTEND_TUNING_TAG,
      ),
      const PrefCheckbox(
        title: Text(USE_HR_MONITOR_REPORTED_CALORIES),
        subtitle: Text(USE_HR_MONITOR_REPORTED_CALORIES_DESCRIPTION),
        pref: USE_HR_MONITOR_REPORTED_CALORIES_TAG,
      ),
      const PrefCheckbox(
        title: Text(USE_HEART_RATE_BASED_CALORIE_COUNTING),
        subtitle: Text(USE_HEART_RATE_BASED_CALORIE_COUNTING_DESCRIPTION),
        pref: USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG,
      ),
      PrefSlider<int>(
        title: const Text(STROKE_RATE_SMOOTHING),
        subtitle: const Text(STROKE_RATE_SMOOTHING_DESCRIPTION),
        pref: STROKE_RATE_SMOOTHING_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: STROKE_RATE_SMOOTHING_MIN,
        max: STROKE_RATE_SMOOTHING_MAX,
        direction: Axis.vertical,
      ),
      const PrefTitle(title: Text("Workarounds")),
      PrefSlider<int>(
        title: const Text(DATA_STREAM_GAP_WATCHDOG),
        subtitle: const Text(DATA_STREAM_GAP_WATCHDOG_DESCRIPTION),
        pref: DATA_STREAM_GAP_WATCHDOG_INT_TAG,
        trailing: (num value) => Text("$value s"),
        min: DATA_STREAM_GAP_WATCHDOG_MIN,
        max: DATA_STREAM_GAP_WATCHDOG_MAX,
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
          final activities = await database.activityDao.findAllActivities();
          for (var activity in activities) {
            final lastRecord =
                await database.recordDao.findLastRecordOfActivity(activity.id!).first;
            if (lastRecord != null) {
              int updated = 0;
              if (lastRecord.calories != null &&
                  lastRecord.calories! > 0 &&
                  activity.calories == 0) {
                activity.calories = lastRecord.calories!;
                updated++;
              }

              if (lastRecord.distance != null &&
                  lastRecord.distance! > 0 &&
                  activity.distance == 0) {
                activity.distance = lastRecord.distance!;
                updated++;
              }

              if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
                activity.elapsed = lastRecord.elapsed!;
                updated++;
              }

              if (lastRecord.timeStamp != null && lastRecord.timeStamp! > 0 && activity.end == 0) {
                activity.end = lastRecord.timeStamp!;
                updated++;
              }

              if (updated > 0) {
                database.activityDao.updateActivity(activity);
                Get.snackbar("Activity ${activity.id}", "Updated $updated fields");
              }
            }
          }
        },
        child: const Text("Fix empty workouts"),
      ),
      const PrefLabel(
        title: Text(DATA_STREAM_GAP_SOUND_EFFECT),
        subtitle: Text(DATA_STREAM_GAP_SOUND_EFFECT_DESCRIPTION),
      ),
      const PrefRadio<String>(
        title: Text(SOUND_EFFECT_NONE_DESCRIPTION),
        value: SOUND_EFFECT_NONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
      ),
      PrefRadio<String>(
        title: const Text(SOUND_EFFECT_ONE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_ONE_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_ONE_TONE),
      ),
      PrefRadio<String>(
        title: const Text(SOUND_EFFECT_TWO_TONE_DESCRIPTION),
        value: SOUND_EFFECT_TWO_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_TWO_TONE),
      ),
      PrefRadio<String>(
        title: const Text(SOUND_EFFECT_THREE_TONE_DESCRIPTION),
        value: SOUND_EFFECT_THREE_TONE,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_THREE_TONE),
      ),
      PrefRadio<String>(
        title: const Text(SOUND_EFFECT_BLEEP_DESCRIPTION),
        value: SOUND_EFFECT_BLEEP,
        pref: DATA_STREAM_GAP_SOUND_EFFECT_TAG,
        onSelect: () => Get.find<SoundService>().playSpecificSoundEffect(SOUND_EFFECT_BLEEP),
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(AUDIO_VOLUME),
        subtitle: const Text(AUDIO_VOLUME_DESCRIPTION),
        pref: AUDIO_VOLUME_INT_TAG,
        trailing: (num value) => Text("$value %"),
        min: AUDIO_VOLUME_MIN,
        max: AUDIO_VOLUME_MAX,
        direction: Axis.vertical,
      ),
      const PrefCheckbox(
        title: Text(CADENCE_GAP_WORKAROUND),
        subtitle: Text(CADENCE_GAP_WORKAROUND_DESCRIPTION),
        pref: CADENCE_GAP_WORKAROUND_TAG,
      ),
      const PrefLabel(title: Text(HEART_RATE_GAP_WORKAROUND_SELECTION)),
      const PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      const PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_NO_WORKAROUND,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      const PrefRadio<String>(
        title: Text(DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION),
        value: DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS,
        pref: HEART_RATE_GAP_WORKAROUND_TAG,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        title: const Text(HEART_RATE_UPPER_LIMIT),
        subtitle: const Text(HEART_RATE_UPPER_LIMIT_DESCRIPTION),
        pref: HEART_RATE_UPPER_LIMIT_INT_TAG,
        trailing: (num value) => Text("$value"),
        min: HEART_RATE_UPPER_LIMIT_MIN,
        max: HEART_RATE_UPPER_LIMIT_MAX,
        direction: Axis.vertical,
      ),
      const PrefLabel(title: Text(HEART_RATE_LIMITING_METHOD)),
      const PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION),
        value: HEART_RATE_LIMITING_WRITE_ZERO,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      const PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION),
        value: HEART_RATE_LIMITING_WRITE_NOTHING,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      const PrefRadio<String>(
        title: Text(HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION),
        value: HEART_RATE_LIMITING_CAP_AT_LIMIT,
        pref: HEART_RATE_LIMITING_METHOD_TAG,
      ),
      const PrefRadio<String>(
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
