import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../preferences/enforced_time_zone.dart';

Future<String> getTimeZone() async {
  final prefService = Get.find<BasePrefService>();
  var timeZone = prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;

  if (timeZone != enforcedTimeZoneDefault) {
    return timeZone;
  }

  return await FlutterTimezone.getLocalTimezone();
}
