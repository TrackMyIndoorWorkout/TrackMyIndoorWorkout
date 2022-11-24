import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/heart_rate_gap_workaround.dart';
import '../../preferences/heart_rate_limiting.dart';
import '../../preferences/heart_rate_monitor_priority.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/use_hr_monitor_reported_calories.dart';
import 'preferences_screen_mixin.dart';

class HeartRatePreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Heart Rate";
  static String title = "$shortTitle Preferences";

  const HeartRatePreferencesScreen({Key? key}) : super(key: key);

  @override
  HeartRatePreferencesScreenState createState() => HeartRatePreferencesScreenState();
}

class HeartRatePreferencesScreenState extends State<HeartRatePreferencesScreen> {
  int _hrUpperLimitEdit = 0;

  void onHeartRateUpperLimitSpinTap(int delta) {
    setState(() {
      final hrUpperLimit = PrefService.of(context).get(heartRateUpperLimitIntTag);
      PrefService.of(context).set(heartRateUpperLimitIntTag, hrUpperLimit + delta);
      _hrUpperLimitEdit++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> heartRatePreferences = [
      const PrefTitle(title: Text("Tuning")),
      const PrefCheckbox(
        title: Text(heartRateMonitorPriority),
        subtitle: Text(heartRateMonitorPriorityDescription),
        pref: heartRateMonitorPriorityTag,
      ),
      const PrefCheckbox(
        title: Text(useHrMonitorReportedCalories),
        subtitle: Text(useHrMonitorReportedCaloriesDescription),
        pref: useHrMonitorReportedCaloriesTag,
      ),
      const PrefCheckbox(
        title: Text(useHeartRateBasedCalorieCounting),
        subtitle: Text(useHeartRateBasedCalorieCountingDescription),
        pref: useHeartRateBasedCalorieCountingTag,
      ),
      const PrefTitle(title: Text("Workarounds")),
      PrefLabel(
        title: Text(
          heartRateGapWorkaroundSelection,
          style: Get.textTheme.headline5!,
          maxLines: 3,
        ),
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundLastPositiveValueDescription),
        value: dataGapWorkaroundLastPositiveValue,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundNoWorkaroundDescription),
        value: dataGapWorkaroundNoWorkaround,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefRadio<String>(
        title: Text(dataGapWorkaroundDoNotWriteZerosDescription),
        value: dataGapWorkaroundDoNotWriteZeros,
        pref: heartRateGapWorkaroundTag,
      ),
      const PrefLabel(title: Divider(height: 1)),
      PrefSlider<int>(
        key: Key("heartRateUpperLimit$_hrUpperLimitEdit"),
        title: const Text(heartRateUpperLimit),
        subtitle: const Text(heartRateUpperLimitDescription),
        pref: heartRateUpperLimitIntTag,
        trailing: (num value) => Text("$value"),
        min: heartRateUpperLimitMin,
        max: heartRateUpperLimitMax,
        divisions: heartRateUpperLimitDivisions,
        direction: Axis.vertical,
      ),
      PrefButton(
        onTap: () => onHeartRateUpperLimitSpinTap(1),
        child: const Text("+1 beat"),
      ),
      PrefButton(
        onTap: () => onHeartRateUpperLimitSpinTap(-1),
        child: const Text("-1 beat"),
      ),
      PrefButton(
        onTap: () => onHeartRateUpperLimitSpinTap(10),
        child: const Text("+10 beats"),
      ),
      PrefButton(
        onTap: () => onHeartRateUpperLimitSpinTap(-10),
        child: const Text("-10 beats"),
      ),
      PrefLabel(title: Text(heartRateLimitingMethod, style: Get.textTheme.headline5!, maxLines: 3)),
      const PrefRadio<String>(
        title: Text(heartRateLimitingWriteZeroDescription),
        value: heartRateLimitingWriteZero,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingWriteNothingDescription),
        value: heartRateLimitingWriteNothing,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingCapAtLimitDescription),
        value: heartRateLimitingCapAtLimit,
        pref: heartRateLimitingMethodTag,
      ),
      const PrefRadio<String>(
        title: Text(heartRateLimitingNoLimitDescription),
        value: heartRateLimitingNoLimit,
        pref: heartRateLimitingMethodTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(HeartRatePreferencesScreen.title)),
      body: PrefPage(children: heartRatePreferences),
    );
  }
}
