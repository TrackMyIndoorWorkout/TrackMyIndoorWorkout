import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../devices/device_map.dart';
import '../persistence/preferences.dart';
import '../track/calculator.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'export_model.dart';
import 'export_record.dart';

abstract class ActivityExport {
  final int major = 1;
  final int minor = 0;
  final String nonCompressedFileExtension;
  late String compressedFileExtension;
  final String nonCompressedMimeType;
  final String compressedMimeType = 'application/x-gzip';

  late int _lastPositiveCadence; // #101
  bool _cadenceGapWorkaround = CADENCE_GAP_WORKAROUND_DEFAULT;
  late int _lastPositiveHeartRate;
  String heartRateGapWorkaround = HEART_RATE_GAP_WORKAROUND_DEFAULT;
  int heartRateUpperLimit = HEART_RATE_UPPER_LIMIT_DEFAULT_INT;
  String heartRateLimitingMethod = HEART_RATE_LIMITING_NO_LIMIT;

  ActivityExport({required this.nonCompressedFileExtension, required this.nonCompressedMimeType}) {
    compressedFileExtension = nonCompressedFileExtension + '.gz';
    _lastPositiveCadence = 0;
    final prefService = Get.find<PrefServiceShared>().sharedPreferences;
    _cadenceGapWorkaround =
        prefService.getBool(CADENCE_GAP_WORKAROUND_TAG) ?? CADENCE_GAP_WORKAROUND_DEFAULT;
    _lastPositiveHeartRate = 0;
    heartRateGapWorkaround =
        prefService.getString(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    heartRateUpperLimit = getStringIntegerPreference(
      HEART_RATE_UPPER_LIMIT_TAG,
      HEART_RATE_UPPER_LIMIT_DEFAULT,
      HEART_RATE_UPPER_LIMIT_DEFAULT_INT,
      prefService,
    );
    heartRateLimitingMethod =
        prefService.getString(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;
  }

  String fileExtension(bool compressed) {
    return compressed ? compressedFileExtension : nonCompressedFileExtension;
  }

  String mimeType(bool compressed) {
    return compressed ? compressedMimeType : nonCompressedMimeType;
  }

  ExportRecord recordToExport(Record record, TrackCalculator calculator) {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(record.timeStamp ?? 0);
    if (record.distance == null) {
      record.distance = 0.0;
    }
    Offset gps = record.distance != null ? calculator.gpsCoordinates(record.distance!) : Offset(0, 0);
    return ExportRecord()
      ..longitude = gps.dx
      ..latitude = gps.dy
      ..timeStampString = timeStampString(timeStamp)
      ..timeStampInteger = timeStampInteger(timeStamp)
      ..altitude = calculator.track.altitude
      ..speed = (record.speed ?? 0.0) * DeviceDescriptor.KMH2MS
      ..distance = record.distance ?? 0.0
      ..date = timeStamp
      ..cadence = record.cadence ?? 0
      ..power = record.power?.toDouble() ?? 0.0
      ..heartRate = record.heartRate ?? 0;
  }

  Future<List<int>> getExport(Activity activity, List<Record> records, bool compress) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final descriptor = deviceMap[activity.fourCC] ?? genericDescriptorForSport(activity.sport);
    final track = getDefaultTrack(activity.sport);
    final calculator = TrackCalculator(track: track);
    final exportRecords = records.map((r) {
        final record = recordToExport(r, calculator);

        if (record.speed > EPS) {
          // #101, #122
          if ((record.cadence == null || record.cadence == 0) &&
              _lastPositiveCadence > 0 &&
              _cadenceGapWorkaround) {
            record.cadence = _lastPositiveCadence;
          } else if (record.cadence != null && record.cadence! > 0) {
            _lastPositiveCadence = record.cadence!;
          }
        }

        if (record.heartRate == null && heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO) {
          record.heartRate = 0;
        }
        // #93, #113
        if ((record.heartRate == 0 || record.heartRate == null) &&
            _lastPositiveHeartRate > 0 &&
            heartRateGapWorkaround == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE) {
          record.heartRate = _lastPositiveHeartRate;
        } else if (record.heartRate != null && record.heartRate! > 0) {
          _lastPositiveHeartRate = record.heartRate!;
        }
        // #114
        if (heartRateUpperLimit > 0 &&
            record.heartRate != null &&
            record.heartRate! > heartRateUpperLimit &&
            heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
          if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
            record.heartRate = heartRateUpperLimit;
          } else {
            record.heartRate = 0;
          }
        }

        return record;
      }).toList(growable: false);
    ExportModel exportModel = ExportModel(
      sport: activity.sport,
      totalDistance: activity.distance,
      totalTime: activity.elapsed.toDouble(),
      calories: activity.calories,
      dateActivity: startStamp,

      // Related to device that generated the data
      descriptor: descriptor,
      deviceId: activity.deviceId,
      versionMajor: major,
      versionMinor: minor,
      buildMajor: major,
      buildMinor: minor,

      // Related to software used to generate the TCX file
      author: 'Csaba Consulting',
      name: 'Track My Indoor Exercise',
      swVersionMajor: major,
      swVersionMinor: minor,
      buildVersionMajor: major,
      buildVersionMinor: minor,
      langID: 'en-US',
      partNumber: '0',
      records: exportRecords,);

    return await getFile(exportModel, compress);
  }

  Future<List<int>> getFile(ExportModel exportModel, bool compress) async {
    final fileBytes = await getFileCore(exportModel);
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

  Future<List<int>> getFileCore(ExportModel exportModel);

  String timeStampString(DateTime dateTime);

  int timeStampInteger(DateTime dateTime);
}
