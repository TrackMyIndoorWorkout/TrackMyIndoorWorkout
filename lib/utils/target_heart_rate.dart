import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../persistence/preferences.dart';
import '../persistence/preferences_spec.dart';

// This can be eliminated once #107 takes care of integer preferences
Tuple2<double, double> getTargetHeartRateBounds(
    String targetMode, PreferencesSpec heartRatePreferences, BasePrefService prefService) {
  if (targetMode == TARGET_HEART_RATE_MODE_NONE) {
    return Tuple2<double, double>(0, 0);
  }

  var lowerBpm = 0.0;
  var upperBpm = 0.0;
  if (targetMode == TARGET_HEART_RATE_MODE_BPM) {
    lowerBpm = (prefService.get<int>(TARGET_HEART_RATE_LOWER_BPM_INT_TAG) ??
            TARGET_HEART_RATE_LOWER_BPM_DEFAULT)
        .toDouble();
    upperBpm = (prefService.get<int>(TARGET_HEART_RATE_UPPER_BPM_INT_TAG) ??
            TARGET_HEART_RATE_UPPER_BPM_DEFAULT)
        .toDouble();
  } else if (targetMode == TARGET_HEART_RATE_MODE_ZONES) {
    final lowerZoneIndex = prefService.get<int>(TARGET_HEART_RATE_LOWER_ZONE_INT_TAG) ??
        TARGET_HEART_RATE_LOWER_ZONE_DEFAULT;
    lowerBpm = heartRatePreferences.zoneLower[lowerZoneIndex];
    final upperZoneIndex = prefService.get<int>(TARGET_HEART_RATE_UPPER_ZONE_INT_TAG) ??
        TARGET_HEART_RATE_UPPER_ZONE_DEFAULT;
    upperBpm = heartRatePreferences.zoneUpper[upperZoneIndex];
  }

  return Tuple2(lowerBpm, upperBpm);
}
