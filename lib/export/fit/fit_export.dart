import 'package:tuple/tuple.dart';

import '../activity_export.dart';
import '../export_model.dart';
import '../export_record.dart';
import '../export_target.dart';
import 'definitions/fit_activity.dart';
import 'definitions/fit_data_record.dart';
import 'definitions/fit_device_info.dart';
import 'definitions/fit_event.dart';
import 'definitions/fit_file_creator.dart';
import 'definitions/fit_file_id.dart';
import 'definitions/fit_lap.dart';
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
    // 0. File ID
    final fileId = FitFileId(localMessageType, exportModel.exportTarget, productNameLength);
    body.output.addAll(fileId.binarySerialize());
    body.output.addAll(fileId.serializeData(exportModel));
    localMessageType++;

    if (exportModel.exportTarget == ExportTarget.regular) {
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

      // 3. Activity
      final activity = FitActivity(localMessageType, exportModel.exportTarget);
      body.output.addAll(activity.binarySerialize());
      body.output.addAll(activity.serializeData(exportModel));
      localMessageType++;

      // 4. Session
      final session = FitSession(
        localMessageType,
        exportModel.altitude,
        exportModel.exportTarget,
      );
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
        exportModel.calculateGps,
      );
      body.output.addAll(dataRecord.binarySerialize());
      for (var record in exportModel.records) {
        body.output.addAll(dataRecord.serializeData(record));
      }

      localMessageType++;

      // 6. Sport
      final fitSport = FitSport(localMessageType);
      body.output.addAll(fitSport.binarySerialize());
      body.output.addAll(fitSport.serializeData(exportModel.activity.sport));
      localMessageType++;
    } else {
      // 1. Data Records
      final dataRecord = FitDataRecord(
        localMessageType,
        exportModel.altitude,
        heartRateGapWorkaround,
        heartRateUpperLimit,
        heartRateLimitingMethod,
        exportModel.calculateGps,
      );
      body.output.addAll(dataRecord.binarySerialize());
      for (var record in exportModel.records) {
        body.output.addAll(dataRecord.serializeData(record));
      }

      localMessageType++;

      // 2. Event
      final event = FitEvent(localMessageType);
      body.output.addAll(event.binarySerialize());
      body.output
          .addAll(event.serializeData(Tuple2<bool, ExportRecord>(true, exportModel.records.first)));
      body.output
          .addAll(event.serializeData(Tuple2<bool, ExportRecord>(false, exportModel.records.last)));
      localMessageType++;

      // 3. Lap
      final lap = FitLap(
        localMessageType,
        exportModel.altitude,
        exportModel.exportTarget,
      );
      body.output.addAll(lap.binarySerialize());
      body.output.addAll(lap.serializeData(exportModel));
      localMessageType++;

      // 4. Session
      final session = FitSession(
        localMessageType,
        exportModel.altitude,
        exportModel.exportTarget,
      );
      body.output.addAll(session.binarySerialize());
      body.output.addAll(session.serializeData(exportModel));
      localMessageType++;

      // 5. Activity
      final activity = FitActivity(localMessageType, exportModel.exportTarget);
      body.output.addAll(activity.binarySerialize());
      body.output.addAll(activity.serializeData(exportModel));
      localMessageType++;
    }

    final dataSize = body.output.length;
    List<int> bodyBytes = body.binarySerialize();
    final header = FitHeader(dataSize: dataSize);
    List<int> headerBytes = header.binarySerialize();

    return headerBytes + bodyBytes;
  }
}
