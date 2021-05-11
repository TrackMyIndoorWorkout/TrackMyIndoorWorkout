import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class TargetHrPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Target HR";
  static String title = "$shortTitle Prefs";

  @override
  Widget build(BuildContext context) {
    List<Widget> targetHrPreferences = [
      PreferenceTitle(TARGET_HEART_RATE_MODE_DESCRIPTION, style: descriptionStyle),
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
      PreferenceTitle(TARGET_HEART_RATE_AUDIO_MODE_DESCRIPTION, style: descriptionStyle),
      PreferenceDialogLink(
        TARGET_HEART_RATE_AUDIO_MODE,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              TARGET_HEART_RATE_AUDIO_MODE_NONE_DESCRIPTION,
              TARGET_HEART_RATE_AUDIO_MODE_NONE,
              TARGET_HEART_RATE_AUDIO_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_AUDIO_MODE_SINGLE_DESCRIPTION,
              TARGET_HEART_RATE_AUDIO_MODE_SINGLE,
              TARGET_HEART_RATE_AUDIO_MODE_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_AUDIO_MODE_PERIODIC_DESCRIPTION,
              TARGET_HEART_RATE_AUDIO_MODE_PERIODIC,
              TARGET_HEART_RATE_AUDIO_MODE_TAG,
            ),
          ],
          title: 'Select Target HR Audio Mode',
          cancelText: 'Close',
        ),
      ),
      PreferenceTitle(TARGET_HEART_RATE_SOUND_EFFECT_DESCRIPTION, style: descriptionStyle),
      PreferenceDialogLink(
        TARGET_HEART_RATE_SOUND_EFFECT,
        dialog: PreferenceDialog(
          [
            RadioPreference(
              TARGET_HEART_RATE_SOUND_EFFECT_ONE_TONE_DESCRIPTION,
              TARGET_HEART_RATE_SOUND_EFFECT_ONE_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_SOUND_EFFECT_TWO_TONE_DESCRIPTION,
              TARGET_HEART_RATE_SOUND_EFFECT_TWO_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_SOUND_EFFECT_THREE_TONE_DESCRIPTION,
              TARGET_HEART_RATE_SOUND_EFFECT_THREE_TONE,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
            ),
            RadioPreference(
              TARGET_HEART_RATE_SOUND_EFFECT_BLEEP_DESCRIPTION,
              TARGET_HEART_RATE_SOUND_EFFECT_BLEEP,
              TARGET_HEART_RATE_SOUND_EFFECT_TAG,
            ),
          ],
          title: 'Select Target HR Sound Effect',
          cancelText: 'Close',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(targetHrPreferences),
    );
  }
}
