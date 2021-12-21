import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../persistence/preferences_spec.dart';
import '../preferences/target_heart_rate.dart';

// This can be eliminated once #107 takes care of integer preferences
Tuple2<double, double> getTargetHeartRateBounds(
    String targetMode, PreferencesSpec heartRatePreferences, BasePrefService prefService) {
  if (targetMode == targetHeartRateModeNone) {
    return const Tuple2<double, double>(0, 0);
  }

  var lowerBpm = 0.0;
  var upperBpm = 0.0;
  if (targetMode == targetHeartRateModeBpm) {
    lowerBpm =
        (prefService.get<int>(targetHeartRateLowerBpmIntTag) ?? targetHeartRateLowerBpmDefault)
            .toDouble();
    upperBpm =
        (prefService.get<int>(targetHeartRateUpperBpmIntTag) ?? targetHeartRateUpperBpmDefault)
            .toDouble();
  } else if (targetMode == targetHeartRateModeZones) {
    final lowerZoneIndex =
        prefService.get<int>(targetHeartRateLowerZoneIntTag) ?? targetHeartRateLowerZoneDefault;
    lowerBpm = heartRatePreferences.zoneLower[lowerZoneIndex];
    final upperZoneIndex =
        prefService.get<int>(targetHeartRateUpperZoneIntTag) ?? targetHeartRateUpperZoneDefault;
    upperBpm = heartRatePreferences.zoneUpper[upperZoneIndex];
  }

  return Tuple2(lowerBpm, upperBpm);
}
