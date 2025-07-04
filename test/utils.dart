import 'dart:math';

import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/schwinn_ac_performance_plus.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

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
    Activity? activity,
    bool? rawData,
    bool? calculateGps,
    DeviceDescriptor? descriptor,
    String? author,
    String? name,
    String? swVersionMajor,
    String? swVersionMinor,
    String? buildVersionMajor,
    String? buildVersionMinor,
    String? langID,
    String? partNumber,
    List<ExportRecord>? records,
  }) : super(
         activity:
             activity ??
             Activity(
               deviceName: "Test Dummy",
               deviceId: "CAFEBAEBE",
               hrmId: "",
               start: DateTime.now(),
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
         calculateGps: calculateGps ?? true,
         descriptor: descriptor ?? SchwinnACPerformancePlus(),
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
