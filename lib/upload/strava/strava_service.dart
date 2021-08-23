import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import '../upload_service.dart';
import 'strava_status_code.dart';
import 'fault.dart';
import 'strava.dart';

class StravaService implements UploadService {
  Strava _strava = Strava(STRAVA_CLIENT_ID, STRAVA_SECRET);

  Future<bool> login() async {
    return await _strava.oauth(_strava.clientId, 'activity:write', _strava.secret, 'auto');
  }

  Future<bool> hasValidToken() async {
    return await _strava.hasValidToken();
  }

  Future<int> deAuthorize() async {
    Fault fault = await _strava.deAuthorize();

    return fault.statusCode;
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.length <= 0) {
      return StravaStatusCode.statusJsonIsEmpty;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(activity, records, false, true);
    Fault fault = await _strava.uploadActivity(activity, fileGzip, exporter);

    return fault.statusCode;
  }
}
