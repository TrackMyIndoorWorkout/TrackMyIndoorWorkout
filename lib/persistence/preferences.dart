import 'dart:io';

import 'package:device_info/device_info.dart';

const PREFERENCES_PREFIX = "pref_";

const PREFERENCES_VERSION_TAG = "version";
const PREFERENCES_VERSION_DEFAULT = 3;
const PREFERENCES_VERSION_SPORT_THRESHOLDS = 1;
const PREFERENCES_VERSION_EQUIPMENT_REMEMBRANCE_PER_SPORT = 2;
const PREFERENCES_VERSION_SPINNERS = 3;
const PREFERENCES_VERSION_DEFAULTING_DATA_CONNECTION = 3;
const PREFERENCES_VERSION_NEXT = PREFERENCES_VERSION_DEFAULT + 1;

const INT_TAG_POSTFIX = "_int";

const UX_PREFERENCES = "UI / UX Preferences";

const UNIT_SYSTEM = "Unit System";
const UNIT_SYSTEM_TAG = "unit_system";
const UNIT_SYSTEM_DEFAULT = false;
const UNIT_SYSTEM_DESCRIPTION =
    "On: metric (km/h speed, meters distance), Off: imperial (mp/h speed, miles distance).";

const DISTANCE_RESOLUTION = "Distance Resolution High/Low";
const DISTANCE_RESOLUTION_TAG = "distance_resolution";
const DISTANCE_RESOLUTION_DEFAULT = false;
const DISTANCE_RESOLUTION_DESCRIPTION =
    "On: high resolution - m or yd, Off: low resolution - km or mi.";

const INSTANT_SCAN = "Instant Scanning";
const INSTANT_SCAN_TAG = "instant_scan";
const INSTANT_SCAN_DEFAULT = true;
const INSTANT_SCAN_DESCRIPTION = "On: the app will automatically start "
    "scanning for equipment after application start.";

const SCAN_DURATION = "Scan Duration (s)";
const SCAN_DURATION_TAG = "scan_duration";
const SCAN_DURATION_MIN = 6;
const SCAN_DURATION_DEFAULT = 6;
const SCAN_DURATION_MAX = 15;
const SCAN_DURATION_DESCRIPTION =
    "Duration in seconds the app will spend looking Bluetooth Low Energy equipment.";

const AUTO_CONNECT = "Auto Connect";
const AUTO_CONNECT_TAG = "auto_connect";
const AUTO_CONNECT_DEFAULT = false;
const AUTO_CONNECT_DESCRIPTION = "On: if there's only a single "
    "equipment after scan, or one of the devices match the "
    "last exercise machine the app will automatically move to the "
    "measurement screen to start recording.";

const LAST_EQUIPMENT_ID_TAG = "last_equipment";
const LAST_EQUIPMENT_ID_TAG_PREFIX = LAST_EQUIPMENT_ID_TAG + "_";
const LAST_EQUIPMENT_ID_DEFAULT = "";

const INSTANT_MEASUREMENT_START = "Instant Measurement Start";
const INSTANT_MEASUREMENT_START_TAG = "instant_measurement_start";
const INSTANT_MEASUREMENT_START_DEFAULT = true;
const INSTANT_MEASUREMENT_START_DESCRIPTION = "On: when navigating to the measurement screen the "
    "workout recording will start immediately. Off: the workout has to be started manually by "
    "pressing the play button.";

const INSTANT_UPLOAD = "Instant Upload";
const INSTANT_UPLOAD_TAG = "instant_upload";
const INSTANT_UPLOAD_DEFAULT = false;
const INSTANT_UPLOAD_DESCRIPTION = "On: when Strava is authenticated and "
    "the device is connected then activity upload is automatically "
    "attempted at the end of workout";

const SIMPLER_UI = "Simplify Measurement UI";
const SIMPLER_UI_TAG = "simpler_ui";
const SIMPLER_UI_FAST_DEFAULT = false;
const SIMPLER_UI_SLOW_DEFAULT = true;
const SIMPLER_UI_DESCRIPTION = "On: the track visualization and the real-time"
    " graphs won't be featured at the bottom of the measurement "
    "screen. This can help old / slow phones.";

