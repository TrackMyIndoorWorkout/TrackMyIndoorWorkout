import 'dart:io';

import 'package:intl/intl.dart';
import 'package:preferences/preferences.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../devices/device_map.dart';
import '../persistence/preferences.dart';
import '../track/calculator.dart';
import '../track/tracks.dart';
import '../utils/display.dart';
import 'export_model.dart';
import 'export_record.dart';

abstract class ActivityExport {
  static const MAJOR = '1';
  static const MINOR = '0';
  static String nonCompressedFileExtension = '';
  static String compressedFileExtension = nonCompressedFileExtension + '.gz';
  static String nonCompressedMimeType;
  static String compressedMimeType;

  String heartRateGapWorkaround = HEART_RATE_GAP_WORKAROUND_DEFAULT;
  int heartRateUpperLimit = HEART_RATE_UPPER_LIMIT_DEFAULT_INT;
  String heartRateLimitingMethod = HEART_RATE_LIMITING_NO_LIMIT;

  ActivityExport() {
    heartRateGapWorkaround =
        PrefService.getString(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    final heartRateUpperLimitString =
        PrefService.getString(HEART_RATE_UPPER_LIMIT_TAG) ?? HEART_RATE_UPPER_LIMIT_DEFAULT;
    heartRateUpperLimit = int.tryParse(heartRateUpperLimitString);
    heartRateLimitingMethod =
        PrefService.getString(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;
  }

  String fileExtension(bool compressed) {
    return compressed ? compressedFileExtension : nonCompressedFileExtension;
  }

  String mimeType(bool compressed) {
    return compressed ? compressedMimeType : nonCompressedMimeType;
  }

  ExportRecord recordToExport(Record record, TrackCalculator calculator) {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(record.timeStamp);
    if (record.distance == null) {
      record.distance = 0.0;
    }
    final gps = calculator.gpsCoordinates(record.distance);
    return ExportRecord()
      ..longitude = gps.dx
      ..latitude = gps.dy
      ..timeStampString = timeStampString(timeStamp)
      ..timeStampInteger = timeStampInteger(timeStamp)
      ..altitude = calculator.track.altitude
      ..speed = record.speed * DeviceDescriptor.KMH2MS
      ..distance = record.distance
      ..date = timeStamp
      ..cadence = record.cadence
      ..power = record.power.toDouble()
      ..heartRate = record.heartRate;
  }

  Future<List<int>> getExport(Activity activity, List<Record> records, bool compress) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final descriptor = deviceMap[activity.fourCC];
    final track = getDefaultTrack(activity.sport);
    final calculator = TrackCalculator(track: track);
    ExportModel exportModel = ExportModel()
      ..activityType = tcxSport(activity.sport)
      ..totalDistance = activity.distance
      ..totalTime = activity.elapsed.toDouble()
      ..calories = activity.calories
      ..dateActivity = startStamp

      // Related to device that generated the data
      ..creator = descriptor.vendorName
      ..deviceName = descriptor.fullName
      ..unitID = activity.deviceId
      ..productID = descriptor.modelName
      ..versionMajor = MAJOR
      ..versionMinor = MINOR
      ..buildMajor = MAJOR
      ..buildMinor = MINOR

      // Related to software used to generate the TCX file
      ..author = 'Csaba Consulting'
      ..name = 'Track My Indoor Exercise'
      ..swVersionMajor = MAJOR
      ..swVersionMinor = MINOR
      ..buildVersionMajor = MAJOR
      ..buildVersionMinor = MINOR
      ..langID = 'en-US'
      ..partNumber = '0'
      ..points = records.map((r) => recordToExport(r, calculator)).toList(growable: false);

    return await getFile(exportModel, compress);
  }

  Future<List<int>> getFile(ExportModel tcxInfo, bool compress) async {
    final fileBytes = await getFileCore(tcxInfo);
    if (!compress) {
      return fileBytes;
    }
    return GZipCodec(gzip: true).encode(fileBytes);
  }

  Map<String, dynamic> getPersistenceValues(Activity activity, bool compressed) {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);
    final fileName = 'Activity_${dateString}_$timeString.${fileExtension(compressed)}'
        .replaceAll('/', '-')
        .replaceAll(':', '-');
    return {
      'startStamp': startStamp,
      'name': '${activity.sport} at $dateString $timeString',
      'description': '${activity.sport} by ${activity.deviceName}',
      'fileName': fileName,
    };
  }

  Future<List<int>> getFileCore(ExportModel tcxInfo);

  String timeStampString(DateTime dateTime);

  int timeStampInteger(DateTime dateTime);
}
