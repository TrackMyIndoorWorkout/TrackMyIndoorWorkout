import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/persistence/models/activity.dart';
import 'package:track_my_indoor_exercise/preferences/generic.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

const smallRepetition = 10;
const repetition = 50;

List<int> getRandomInts(int count, int max, Random source) {
  return List<int>.generate(count, (index) => source.nextInt(max));
}

List<double> getRandomDoubles(int count, double max, Random source) {
  return List<double>.generate(count, (index) => source.nextDouble() * max);
}

String getRandomSport() {
  return allSports[Random().nextInt(allSports.length)];
}

class ExportModelForTests extends ExportModel {
  ExportModelForTests({
    activity,
    rawData,
    descriptor,
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
          activity: activity ??
              Activity(
                deviceName: "Test Dummy",
                deviceId: "CAFEBAEBE",
                hrmId: "",
                start: 0,
                fourCC: schwinnACPerfPlusFourCC,
                sport: ActivityType.ride,
                powerFactor: 1.0,
                calorieFactor: 1.0,
                hrCalorieFactor: 1.0,
                hrmCalorieFactor: 1.0,
                hrBasedCalories: false,
                timeZone: "America/Los_Angeles",
              ),
          rawData: rawData ?? false,
          descriptor: descriptor ?? deviceMap[schwinnACPerfPlusFourCC]!,
          author: author ?? 'Csaba Consulting',
          name: name ?? appName,
          swVersionMajor: swVersionMajor ?? "1",
          swVersionMinor: swVersionMinor ?? "0",
          buildVersionMajor: buildVersionMajor ?? "1",
          buildVersionMinor: buildVersionMinor ?? "0",
          langID: langID ?? 'en-US',
          partNumber: partNumber ?? '0',
          altitude: 0.0,
          records: records ?? [],
        );
}

Future<void> initPrefServiceForTest() async {
  var prefDefaults = await getPrefDefaults();
  final prefService = await PrefServiceShared.init(
    prefix: preferencesPrefix,
    defaults: prefDefaults,
  );
  Get.put<BasePrefService>(prefService);
}