const DEVICE_FILTERING = "Device Filtering";
const DEVICE_FILTERING_TAG = "device_filtering";
const DEVICE_FILTERING_DEFAULT = true;
const DEVICE_FILTERING_DESCRIPTION =
    "Off: the app won't filter the list of Bluetooth device while scanning. "
    "If your device is not listed while filtering is on then most probably it's not compatible.";

const MULTI_SPORT_DEVICE_SUPPORT = "Multi-Sport Device Support";
const MULTI_SPORT_DEVICE_SUPPORT_TAG = "multi_sport_device_support";
const MULTI_SPORT_DEVICE_SUPPORT_DEFAULT = false;
const MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION =
    "Turn this on only if you use a device (like Genesis Port) with multiple equipment of "
    "different sport (like Kayaking, Canoeing, Rowing, and Swimming). In that case you'll "
    "be prompted to select a sport before every workout.";

const TUNING_PREFERENCES = "Tuning";
const WORKAROUND_PREFERENCES = "Workarounds";

const MEASUREMENT_PANELS_EXPANDED_TAG = "measurement_panels_expanded";
const MEASUREMENT_PANELS_EXPANDED_DEFAULT = "00001";

const MEASUREMENT_DETAIL_SIZE_TAG = "measurement_detail_size";
const MEASUREMENT_DETAIL_SIZE_DEFAULT = "00000";

const EXTEND_TUNING = "Extend Power Tuning If Applicable";
const EXTEND_TUNING_TAG = "extend_tuning";
const EXTEND_TUNING_DEFAULT = false;
const EXTEND_TUNING_DESCRIPTION =
    "Apply power tuning to other attributes (speed, distance) as well when applicable. "
    "Note that depending on the equipment the tuning might already affect multiple attributes "
    "if they depend on each other like when calories or speed is calculated from power. "
    "Also note when both calorie and power tuning applied then their effect may combine.";

const USE_HR_MONITOR_REPORTED_CALORIES = "Use heart rate monitor reported calories";
const USE_HR_MONITOR_REPORTED_CALORIES_TAG = "use_heart_rate_monitor_reported_calories";
const USE_HR_MONITOR_REPORTED_CALORIES_DEFAULT = false;
const USE_HR_MONITOR_REPORTED_CALORIES_DESCRIPTION =
    "Only very enhanced heart rate monitors are capable reporting calories."
    "In such case should that calorie count take precedence over the value "
    "calculated by the fitness equipment (explicitly or deducted from the power reading).";

const USE_HEART_RATE_BASED_CALORIE_COUNTING = "Use heart rate based calorie counting";
const USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG = "heart_rate_based_calorie_counting";
const USE_HEART_RATE_BASED_CALORIE_COUNTING_DEFAULT = false;
const USE_HEART_RATE_BASED_CALORIE_COUNTING_DESCRIPTION =
    "This method also requires configured athlete weight, age, and gender. "
    "Optional VO2max could make the calculation even more precise.";

const STROKE_RATE_SMOOTHING = "Stroke Rate Smoothing";
const STROKE_RATE_SMOOTHING_TAG = "stroke_rate_smoothing";
const STROKE_RATE_SMOOTHING_INT_TAG = STROKE_RATE_SMOOTHING_TAG + INT_TAG_POSTFIX;
const STROKE_RATE_SMOOTHING_MIN = 1;
const STROKE_RATE_SMOOTHING_DEFAULT = 10;
const STROKE_RATE_SMOOTHING_MAX = 50;
const STROKE_RATE_SMOOTHING_DESCRIPTION = "Ergometers may provide too jittery data. Averaging "
    "these over time soothes the data. This setting tells the window size by how many samples "
    "could be in the smoothing queue. 1 means no smoothing.";

