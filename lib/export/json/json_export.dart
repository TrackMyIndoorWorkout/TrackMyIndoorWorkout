import 'dart:convert';

import '../activity_export.dart';
import '../export_model.dart';
import 'json_aggregates.dart';
import 'json_workout.dart';
import 'under_armour_sport.dart';

class JsonExport extends ActivityExport {
  JsonExport()
      : super(
          nonCompressedFileExtension: 'json',
          nonCompressedMimeType: 'application/json',
        );

  @override
  Future<List<int>> getFileCore(ExportModel exportModel) async {
    final jsonAggregates = JsonAggregates(
      exportModel.activity.elapsed,
      exportModel.activity.distance,
      exportModel.minimumSpeed,
      exportModel.maximumSpeed,
      exportModel.averageSpeed,
      exportModel.minimumPower,
      exportModel.maximumPower,
      exportModel.averagePower,
      exportModel.minimumCadence,
      exportModel.maximumCadence,
      exportModel.averageCadence,
      exportModel.minimumHeartRate,
      exportModel.maximumHeartRate,
      exportModel.averageHeartRate,
    );
    final jsonWorkout = JsonWorkout(
      exportModel.activity.start,
      exportModel.name,
      jsonAggregates,
      exportModel.activity.timeZone,
      toUnderArmourSport(exportModel.activity.sport),
    );

    return utf8.encode(jsonWorkout.toJson(exportModel));
  }
}
