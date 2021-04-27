import '../activity_export.dart';
import '../export_model.dart';
import 'definitions/fit_activity.dart';
import 'definitions/fit_data_record.dart';
import 'definitions/fit_device_info.dart';
import 'definitions/fit_file_creator.dart';
import 'definitions/fit_file_id.dart';
import 'definitions/fit_lap.dart';
import 'definitions/fit_session.dart';
import 'definitions/fit_sport.dart';
import 'fit_header.dart';
import 'fit_serializable.dart';

class FitExport extends ActivityExport {
  FitExport()
      : super(nonCompressedFileExtension: 'fit', nonCompressedMimeType: 'application/octet-stream');

  Future<List<int>> getFileCore(ExportModel exportModel) async {
    var body = FitHeader();
    // 0. File ID
    var localMessageType = 0;
    final fileId = FitFileId(localMessageType: localMessageType);
    body.output.addAll(fileId.binarySerialize());
    body.output.addAll(fileId.serializeData(exportModel));
    localMessageType++;
    // 1. File Creator
    final fileCreator = FitFileCreator(localMessageType: localMessageType);
    body.output.addAll(fileCreator.binarySerialize());
    body.output.addAll(fileCreator.serializeData(exportModel));
    localMessageType++;
    // 2. Device Info
    final deviceInfo = FitDeviceInfo(localMessageType: localMessageType);
    body.output.addAll(deviceInfo.binarySerialize());
    body.output.addAll(deviceInfo.serializeData(exportModel));
    localMessageType++;

    // 3. Data Records
    final dataRecord = FitDataRecord(
      localMessageType: localMessageType,
      heartRateGapWorkaround: heartRateGapWorkaround,
      heartRateUpperLimit: heartRateUpperLimit,
      heartRateLimitingMethod: heartRateLimitingMethod,
    );
    body.output.addAll(dataRecord.binarySerialize());
    exportModel.records.forEach((record) {
      body.output.addAll(dataRecord.serializeData(record));
    });
    localMessageType++;

    // 4. Sport
    final fitSport = FitSport(localMessageType: localMessageType);
    body.output.addAll(fitSport.binarySerialize());
    body.output.addAll(fitSport.serializeData(exportModel.activityType));
    localMessageType++;
    // 5. Lap
    final lap = FitLap(localMessageType: localMessageType);
    body.output.addAll(lap.binarySerialize());
    body.output.addAll(lap.serializeData(exportModel));
    localMessageType++;
    // 6. Session
    final session = FitSession(localMessageType: localMessageType);
    body.output.addAll(session.binarySerialize());
    body.output.addAll(session.serializeData(exportModel));
    localMessageType++;
    // 7. Activity
    final activity = FitActivity(localMessageType: localMessageType);
    body.output.addAll(activity.binarySerialize());
    body.output.addAll(activity.serializeData(exportModel));
    localMessageType++;
    final dataSize = body.output.length;
    List<int> bodyBytes = body.binarySerialize();

    final header = FitHeader(dataSize: dataSize);
    List<int> headerBytes = header.binarySerialize();

    return headerBytes + bodyBytes;
  }

  String timeStampString(DateTime dateTime) {
    return ""; // Not used for FIT
  }

  int timeStampInteger(DateTime dateTime) {
    return FitSerializable.fitDateTime(dateTime);
  }
}
