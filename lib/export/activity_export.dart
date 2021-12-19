import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../track/calculator.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import 'export_model.dart';
import 'export_record.dart';

abstract class ActivityExport {
  final int major = 1;
  final int minor = 0;
  final String nonCompressedFileExtension;
  late String compressedFileExtension;
  final String nonCompressedMimeType;
  final String compressedMimeType = 'application/x-gzip';
  late String version;
  late String buildNumber;

  int _lastPositiveCadence = 0; // #101
  bool _cadenceGapWorkaround = CADENCE_GAP_WORKAROUND_DEFAULT;
  int _lastPositiveHeartRate = 0;
  String heartRateGapWorkaround = HEART_RATE_GAP_WORKAROUND_DEFAULT;
  int heartRateUpperLimit = HEART_RATE_UPPER_LIMIT_DEFAULT;
  String heartRateLimitingMethod = HEART_RATE_LIMITING_NO_LIMIT;

  ActivityExport({required this.nonCompressedFileExtension, required this.nonCompressedMimeType}) {
    compressedFileExtension = nonCompressedFileExtension + '.gz';
    final prefService = Get.find<BasePrefService>();
    _cadenceGapWorkaround =
        prefService.get<bool>(CADENCE_GAP_WORKAROUND_TAG) ?? CADENCE_GAP_WORKAROUND_DEFAULT;
    heartRateGapWorkaround =
        prefService.get<String>(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    heartRateUpperLimit =
        prefService.get<int>(HEART_RATE_UPPER_LIMIT_INT_TAG) ?? HEART_RATE_UPPER_LIMIT_DEFAULT;
    heartRateLimitingMethod =
        prefService.get<String>(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;

    final packageInfo = Get.find<PackageInfo>();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  String fileExtension(bool compressed) {
    return compressed ? compressedFileExtension : nonCompressedFileExtension;
  }

  String mimeType(bool compressed) {
    return compressed ? compressedMimeType : nonCompressedMimeType;
  }

  ExportRecord recordToExport(
    Record record,
    Activity activity,
    TrackCalculator calculator,
    bool rawData,
  ) {
    record.distance ??= 0.0;

    Offset gps = record.distance != null && !rawData
        ? calculator.gpsCoordinates(record.distance!)
        : const Offset(0, 0);

    if (!rawData && record.speed != null) {
      record.speed = record.speed! * DeviceDescriptor.kmh2ms;
    }

    return ExportRecord(record: record)
      ..longitude = gps.dx
      ..latitude = gps.dy;
  }

  Future<List<int>> getExport(
    Activity activity,
    List<Record> records,
    bool rawData,
    bool compress,
    int exportTarget,
  ) async {
    activity.hydrate();
    final descriptor = activity.deviceDescriptor();
    final track = getDefaultTrack(activity.sport);
    final calculator = TrackCalculator(track: track);
    final exportRecords = records.map((r) {
      final record = recordToExport(r, activity, calculator, rawData);

      if (!rawData) {
        if ((record.record.speed ?? 0.0) > EPS) {
          // #101, #122
          if ((record.record.cadence == null || record.record.cadence == 0) &&
              _lastPositiveCadence > 0 &&
              _cadenceGapWorkaround) {
            record.record.cadence = _lastPositiveCadence;
          } else if (record.record.cadence != null && record.record.cadence! > 0) {
            _lastPositiveCadence = record.record.cadence!;
          }
        }

        if (record.record.heartRate == null &&
            heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO) {
          record.record.heartRate = 0;
        }

        // #93, #113
        if ((record.record.heartRate == 0 || record.record.heartRate == null) &&
            _lastPositiveHeartRate > 0 &&
            heartRateGapWorkaround == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE) {
          record.record.heartRate = _lastPositiveHeartRate;
        } else if ((record.record.heartRate ?? 0) > 0) {
          _lastPositiveHeartRate = record.record.heartRate!;
        }

        // #114
        if (heartRateUpperLimit > 0 &&
            record.record.heartRate != null &&
            record.record.heartRate! > heartRateUpperLimit &&
            heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
          if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
            record.record.heartRate = heartRateUpperLimit;
          } else {
            record.record.heartRate = 0;
          }
        }
      }

      return record;
    }).toList(growable: false);
    final versionParts = version.split(".");
    ExportModel exportModel = ExportModel(
      activity: activity,
      rawData: rawData,
      descriptor: descriptor,
      author: 'Csaba Consulting',
      name: APP_NAME,
      swVersionMajor: versionParts[0],
      swVersionMinor: versionParts[1],
      buildVersionMajor: versionParts[2],
      buildVersionMinor: buildNumber,
      langID: 'en-US',
      partNumber: '0',
      altitude: calculator.track.altitude,
      exportTarget: exportTarget,
      records: exportRecords,
    );

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
}
