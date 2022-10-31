import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/floor/models/activity.dart';
import '../../persistence/floor/models/record.dart';
import '../../secret.dart';
import '../upload_service.dart';
import 'suunto.dart';

class SuuntoService implements UploadService {
  final Suunto _suunto = Suunto(
    suuntoClientId,
    suuntoSecret,
    suuntoSubscriptionPrimaryKey,
  );

  @override
  Future<bool> login() async {
    return await _suunto.oauth(_suunto.clientId, _suunto.secret, _suunto.subscriptionKey);
  }

  @override
  Future<bool> hasValidToken() async {
    return await _suunto.hasValidToken();
  }

  @override
  Future<int> logout() async {
    bool fault = await _suunto.deAuthorize(_suunto.clientId, _suunto.subscriptionKey);

    return fault ? 1 : 0;
  }

  @override
  Future<int> upload(Activity activity, List<Record> records, bool calculateGps) async {
    if (records.isEmpty) {
      return 0;
    }

    final exporter = FitExport();
    final fileBytes = await exporter.getExport(
      activity,
      records,
      false,
      calculateGps,
      false,
      ExportTarget.suunto,
    );
    final statusCode = await _suunto.uploadActivity(activity, fileBytes, exporter);

    return statusCode;
  }
}
