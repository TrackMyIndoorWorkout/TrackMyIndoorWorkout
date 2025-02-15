import 'package:collection/collection.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';

import '../preferences/enforced_time_zone.dart';

Future<String> getTimeZone() async {
  final prefService = Get.find<BasePrefService>();
  var timeZone = prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;

  if (timeZone != enforcedTimeZoneDefault) {
    return timeZone;
  }

  return getClosestTimeZone(await FlutterTimezone.getLocalTimezone());
}

int timeZoneOffset(String timeZoneName) {
  DateTime? now;
  if (timeZoneName == enforcedTimeZoneDefault ||
      !tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
    now = DateTime.now();
  } else {
    final location = tz.getLocation(getClosestTimeZone(timeZoneName));
    now = tz.TZDateTime.now(location);
  }

  return now.timeZoneOffset.inMinutes;
}

String getClosestTimeZone(String timeZoneName) {
  if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
    return timeZoneName;
  }

  final timeOffset = timeZoneOffset(timeZoneName);
  return tz.timeZoneDatabase.locations.entries
      .map(
        (loc) => Tuple2<String, int>(
          loc.key,
          (loc.value.currentTimeZone.offset ~/ 60000 - timeOffset).abs(),
        ),
      )
      .sortedByCompare((loc) => loc.item2, (int o1, int o2) => o1.compareTo(o2))
      .first
      .item1;
}

Future<List<String>> getSortedTimezones() async {
  // Also curate it so only the ones which are contained in the 10y TZ DB
  final flutterTimezoneChoices = (await FlutterTimezone.getAvailableTimezones())
      .where((timeZoneName) => tz.timeZoneDatabase.locations.containsKey(timeZoneName))
      .toList(growable: false);
  flutterTimezoneChoices.sort();
  return flutterTimezoneChoices;
}
