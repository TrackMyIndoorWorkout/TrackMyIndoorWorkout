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

  @override
  String timeStampString(DateTime dateTime) {
    return ""; // Not used for CSV
  }

  @override
  int timeStampInteger(DateTime dateTime) {
    return 0; // Not used for CSV
  }
}
