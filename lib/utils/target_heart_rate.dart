import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import '../persistence/preferences.dart';
import '../utils/preferences.dart';

// This can be eliminated once #107 takes care of integer preferences
Tuple2<double, double> getTargetHeartRateBounds(
    String targetMode, PreferencesSpec heartRatePreferences, SharedPreferences prefService) {
  if (targetMode == TARGET_HEART_RATE_MODE_NONE) {
    return Tuple2<double, double>(0, 0);
  }

  var lowerBpm = 0.0;
  var upperBpm = 0.0;
  if (targetMode == TARGET_HEART_RATE_MODE_BPM) {
    lowerBpm = getStringIntegerPreference(
      TARGET_HEART_RATE_LOWER_BPM_TAG,
      TARGET_HEART_RATE_LOWER_BPM_DEFAULT,
      TARGET_HEART_RATE_LOWER_BPM_DEFAULT_INT,
      prefService,
    ).toDouble();
    upperBpm = getStringIntegerPreference(
      TARGET_HEART_RATE_UPPER_BPM_TAG,
      TARGET_HEART_RATE_UPPER_BPM_DEFAULT,
      TARGET_HEART_RATE_UPPER_BPM_DEFAULT_INT,
      prefService,
    ).toDouble();
  } else if (targetMode == TARGET_HEART_RATE_MODE_ZONES) {
    final lowerZoneIndex = getStringIntegerPreference(
      TARGET_HEART_RATE_LOWER_ZONE_TAG,
      TARGET_HEART_RATE_LOWER_ZONE_DEFAULT,
      TARGET_HEART_RATE_LOWER_ZONE_DEFAULT_INT,
      prefService,
    );
    lowerBpm = heartRatePreferences.zoneLower[lowerZoneIndex];
    final upperZoneIndex = getStringIntegerPreference(
      TARGET_HEART_RATE_UPPER_ZONE_TAG,
      TARGET_HEART_RATE_UPPER_ZONE_DEFAULT,
      TARGET_HEART_RATE_UPPER_ZONE_DEFAULT_INT,
      prefService,
    );
    upperBpm = heartRatePreferences.zoneUpper[upperZoneIndex];
  }

  return Tuple2(lowerBpm, upperBpm);
}
