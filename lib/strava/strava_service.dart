import 'package:flutter/foundation.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/secret.dart';
import '../strava/error_codes.dart';
import '../tcx/tcx_output.dart';
import 'fault.dart';
import 'strava.dart';

class StravaService {
  Strava _strava;
  StravaService() {
    _strava = Strava(kDebugMode, STRAVA_SECRET);
  }

  login() async {
    return await _strava.oauth(
        STRAVA_CLIENT_ID, 'activity:write', STRAVA_SECRET, 'auto');
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records == null || records.length <= 0) {
      return statusJsonIsEmpty;
    }

    final tcxGzip = await TCXOutput().getTcxOfActivity(activity, records);
    Fault fault = await _strava.uploadActivity(
      activity,
      tcxGzip,
    );

    return fault.statusCode;
  }
}
