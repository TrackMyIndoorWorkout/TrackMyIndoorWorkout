import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../persistence/preferences.dart';

Future<String> getTimeZone() async {
  final prefService = Get.find<BasePrefService>();
  var timeZone = prefService.get<String>(ENFORCED_TIME_ZONE_TAG) ?? ENFORCED_TIME_ZONE_DEFAULT;

  if (timeZone != ENFORCED_TIME_ZONE_DEFAULT) {
    return timeZone;
  }

  return await FlutterNativeTimezone.getLocalTimezone();
}
