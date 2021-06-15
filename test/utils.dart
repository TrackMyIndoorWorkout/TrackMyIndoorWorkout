import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/persistence/preferences.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

const SMALL_REPETITION = 10;
const REPETITION = 50;

const SPORTS = [
  ActivityType.Ride,
  ActivityType.Run,
  ActivityType.Kayaking,
  ActivityType.Canoeing,
  ActivityType.Rowing,
  ActivityType.Swim,
  ActivityType.Elliptical,
];

extension RangeExtension on int {
  List<int> to(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

List<int> getRandomInts(int count, int max, Random source) {
  return List<int>.generate(count, (index) => source.nextInt(max));
}

List<double> getRandomDoubles(int count, double max, Random source) {
  return List<double>.generate(count, (index) => source.nextDouble() * max);
}

String getRandomSport() {
  return SPORTS[Random().nextInt(SPORTS.length)];
}

class ExportModelForTests extends ExportModel {
  ExportModelForTests({
    sport,
    totalDistance,
    totalTime,
    calories,
    dateActivity,
    descriptor,
    deviceId,
    versionMajor,
    versionMinor,
    buildMajor,
    buildMinor,
    author,
    name,
    swVersionMajor,
    swVersionMinor,
    buildVersionMajor,
    buildVersionMinor,
    langID,
    partNumber,
    records,
  }) : super(
          sport: sport ?? ActivityType.Ride,
          totalDistance: totalDistance ?? 0.0,
          totalTime: totalTime ?? 0,
          calories: calories ?? 0,
          dateActivity: dateActivity ?? DateTime.now(),
          descriptor: descriptor ?? deviceMap["SAP+"]!,
          deviceId: deviceId ?? MPOWER_IMPORT_DEVICE_ID,
          versionMajor: versionMajor ?? 1,
          versionMinor: versionMinor ?? 0,
          buildMajor: buildMajor ?? 1,
          buildMinor: buildMinor ?? 0,
          author: author ?? 'Csaba Consulting',
          name: name ?? 'Track My Indoor Exercise',
          swVersionMajor: swVersionMajor ?? 1,
          swVersionMinor: swVersionMinor ?? 0,
          buildVersionMajor: buildVersionMajor ?? 1,
          buildVersionMinor: buildVersionMinor ?? 0,
          langID: langID ?? 'en-US',
          partNumber: partNumber ?? '0',
          records: records ?? [],
        );
}

Future<void> initPrefServiceForTest() async {
  var prefDefaults = await getPrefDefaults();
  final prefService =
      await PrefServiceShared.init(prefix: PREFERENCES_PREFIX, defaults: prefDefaults);
  Get.put<BasePrefService>(prefService);
}
