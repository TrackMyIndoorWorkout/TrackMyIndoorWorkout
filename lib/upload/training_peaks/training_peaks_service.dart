import '../../export/json/json_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'training_peaks.dart';

class TrainingPeaksService implements UploadService {
  TrainingPeaks _trainingPeaks = TrainingPeaks(TRAINING_PEAKS_CLIENT_ID, TRAINING_PEAKS_SECRET);

  Future<bool> login() async {
    return await _trainingPeaks.oauth(_trainingPeaks.clientId, _trainingPeaks.secret);
  }

  Future<bool> hasValidToken() async {
    return await _trainingPeaks.hasValidToken();
  }

  Future<int> deAuthorize() async {
    return await _trainingPeaks.deAuthorize(_trainingPeaks.clientId);
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.length <= 0) {
      return 404;
    }

    final exporter = JsonExport();
    final fileGzip = await exporter.getExport(activity, records, false, false);
    return await _trainingPeaks.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _trainingPeaks.clientId,
    );
  }
}
