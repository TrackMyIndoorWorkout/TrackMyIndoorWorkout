import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../preferences/enforced_time_zone.dart';

Future<String> getTimeZone() async {
  final prefService = Get.find<BasePrefService>();
  var timeZone = prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;

  if (timeZone != enforcedTimeZoneDefault) {
    return timeZone;
  }

  return await FlutterNativeTimezone.getLocalTimezone();
}
