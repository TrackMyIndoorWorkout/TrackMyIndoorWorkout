import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:timezone/timezone.dart' as tz;
import '../preferences/enforced_time_zone.dart';

Future<String> getTimeZone() async {
  final prefService = Get.find<BasePrefService>();
  var timeZone = prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;

  if (timeZone != enforcedTimeZoneDefault) {
    return timeZone;
  }

  return await FlutterTimezone.getLocalTimezone();
}

Future<List<String>> getSortedTimezones() async {
  // Also curate it so only the ones which are contained in the 10y TZ DB
  final flutterTimezoneChoices = (await FlutterTimezone.getAvailableTimezones())
      .where((timeZoneName) => tz.timeZoneDatabase.locations.containsKey(timeZoneName))
      .toList(growable: false);
  flutterTimezoneChoices.sort();
  return flutterTimezoneChoices;
}