const DATA_STREAM_GAP_WATCHDOG = "Data Stream Gap Watchdog Timer";
const DATA_STREAM_GAP_WATCHDOG_TAG = "data_stream_gap_watchdog_timer";
const DATA_STREAM_GAP_WATCHDOG_INT_TAG = DATA_STREAM_GAP_WATCHDOG_TAG + INT_TAG_POSTFIX;
const DATA_STREAM_GAP_WATCHDOG_MIN = 0;
const DATA_STREAM_GAP_WATCHDOG_DEFAULT = 5;
const DATA_STREAM_GAP_WATCHDOG_MAX = 50;
const DATA_STREAM_GAP_WATCHDOG_DESCRIPTION = "How many seconds of data gap considered "
    "as a disconnection. A watchdog would finish the workout and can trigger sound warnings as well. "
    "Zero means disabled";

const SOUND_EFFECT_NONE = "none";
const SOUND_EFFECT_NONE_DESCRIPTION = "No sound effect";
const SOUND_EFFECT_ONE_TONE = "one_tone_beep";
const SOUND_EFFECT_ONE_TONE_DESCRIPTION = "A single tone 1200Hz beep";
const SOUND_EFFECT_TWO_TONE = "two_tone_beep";
const SOUND_EFFECT_TWO_TONE_DESCRIPTION = "Two beep tones repeated twice";
const SOUND_EFFECT_THREE_TONE = "three_tone_beep";
const SOUND_EFFECT_THREE_TONE_DESCRIPTION = "Three beep tones after one another";
const SOUND_EFFECT_BLEEP = "media_bleep";
const SOUND_EFFECT_BLEEP_DESCRIPTION = "A Media Call type bleep";

const DATA_STREAM_GAP_SOUND_EFFECT = "Data Stream Gap Audio Warning:";
const DATA_STREAM_GAP_SOUND_EFFECT_TAG = "data_stream_gap_sound_effect";
const DATA_STREAM_GAP_SOUND_EFFECT_DESCRIPTION =
    "Select the type of sound effect played when data acquisition timeout happens:";
const DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT = SOUND_EFFECT_THREE_TONE;

const CADENCE_GAP_WORKAROUND = "Cadence Data Gap Workaround:";
const CADENCE_GAP_WORKAROUND_TAG = "cadence_data_gap_workaround";
const CADENCE_GAP_WORKAROUND_DEFAULT = true;
const CADENCE_GAP_WORKAROUND_DESCRIPTION = "On: When speed / pace is non zero but the "
    "cadence / stroke rate is zero the application will substitute the zero with the last "
    "positive cadence reading. "
    "Off: Zero cadence will be recorded without modification.";

const HEART_RATE_GAP_WORKAROUND = "Heart Rate Data Gap Workaround";
const HEART_RATE_GAP_WORKAROUND_TAG = "heart_rate_gap_workaround";
const HEART_RATE_GAP_WORKAROUND_SELECTION = "Heart Rate Data Gap Workaround Selection:";
const DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE = "last_positive_value";
const DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE_DESCRIPTION =
    "Hold the last known positive reading when a zero intermittent reading is encountered";
const DATA_GAP_WORKAROUND_NO_WORKAROUND = "no_workaround";
const DATA_GAP_WORKAROUND_NO_WORKAROUND_DESCRIPTION =
    "Record any values (including zeros) just as they are read from the device";
const DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS = "do_not_write_zeros";
const DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS_DESCRIPTION =
    "Don't output any reading when zero data is recorded. Certain standards may not support that";
const HEART_RATE_GAP_WORKAROUND_DEFAULT = DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE;

const HEART_RATE_UPPER_LIMIT = "Heart Rate Upper Limit";
const HEART_RATE_UPPER_LIMIT_TAG = "heart_rate_upper_limit";
const HEART_RATE_UPPER_LIMIT_INT_TAG = HEART_RATE_UPPER_LIMIT_TAG + INT_TAG_POSTFIX;
const HEART_RATE_UPPER_LIMIT_MIN = 0;
const HEART_RATE_UPPER_LIMIT_DEFAULT = 0;
const HEART_RATE_UPPER_LIMIT_MAX = 300;
const HEART_RATE_UPPER_LIMIT_DESCRIPTION = "This is a heart rate upper bound where the methods "
    "bellow would be applied. 0 means no upper limiting is performed.";

