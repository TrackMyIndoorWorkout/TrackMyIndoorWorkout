import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../devices/devices.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/secret.dart';
import '../tcx/activity_type.dart';
import '../tcx/tcx_model.dart';
import '../tcx/tcx_output.dart';
import '../track/constants.dart';
import 'fault.dart';
import 'strava.dart';

class StravaService {
  static const MAJOR = '1';
  static const MINOR = '0';

  Strava _strava;
  StravaService() {
    _strava = Strava(kDebugMode, STRAVA_SECRET);
  }

  login() async {
    return await _strava.oauth(
        STRAVA_CLIENT_ID, 'activity:write', STRAVA_SECRET, 'auto');
  }

  TrackPoint recordToTrackPoint(Record record) {
    return TrackPoint()
      ..latitude = record.lat
      ..longitude = record.lon
      // ..timeStamp = record.timeStamp // TODO
      ..altitude = TRACK_ALTITUDE
      ..speed = record.speed
      ..distance = record.distance
      ..date = DateTime.fromMillisecondsSinceEpoch(record.timeStamp)
      ..cadence = record.cadence
      ..power = record.power.toDouble()
      ..heartRate = record.heartRate;
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);

    TCXModel tcxInfo = TCXModel()
      ..activityType = ActivityType.VirtualRide
      ..totalDistance = activity.distance
      ..totalTime = activity.elapsed.toDouble()
      ..calories = activity.calories
      ..dateActivity = startStamp

      // Related to device that generated the data
      ..creator = 'Precor'
      ..deviceName = devices[0].fullName
      ..unitID = activity.deviceId
      ..productID = devices[0].sku
      ..versionMajor = MAJOR
      ..versionMinor = MINOR
      ..buildMajor = MAJOR
      ..buildMinor = MINOR

      // Related to software used to generate the TCX file
      ..author = 'Csaba Consulting'
      ..name = 'Virtual Velodrome Rider'
      ..swVersionMajor = MAJOR
      ..swVersionMinor = MINOR
      ..buildVersionMajor = MAJOR
      ..buildVersionMinor = MINOR
      ..langID = 'en-US'
      ..partNumber = '0'
      ..points = records.map((r) => recordToTrackPoint(r)).toList();

    final tcxGzip = await TCXOutput().getTCX(tcxInfo);

    Fault fault = await _strava.uploadActivity(
      'Virtual velodrome ride at $dateString $timeString',
      'Virtual velodrome ride on a ${activity.deviceName}',
      'ERide$dateString-$timeString.gpx.gz',
      'gpx.gz',
      tcxGzip,
    );

    return fault.statusCode;
  }
}
