import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'under_armour_status_code.dart';
import 'fault.dart';
import 'under_armour.dart';

class UnderArmourService implements UploadService {
  UnderArmour _underArmour = UnderArmour(UNDER_ARMOUR_KEY, UNDER_ARMOUR_SECRET);

  Future<bool> login() async {
    return await _underArmour.oauth(_underArmour.clientId, _underArmour.secret);
  }

  Future<bool> hasValidToken() async {
    return await _underArmour.hasValidToken();
  }

  Future<int> deAuthorize() async {
    Fault fault = await _underArmour.deAuthorize(_underArmour.clientId);

    return fault.statusCode;
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.length <= 0) {
      return UnderArmourStatusCode.statusJsonIsEmpty;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(activity, records, false, true);
    Fault fault = await _underArmour.uploadActivity(
      activity,
      fileGzip,
      exporter,
      _underArmour.clientId,
    );

    return fault.statusCode;
  }
}