const HEART_RATE_LIMITING_METHOD = "Heart Rate Limiting Method Selection:";
const HEART_RATE_LIMITING_METHOD_TAG = "heart_rate_limiting_method";
const HEART_RATE_LIMITING_WRITE_ZERO = "write_zero";
const HEART_RATE_LIMITING_WRITE_ZERO_DESCRIPTION =
    "Record zero when the heart rate limit is reached";
const HEART_RATE_LIMITING_WRITE_NOTHING = "write_nothing";
const HEART_RATE_LIMITING_WRITE_NOTHING_DESCRIPTION =
    "Don't record any heart rate when the limit is reached";
const HEART_RATE_LIMITING_CAP_AT_LIMIT = "cap_at_limit";
const HEART_RATE_LIMITING_CAP_AT_LIMIT_DESCRIPTION = "Cap the value at the level configured bellow";
const HEART_RATE_LIMITING_NO_LIMIT = "no_limit";
const HEART_RATE_LIMITING_NO_LIMIT_DESCRIPTION = "Don't apply any limiting";
const HEART_RATE_LIMITING_METHOD_DEFAULT = HEART_RATE_LIMITING_NO_LIMIT;

const TARGET_HEART_RATE_MODE = "Target Heart Rate Mode:";
const TARGET_HEART_RATE_MODE_TAG = "target_heart_rate_mode";
const TARGET_HEART_RATE_MODE_DESCRIPTION =
    "You can configure target heart rate BPM range or zone range. "
    "The app will alert visually (and optionally audio as well) when you are outside of the range. "
    "The lower and upper zone can be the same if you want to target just one zone.";
const TARGET_HEART_RATE_MODE_NONE = "none";
const TARGET_HEART_RATE_MODE_NONE_DESCRIPTION = "Target heart rate alert is turned off";
const TARGET_HEART_RATE_MODE_BPM = "bpm";
const TARGET_HEART_RATE_MODE_BPM_DESCRIPTION =
    "Bounds are specified by explicit beat per minute numbers";
const TARGET_HEART_RATE_MODE_ZONES = "zones";
const TARGET_HEART_RATE_MODE_ZONES_DESCRIPTION = "Bounds are specified by HR zone numbers";
const TARGET_HEART_RATE_MODE_DEFAULT = TARGET_HEART_RATE_MODE_NONE;

const TARGET_HEART_RATE_LOWER_BPM = "Target Heart Rate Lower BPM";
const TARGET_HEART_RATE_LOWER_BPM_TAG = "target_heart_rate_bpm_lower";
const TARGET_HEART_RATE_LOWER_BPM_INT_TAG = TARGET_HEART_RATE_LOWER_BPM_TAG + INT_TAG_POSTFIX;
const TARGET_HEART_RATE_LOWER_BPM_MIN = 0;
const TARGET_HEART_RATE_LOWER_BPM_DEFAULT = 120;
const TARGET_HEART_RATE_LOWER_BPM_DESCRIPTION =
    "Lower bpm of the target heart rate (for bpm target mode).";

const TARGET_HEART_RATE_UPPER_BPM = "Target Heart Rate Upper BPM";
const TARGET_HEART_RATE_UPPER_BPM_TAG = "target_heart_rate_bpm_upper";
const TARGET_HEART_RATE_UPPER_BPM_INT_TAG = TARGET_HEART_RATE_UPPER_BPM_TAG + INT_TAG_POSTFIX;
const TARGET_HEART_RATE_UPPER_BPM_DEFAULT = 140;
const TARGET_HEART_RATE_UPPER_BPM_MAX = 300;
const TARGET_HEART_RATE_UPPER_BPM_DESCRIPTION =
    "Upper bpm of the target heart rate (for bpm target mode).";

