import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'training_peaks.dart';

class TrainingPeaksService implements UploadService {
  final TrainingPeaks _trainingPeaks = TrainingPeaks(trainingPeaksClientId, trainingPeaksSecret);

  @override
  Future<bool> login() async {
    return await _trainingPeaks.oauth(_trainingPeaks.clientId, _trainingPeaks.secret, 'file:write');
  }

  @override
  Future<bool> hasValidToken() async {
    return await _trainingPeaks.hasValidToken();
  }

  @override
  Future<int> logout() async {
    bool fault = await _trainingPeaks.deAuthorize();

    return fault ? 1 : 0;
  }

  @override
  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.isEmpty) {
      return 404;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(
      activity,
      records,
      false,
      true,
      ExportTarget.regular,
    );
    return await _trainingPeaks.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _trainingPeaks.clientId,
    );
  }
}
