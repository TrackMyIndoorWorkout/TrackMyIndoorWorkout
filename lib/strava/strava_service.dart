import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/secret.dart';
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
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);

    final tcxGzip = await TCXOutput().getTcxOfActivity(activity, records);

    Fault fault = await _strava.uploadActivity(
      'Virtual velodrome ride at $dateString $timeString',
      'Virtual velodrome ride on a ${activity.deviceName}',
      'ERide_${dateString}_$timeString.gpx.gz'
          .replaceAll('/', '-')
          .replaceAll(':', '-'),
      'gpx.gz',
      tcxGzip,
    );

    return fault.statusCode;
  }
}