const TARGET_HEART_RATE_LOWER_ZONE = "Target Heart Rate Lower Zone";
const TARGET_HEART_RATE_LOWER_ZONE_TAG = "target_heart_rate_zone_lower";
const TARGET_HEART_RATE_LOWER_ZONE_INT_TAG = TARGET_HEART_RATE_LOWER_ZONE_TAG + INT_TAG_POSTFIX;
const TARGET_HEART_RATE_LOWER_ZONE_MIN = 0;
const TARGET_HEART_RATE_LOWER_ZONE_DEFAULT = 3;
const TARGET_HEART_RATE_LOWER_ZONE_DESCRIPTION =
    "Lower zone of the target heart rate (for zone target mode).";

const TARGET_HEART_RATE_UPPER_ZONE = "Target Heart Rate Upper Zone";
const TARGET_HEART_RATE_UPPER_ZONE_TAG = "target_heart_rate_zone_upper";
const TARGET_HEART_RATE_UPPER_ZONE_INT_TAG = TARGET_HEART_RATE_UPPER_ZONE_TAG + INT_TAG_POSTFIX;
const TARGET_HEART_RATE_UPPER_ZONE_DEFAULT = 3;
const TARGET_HEART_RATE_UPPER_ZONE_MAX = 7;
const TARGET_HEART_RATE_UPPER_ZONE_DESCRIPTION =
    "Upper zone of the target heart rate (for zone target mode).";

const TARGET_HEART_RATE_AUDIO = "Target Heart Rate Audio";
const TARGET_HEART_RATE_AUDIO_TAG = "target_heart_rate_audio";
const TARGET_HEART_RATE_AUDIO_DEFAULT = false;
const TARGET_HEART_RATE_AUDIO_DESCRIPTION = "Should a sound effect play when HR is out of range.";

const TARGET_HEART_RATE_AUDIO_PERIOD = "Target HR Audio Period (seconds)";
const TARGET_HEART_RATE_AUDIO_PERIOD_TAG = "target_heart_rate_audio_period";
const TARGET_HEART_RATE_AUDIO_PERIOD_INT_TAG = TARGET_HEART_RATE_AUDIO_PERIOD_TAG + INT_TAG_POSTFIX;
const TARGET_HEART_RATE_AUDIO_PERIOD_MIN = 0;
const TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT = 0;
const TARGET_HEART_RATE_AUDIO_PERIOD_MAX = 10;
const TARGET_HEART_RATE_AUDIO_PERIOD_DESCRIPTION = "0 or 1: no periodicity. Larger than 1 seconds: "
    "the selected sound effect will play with the periodicity until the HR is back in range.";

const TARGET_HEART_RATE_SOUND_EFFECT = "Target Heart Rate Out of Range Sound Effect:";
const TARGET_HEART_RATE_SOUND_EFFECT_TAG = "target_heart_rate_sound_effect";
const TARGET_HEART_RATE_SOUND_EFFECT_DESCRIPTION =
    "Select the type of sound effect played when the HR gets out of range:";
const TARGET_HEART_RATE_SOUND_EFFECT_DEFAULT = SOUND_EFFECT_TWO_TONE;

const AUDIO_VOLUME = "Audio Volume (%)";
const AUDIO_VOLUME_TAG = "audio_volume";
const AUDIO_VOLUME_INT_TAG = AUDIO_VOLUME_TAG + INT_TAG_POSTFIX;
const AUDIO_VOLUME_MIN = 0;
const AUDIO_VOLUME_DEFAULT = 50;
const AUDIO_VOLUME_MAX = 100;
const AUDIO_VOLUME_DESCRIPTION = "Volume base of the audio effects.";

const LEADERBOARD_FEATURE = "Leaderboard Feature";
const LEADERBOARD_FEATURE_TAG = "leaderboard_feature";
const LEADERBOARD_FEATURE_DEFAULT = false;
const LEADERBOARD_FEATURE_DESCRIPTION =
    "Leaderboard registry: should the app record workout entries for leaderboard purposes.";

const RANK_RIBBON_VISUALIZATION = "Display Rank Ribbons Above the Speed Graph";
const RANK_RIBBON_VISUALIZATION_TAG = "rank_ribbon_visualization";
const RANK_RIBBON_VISUALIZATION_DEFAULT = false;
const RANK_RIBBON_VISUALIZATION_DESCRIPTION =
    "Should the app provide UI feedback by ribbons above the speed graph. "
    "Blue color means behind the top leaderboard, green marks record pace.";

