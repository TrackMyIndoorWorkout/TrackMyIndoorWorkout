import 'dart:convert';

import '../../import/constants.dart';
import '../activity_export.dart';
import '../export_model.dart';

class CsvExport extends ActivityExport {
  final StringBuffer _sb = StringBuffer();

  CsvExport() : super(nonCompressedFileExtension: 'csv', nonCompressedMimeType: 'text/csv');

  @override
  Future<List<int>> getFileCore(ExportModel exportModel) async {
    _sb.writeln("$CSV_MAGIC,$CSV_VERSION,");
    _sb.writeln("$RIDE_SUMMARY,");

    addActivity(exportModel);

    return utf8.encode(_sb.toString());
  }

  void addActivity(ExportModel exportModel) {
    _sb.writeln("$TOTAL_TIME,${exportModel.activity.elapsed},$SECONDS_UNIT,");
    _sb.writeln("$TOTAL_DISTANCE,${exportModel.activity.distance},$METER_UNIT,");
    _sb.writeln("$DEVICE_NAME,${exportModel.activity.deviceName},");
    _sb.writeln("$DEVICE_ID,${exportModel.activity.deviceId},");

    _sb.writeln("$START_TIME,${exportModel.activity.start},");
    _sb.writeln("$END_TIME,${exportModel.activity.end},");
    _sb.writeln("$CALORIES,${exportModel.activity.calories},");
    _sb.writeln("$UPLOADED_TAG,${exportModel.activity.uploaded},");
    _sb.writeln("$STRAVA_ID,${exportModel.activity.stravaId},");
    _sb.writeln("$FOUR_CC,${exportModel.activity.fourCC},");
    _sb.writeln("$SPORT_TAG,${exportModel.activity.sport},");
    _sb.writeln("$POWER_FACTOR,${exportModel.activity.powerFactor},");
    _sb.writeln("$CALORIE_FACTOR,${exportModel.activity.calorieFactor},");
    _sb.writeln("$HR_CALORIE_FACTOR,${exportModel.activity.hrCalorieFactor},");
    _sb.writeln("$HR_BASED_CALORIES,${exportModel.activity.hrBasedCalories},");
    _sb.writeln("$TIME_ZONE,${exportModel.activity.timeZone},");
    _sb.writeln("$SUUNTO_UPLOADED,${exportModel.activity.suuntoUploaded},");
    _sb.writeln("$SUUNTO_BLOB_URL,${exportModel.activity.suuntoBlobUrl},");
    _sb.writeln("$SUUNTO_WORKOUT_URL,${exportModel.activity.suuntoWorkoutUrl},");
    _sb.writeln("$SUUNTO_UPLOAD_ID,${exportModel.activity.suuntoUploadIdentifier},");
    _sb.writeln("$UNDER_ARMOUR_UPLOADED,${exportModel.activity.underArmourUploaded},");
    _sb.writeln("$UA_WORKOUT_ID,${exportModel.activity.uaWorkoutId},");
    _sb.writeln("$TRAINING_PEAKS_UPLOADED,${exportModel.activity.trainingPeaksUploaded},");
    _sb.writeln("$TRAINING_PEAKS_ATHLETE_ID,${exportModel.activity.trainingPeaksAthleteId},");
    _sb.writeln("$TRAINING_PEAKS_WORKOUT_ID,${exportModel.activity.trainingPeaksWorkoutId},");
    _sb.writeln("");

    addRideData(exportModel);
  }

  void addRideData(ExportModel exportModel) {
    _sb.writeln(RIDE_DATA);
    _sb.write("$POWER_HEADER,");
    _sb.write("$RPM_HEADER,");
    _sb.write("$HR_HEADER,");
    _sb.write("$DISTANCE_HEADER,");
    _sb.write("$TIME_STAMP,");
    _sb.write("$ELAPSED,");
    _sb.write("$SPEED,");
    _sb.writeln("$CALORIES,");

    for (var record in exportModel.records) {
      _sb.write("${record.record.power},");
      _sb.write("${record.record.cadence},");
      _sb.write("${record.record.heartRate},");
      _sb.write("${record.record.distance?.toStringAsFixed(2)},");
      _sb.write("${record.record.timeStamp},");
      _sb.write("${record.record.elapsed},");
      _sb.write("${record.record.speed?.toStringAsFixed(2)},");
      _sb.writeln("${record.record.calories},");
    }
  }
}
