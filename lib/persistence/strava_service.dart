import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/strava.dart';
import 'package:rw_tcx/models/TCXModel.dart';
import 'package:rw_tcx/wTCX.dart';
import 'package:virtual_velodrome_rider/track/constants.dart';
import '../devices/devices.dart';
import 'activity.dart';
import 'record.dart';
import 'secret.dart';

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
      ..cadence = record.cadence.toDouble()
      ..power = record.power.toDouble()
      ..heartRate = record.heartRate;
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);

    TCXModel tcxInfo = TCXModel()
      ..activityType = "Virtual bicycle"
      ..totalDistance = activity.distance
      ..totalTime = activity.elapsed.toDouble()
      ..maxSpeed = activity.maxSpeed // in m/s
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

    await writeTCX(tcxInfo, 'generatedSample.tcx');

    Fault fault = await _strava.uploadActivity(
        'Virtual velodrome ride at $dateString $timeString',
        'Virtual velodrome ride on a ${activity.deviceName}',
        'filePath', // TODO
        'tcx');

    return fault.statusCode;
  }
}
