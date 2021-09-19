import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'suunto.dart';

class SuuntoService implements UploadService {
  final Suunto _suunto = Suunto(SUUNTO_CLIENT_ID, SUUNTO_SECRET);

  @override
  Future<bool> login() async {
    return await _suunto.oauth(_suunto.clientId, _suunto.secret);
  }

  @override
  Future<bool> hasValidToken() async {
    return await _suunto.hasValidToken();
  }

  @override
  Future<int> deAuthorize() async {
    bool fault = await _suunto.deAuthorize(_suunto.clientId);

    return fault ? 1 : 0;
  }

  @override
  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.isEmpty) {
      return 0;
    }

    final exporter = FitExport();
    final file = await exporter.getExport(activity, records, false, false);
    final statusCode = await _suunto.uploadActivity(activity, file, exporter);

    return statusCode;
  }
}
