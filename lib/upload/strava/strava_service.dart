import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/activity.dart';
import '../../persistence/db_utils.dart';
import '../../secret.dart';
import '../upload_service.dart';
import 'fault.dart';
import 'strava.dart';
import 'strava_status_code.dart';

class StravaService implements UploadService {
  final Strava _strava = Strava(stravaClientId, stravaSecret);

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
  Future<int> upload(Activity activity, bool calculateGps) async {
    if (!DbUtils().hasRecords(activity.id)) {
      return StravaStatusCode.statusJsonIsEmpty;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(
      activity,
      false,
      calculateGps,
      true,
      ExportTarget.regular,
    );
    Fault fault = await _strava.uploadActivity(activity, fileGzip, exporter);

    return fault.statusCode;
  }
}