const RANKING_FOR_DEVICE = "Ranking Based on the Actual Device";
const RANKING_FOR_DEVICE_TAG = "ranking_for_device";
const RANKING_FOR_DEVICE_DEFAULT = false;
const RANKING_FOR_DEVICE_DESCRIPTION = "Should the app display ranking for the particular device. "
    "This affects both the ribbon type and the track visualization.";

const RANKING_FOR_SPORT = "Ranking Based on the Whole Sport";
const RANKING_FOR_SPORT_TAG = "ranking_for_sport";
const RANKING_FOR_SPORT_DEFAULT = false;
const RANKING_FOR_SPORT_DESCRIPTION =
    "Should the app display ranking for all devices for the sport. "
    "This affects both the ribbon type and the track visualization.";

const RANK_TRACK_VISUALIZATION = "Visualize Rank Positions on the Track";
const RANK_TRACK_VISUALIZATION_TAG = "rank_track_visualization";
const RANK_TRACK_VISUALIZATION_DEFAULT = false;
const RANK_TRACK_VISUALIZATION_DESCRIPTION =
    "For performance reasons only the position right ahead (green color) and right behind "
    "(blue color) of the current effort is displayed. Both positions have a the rank "
    "number inside their dot.";

const RANK_INFO_ON_TRACK =
    "Display rank information at the center of the track (on top of positions)";
const RANK_INFO_ON_TRACK_TAG = "rank_info_on_track";
const RANK_INFO_ON_TRACK_DEFAULT = true;
const RANK_INFO_ON_TRACK_DESCRIPTION =
    "On: when rank position is enabled this switch will display extra information "
    "in the middle of the track: it'll list the preceding and following positions "
    "along with the distance compared to the athlete's current position";

const EXPERT_PREFERENCES = "Expert Preferences";

const APP_DEBUG_MODE = "Application Debug Mode";
const APP_DEBUG_MODE_TAG = "app_debug_mode";
const APP_DEBUG_MODE_DEFAULT = false;
const APP_DEBUG_MODE_DESCRIPTION =
    "On: The Recording UI runs on simulated data, no equipment required. "
    "Off: The recording works as it should in release.";

const DATA_CONNECTION_ADDRESSES = "Data Connection Check Endpoints";
const DATA_CONNECTION_ADDRESSES_TAG = "data_connection_addresses";
const DATA_CONNECTION_ADDRESSES_DEFAULT = "";
const DATA_CONNECTION_ADDRESSES_OLD_DEFAULT =
    "52.44.84.95,54.160.234.139,52.87.57.116,3.93.102.29,54.157.131.119,3.226.9.14";

const DATA_CONNECTION_ADDRESSES_DESCRIPTION =
    "Following is a comma separated list of IP addresses with optional comma "
    "separated port numbers. Lack of a port number will mean 443 (HTTPS). "
    "The application will reach out to these endpoints to determine if "
    "there is really a data connection.";

const ZONE_PREFERENCES = " Zone Preferences";

const THEME_SELECTION = "Theme Selection (System / Light / Dark):";
const THEME_SELECTION_TAG = "theme_selection";
const THEME_SELECTION_DESCRIPTION =
    "Should the theme match the system default, be light, or be dark:";
const THEME_SELECTION_SYSTEM = "system";
const THEME_SELECTION_SYSTEM_DESCRIPTION = "System's theme";
const THEME_SELECTION_LIGHT = "light";
const THEME_SELECTION_LIGHT_DESCRIPTION = "Light theme";
const THEME_SELECTION_DARK = "dark";
const THEME_SELECTION_DARK_DESCRIPTION = "Dark theme";
const THEME_SELECTION_DEFAULT = THEME_SELECTION_SYSTEM;

const ZONE_INDEX_DISPLAY_COLORING = "Color the measurement based on zones";
const ZONE_INDEX_DISPLAY_COLORING_TAG = "zone_index_display_coloring";
const ZONE_INDEX_DISPLAY_COLORING_DEFAULT = true;
const ZONE_INDEX_DISPLAY_COLORING_DESCRIPTION =
    "On: The measurement font and background is color modified to reflect the zone value. "
    "Off: The zone is displayed without any re-coloring, this is less performance intensive.";

