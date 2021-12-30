import '../activity_export.dart';
import '../export_model.dart';
import '../export_target.dart';
import 'definitions/fit_activity.dart';
import 'definitions/fit_data_record.dart';
import 'definitions/fit_device_info.dart';
import 'definitions/fit_file_creator.dart';
import 'definitions/fit_file_id.dart';
import 'definitions/fit_session.dart';
import 'definitions/fit_sport.dart';
import 'fit_data.dart';
import 'fit_header.dart';

class FitExport extends ActivityExport {
  FitExport()
      : super(
          nonCompressedFileExtension: 'fit',
          nonCompressedMimeType: 'application/octet-stream',
        );

  @override
  Future<List<int>> getFileCore(ExportModel exportModel) async {
    var body = FitData();
    final productNameLength = exportModel.descriptor.fullName.length;

    var localMessageType = 0;
    if (exportModel.exportTarget == ExportTarget.regular) {
      // 0. File ID
      final fileId = FitFileId(localMessageType, productNameLength);
      body.output.addAll(fileId.binarySerialize());
      body.output.addAll(fileId.serializeData(exportModel));
      localMessageType++;

      // 1. File Creator
      final fileCreator = FitFileCreator(localMessageType);
      body.output.addAll(fileCreator.binarySerialize());
      body.output.addAll(fileCreator.serializeData(exportModel));
      localMessageType++;

      // 2. Device Info
      final deviceInfo = FitDeviceInfo(localMessageType, productNameLength);
      body.output.addAll(deviceInfo.binarySerialize());
      body.output.addAll(deviceInfo.serializeData(exportModel));
      localMessageType++;
    }

    // 3. Activity
    final activity = FitActivity(localMessageType, exportModel.exportTarget);
    body.output.addAll(activity.binarySerialize());
    body.output.addAll(activity.serializeData(exportModel));
    localMessageType++;

    // 4. Session
    final session = FitSession(localMessageType, exportModel.exportTarget);
    body.output.addAll(session.binarySerialize());
    body.output.addAll(session.serializeData(exportModel));
    localMessageType++;

    // 5. Data Records
    final dataRecord = FitDataRecord(
      localMessageType,
      exportModel.altitude,
      heartRateGapWorkaround,
      heartRateUpperLimit,
      heartRateLimitingMethod,
    );
    body.output.addAll(dataRecord.binarySerialize());
    for (var record in exportModel.records) {
      body.output.addAll(dataRecord.serializeData(record));
    }

    localMessageType++;

    if (exportModel.exportTarget == ExportTarget.regular) {
      // 6. Sport
      final fitSport = FitSport(localMessageType);
      body.output.addAll(fitSport.binarySerialize());
      body.output.addAll(fitSport.serializeData(exportModel.activity.sport));
      localMessageType++;
    }

    final dataSize = body.output.length;
    List<int> bodyBytes = body.binarySerialize();
    final header = FitHeader(dataSize: dataSize);
    List<int> headerBytes = header.binarySerialize();

    return headerBytes + bodyBytes;
  }
}
