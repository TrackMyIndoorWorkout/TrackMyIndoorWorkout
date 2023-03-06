import 'dart:convert';

import '../../import/constants.dart';
import '../activity_export.dart';
import '../export_model.dart';

class CsvExport extends ActivityExport {
  final StringBuffer _sb = StringBuffer();

  CsvExport() : super(nonCompressedFileExtension: 'csv', nonCompressedMimeType: 'text/csv');

  @override
  Future<List<int>> getFileCore(ExportModel exportModel) async {
    _sb.writeln("$csvMagic,$csvVersion,");
    _sb.writeln("$rideSummaryTag,");

    addActivity(exportModel);

    return utf8.encode(_sb.toString());
  }

  void addActivity(ExportModel exportModel) {
    _sb.writeln("$totalTimeTag,${exportModel.activity.elapsed},$secondsUnitTag,");
    _sb.writeln("$totalDistanceTag,${exportModel.activity.distance},$meterUnitTag,");
    _sb.writeln("$deviceNameTag,${exportModel.activity.deviceName},");
    _sb.writeln("$deviceIdTag,${exportModel.activity.deviceId},");

    _sb.writeln("$startTimeTag,${exportModel.activity.start.millisecondsSinceEpoch},");
    _sb.writeln("$endTimeTag,${exportModel.activity.end?.millisecondsSinceEpoch ?? 0},");
    _sb.writeln("$caloriesTag,${exportModel.activity.calories},");
    _sb.writeln("$uploadedTag,${exportModel.activity.uploaded},");
    _sb.writeln("$stravaIdTag,${exportModel.activity.stravaId},");
    _sb.writeln("$fourCCTag,${exportModel.activity.fourCC},");
    _sb.writeln("$sportTag,${exportModel.activity.sport},");
    _sb.writeln("$powerFactorTag,${exportModel.activity.powerFactor},");
    _sb.writeln("$calorieFactorTag,${exportModel.activity.calorieFactor},");
    _sb.writeln("$hrCalorieFactorTag,${exportModel.activity.hrCalorieFactor},");
    _sb.writeln("$hrmCalorieFactorTag,${exportModel.activity.hrmCalorieFactor},");
    _sb.writeln("$hrmIdTag,${exportModel.activity.hrmId},");
    _sb.writeln("$hrBasedCaloriesTag,${exportModel.activity.hrBasedCalories},");
    _sb.writeln("$timeZoneTag,${exportModel.activity.timeZone},");
    _sb.writeln("$suuntoUploadedTag,${exportModel.activity.suuntoUploaded},");
    _sb.writeln("$suuntoBlobUrlTag,${exportModel.activity.suuntoBlobUrl},");
    _sb.writeln("$suuntoWorkoutUrlTag,${exportModel.activity.suuntoWorkoutUrl},");
    _sb.writeln("$suuntoUploadIdTag,${exportModel.activity.suuntoUploadIdentifier},");
    _sb.writeln("$underArmourUploadedTag,${exportModel.activity.underArmourUploaded},");
    _sb.writeln("$uaWorkoutIdTag,${exportModel.activity.uaWorkoutId},");
    _sb.writeln("$trainingPeaksUploadedTag,${exportModel.activity.trainingPeaksUploaded},");
    _sb.writeln("$trainingPeaksAthleteIdTag,${exportModel.activity.trainingPeaksAthleteId},");
    _sb.writeln("$trainingPeaksWorkoutIdTag,${exportModel.activity.trainingPeaksWorkoutId},");
    _sb.writeln("$movingTimeTag,${exportModel.activity.movingTime},");
    _sb.writeln("");

    addDetailData(exportModel);
  }

  void addDetailData(ExportModel exportModel) {
    _sb.writeln(rideDataTag);
    _sb.write("$powerHeaderTag,");
    _sb.write("$rpmHeaderTag,");
    _sb.write("$hrHeaderTag,");
    _sb.write("$distanceHeaderTag,");
    _sb.write("$timeStampTag,");
    _sb.write("$elapsedTag,");
    _sb.write("$speedTag,");
    _sb.writeln("$caloriesTag,");

    for (var record in exportModel.records) {
      _sb.write("${record.record.power ?? ""},");
      _sb.write("${record.record.cadence ?? ""},");
      _sb.write("${record.record.heartRate ?? ""},");
      _sb.write("${record.record.distance?.toStringAsFixed(2) ?? ""},");
      _sb.write("${record.record.timeStamp ?? ""},");
      _sb.write("${record.record.elapsed ?? ""},");
      _sb.write("${record.record.speed?.toStringAsFixed(2) ?? ""},");
      _sb.writeln("${record.record.calories ?? ""},");
    }
  }
}
