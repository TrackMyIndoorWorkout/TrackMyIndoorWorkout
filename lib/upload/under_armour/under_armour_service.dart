import '../../export/json/json_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'under_armour.dart';

class UnderArmourService implements UploadService {
  final UnderArmour _underArmour = UnderArmour(UNDER_ARMOUR_KEY, UNDER_ARMOUR_SECRET);

  @override
  Future<bool> login() async {
    return await _underArmour.oauth(_underArmour.clientId, _underArmour.secret);
  }

  @override
  Future<bool> hasValidToken() async {
    return await _underArmour.hasValidToken();
  }

  @override
  Future<int> deAuthorize() async {
    return await _underArmour.deAuthorize(_underArmour.clientId);
  }

  @override
  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.isEmpty) {
      return 404;
    }

    final exporter = JsonExport();
    final fileGzip = await exporter.getExport(activity, records, false, true);
    return await _underArmour.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _underArmour.clientId,
    );
  }
}
