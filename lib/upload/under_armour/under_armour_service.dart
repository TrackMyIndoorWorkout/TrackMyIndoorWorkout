import '../../export/export_target.dart';
import '../../export/json/json_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
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
    return await _underArmour.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _underArmour.clientId,
    );
  }
}
