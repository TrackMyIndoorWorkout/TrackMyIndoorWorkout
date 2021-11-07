import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'strava_status_code.dart';
import 'fault.dart';
import 'strava.dart';

class StravaService implements UploadService {
  final Strava _strava = Strava(STRAVA_CLIENT_ID, STRAVA_SECRET);

  @override
  Future<bool> login() async {
    return await _strava.oauth(_strava.clientId, 'activity:write', _strava.secret, 'auto');
  }

  @override
  Future<bool> hasValidToken() async {
    return await _strava.hasValidToken();
  }

  @override
  Future<int> logout() async {
    Fault fault = await _strava.deAuthorize();

    return fault.statusCode;
  }

  @override
  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.isEmpty) {
      return StravaStatusCode.statusJsonIsEmpty;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(
      activity,
      records,
      false,
      true,
      ExportTarget.regular,
    );
    Fault fault = await _strava.uploadActivity(activity, fileGzip, exporter);

    return fault.statusCode;
  }
}
