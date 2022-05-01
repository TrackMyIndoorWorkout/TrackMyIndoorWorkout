import '../../export/export_target.dart';
import '../../export/json/json_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../secret.dart';
import '../upload_service.dart';
import 'google_fit.dart';

class GoogleFitService implements UploadService {
  final GoogleFit _googleFit = GoogleFit(googleFitClientId, googleFitSecret);

  @override
  Future<bool> login() async {
    return await _googleFit.oauth(_googleFit.clientId, _googleFit.secret);
  }

  @override
  Future<bool> hasValidToken() async {
    return await _googleFit.hasValidToken();
  }

  @override
  Future<int> logout() async {
    return await _googleFit.deAuthorize(_googleFit.clientId);
  }

  @override
  Future<int> upload(Activity activity, List<Record> records, bool calculateGps) async {
    if (records.isEmpty) {
      return 404;
    }

    final exporter = JsonExport();
    final fileGzip = await exporter.getExport(
      activity,
      records,
      false,
      calculateGps,
      true,
      ExportTarget.regular,
    );
    return await _googleFit.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _googleFit.clientId,
    );
  }
}
