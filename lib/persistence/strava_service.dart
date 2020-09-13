import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/strava.dart';
import 'activity.dart';
import 'secret.dart';

class StravaService {
  Strava _strava;
  StravaService() {
    _strava = Strava(kDebugMode, STRAVA_SECRET);
  }

  login() async {
    return await _strava.oauth(
        STRAVA_CLIENT_ID, 'activity:write', STRAVA_SECRET, 'auto');
  }

  Future<int> upload(Activity activity, String filePath) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);

    Fault fault = await _strava.uploadActivity(
        'Virtual velodrome ride at $dateString $timeString',
        'Virtual velodrome ride on a ${activity.deviceName}',
        filePath,
        'tcx');

    return fault.statusCode;
  }
}
