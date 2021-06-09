import '../export/fit/fit_export.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/secret.dart';
import '../strava/strava_status_code.dart';
import 'fault.dart';
import 'strava.dart';

class StravaService {
  Strava _strava = Strava(STRAVA_SECRET);

  Future<bool> login() async {
    return await _strava.oauth(STRAVA_CLIENT_ID, 'activity:write', STRAVA_SECRET, 'auto');
  }

  Future<bool> hasValidToken() async {
    return await _strava.hasValidToken();
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.length <= 0) {
      return StravaStatusCode.statusJsonIsEmpty;
    }

    final exporter = FitExport();
    final fileGzip = await exporter.getExport(activity, records, true);
    Fault fault = await _strava.uploadActivity(activity, fileGzip, exporter);

    return fault.statusCode;
  }
}