const ATHLETE_BODY_WEIGHT = "Body Weight (kg)";
const ATHLETE_BODY_WEIGHT_TAG = "athlete_body_weight";
const ATHLETE_BODY_WEIGHT_INT_TAG = ATHLETE_BODY_WEIGHT_TAG + INT_TAG_POSTFIX;
const ATHLETE_BODY_WEIGHT_MIN = 1;
const ATHLETE_BODY_WEIGHT_DEFAULT = 60;
const ATHLETE_BODY_WEIGHT_MAX = 300;
const ATHLETE_BODY_WEIGHT_DESCRIPTION =
    "This settings is optional. It could be used either for heart rate based calorie counting equations "
    "or spin-down capable devices to set "
    "the initial value displayed in the weight input until the device sends the last inputted weight. "
    "As soon as the last inputted weight is received from the device it'll override the value in the input";

const REMEMBER_ATHLETE_BODY_WEIGHT = "Remember last inputted weight at spin-down";
const REMEMBER_ATHLETE_BODY_WEIGHT_TAG = "remember_athlete_body_weight";
const REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT = true;
const REMEMBER_ATHLETE_BODY_WEIGHT_DESCRIPTION =
    "On: The weight inputted at the beginning of a spin-down will override the weight above. "
    "Off: The weight input adjusted at spin-down won't be stored back to the setting above.";

const ATHLETE_AGE = "Age (years)";
const ATHLETE_AGE_TAG = "athlete_age";
const ATHLETE_AGE_MIN = 0;
const ATHLETE_AGE_DEFAULT = 30;
const ATHLETE_AGE_MAX = 120;
const ATHLETE_AGE_DESCRIPTION = "Used for heart rate base calorie counting if that is preferred";

const ATHLETE_GENDER = "Gender";
const ATHLETE_GENDER_TAG = "athlete_gender";
const ATHLETE_GENDER_DESCRIPTION =
    "The gender classification for the purpose heart rate based calorie calculation equations.";
const ATHLETE_GENDER_MALE = "male";
const ATHLETE_GENDER_MALE_DESCRIPTION = "Male";
const ATHLETE_GENDER_FEMALE = "female";
const ATHLETE_GENDER_FEMALE_DESCRIPTION = "Female";
const ATHLETE_GENDER_DEFAULT = ATHLETE_GENDER_MALE;

const ATHLETE_VO2MAX = "VO2max (ml/kg/min)";
const ATHLETE_VO2MAX_TAG = "athlete_vo2max";
const ATHLETE_VO2MAX_MIN = 15;
const ATHLETE_VO2MAX_DEFAULT = ATHLETE_VO2MAX_MIN;
const ATHLETE_VO2MAX_MAX = 100;
const ATHLETE_VO2MAX_DESCRIPTION = "Optional, but it could make the equation more precise. "
    "15 (minimum) means that the VO2max is ignored (not set).";

const ENFORCED_TIME_ZONE = "Enforced Time Zone";
const ENFORCED_TIME_ZONE_TAG = "enforced_time_zone";
const ENFORCED_TIME_ZONE_DEFAULT = "Auto Detected";
const ENFORCED_TIME_ZONE_DESCRIPTION = "The supposed time-zone of a workout. "
    "If not set the app will auto detect the device's time zone, "
    "you can see the auto detected time zone on About screen."
    "Right now only Training Peaks has time zone information, and all GPS "
    "data is at the US Pacific Coast.";

Future<bool> getSimplerUiDefault() async {
  var simplerUiDefault = SIMPLER_UI_FAST_DEFAULT;
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 26) {
      // Remove complexities for very old Android devices
      simplerUiDefault = SIMPLER_UI_SLOW_DEFAULT;
    }
  }
  return simplerUiDefault;
}

extension DurationDisplay on Duration {
  String toDisplay() {
    return this.toString().split('.').first.padLeft(8, "0");
  }
}
