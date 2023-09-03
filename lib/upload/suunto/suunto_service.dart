import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/isar/activity.dart';
import '../../persistence/isar/db_utils.dart';
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
  Future<int> upload(Activity activity, bool calculateGps) async {
    if (!DbUtils().hasRecords(activity.id)) {
      return 0;
    }

    final exporter = FitExport();
    final fileBytes = await exporter.getExport(
      activity,
      false,
      calculateGps,
      false,
      ExportTarget.suunto,
    );
    final statusCode = await _suunto.uploadActivity(activity, fileBytes, exporter);

    return statusCode;
  }
}
