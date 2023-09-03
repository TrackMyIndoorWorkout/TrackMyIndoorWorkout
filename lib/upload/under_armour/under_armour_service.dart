import '../../export/export_target.dart';
import '../../export/json/json_export.dart';
import '../../persistence/isar/activity.dart';
import '../../persistence/isar/db_utils.dart';
import '../../secret.dart';
import '../upload_service.dart';
import 'under_armour.dart';

class UnderArmourService implements UploadService {
  final UnderArmour _underArmour = UnderArmour(underArmourKey, underArmourSecret);

  @override
  Future<bool> login() async {
    return await _underArmour.oauth(_underArmour.clientId, _underArmour.secret);
  }

  @override
  Future<bool> hasValidToken() async {
    return await _underArmour.hasValidToken();
  }

  @override
  Future<int> logout() async {
    return await _underArmour.deAuthorize(_underArmour.clientId);
  }

  @override
  Future<int> upload(Activity activity, bool calculateGps) async {
    if (!DbUtils().hasRecords(activity.id)) {
      return 404;
    }

    final exporter = JsonExport();
    final fileGzip = await exporter.getExport(
      activity,
      false,
      calculateGps,
      true,
      ExportTarget.regular,
    );
    return await _underArmour.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _underArmour.clientId,
    );
  }
}
