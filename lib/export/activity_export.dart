import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';

import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/activity.dart';
import '../persistence/db_utils.dart';
import '../persistence/record.dart';
import '../preferences/cadence_data_gap_workaround.dart';
import '../preferences/heart_rate_gap_workaround.dart';
import '../preferences/heart_rate_limiting.dart';
import '../track/calculator.dart';
import '../track/track_manager.dart';
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
  bool _cadenceGapWorkaround = cadenceGapWorkaroundDefault;
  int _lastPositiveHeartRate = 0;
  String heartRateGapWorkaround = heartRateGapWorkaroundDefault;
  int heartRateUpperLimit = heartRateUpperLimitDefault;
  String heartRateLimitingMethod = heartRateLimitingMethodDefault;

  ActivityExport({required this.nonCompressedFileExtension, required this.nonCompressedMimeType}) {
    compressedFileExtension = "$nonCompressedFileExtension.gz";
    final prefService = Get.find<BasePrefService>();
    _cadenceGapWorkaround =
        prefService.get<bool>(cadenceGapWorkaroundTag) ?? cadenceGapWorkaroundDefault;
    heartRateGapWorkaround =
        prefService.get<String>(heartRateGapWorkaroundTag) ?? heartRateGapWorkaroundDefault;
    heartRateUpperLimit =
        prefService.get<int>(heartRateUpperLimitIntTag) ?? heartRateUpperLimitDefault;
    heartRateLimitingMethod =
        prefService.get<String>(heartRateLimitingMethodTag) ?? heartRateLimitingMethodDefault;

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
    bool calculateGps,
    bool rawData,
  ) {
    record.distance ??= 0.0;

    if (!rawData && record.speed != null) {
      record.speed = record.speed! * DeviceDescriptor.kmh2ms;
    }

    final exportRecord = ExportRecord(record: record);
    if (record.distance != null && !rawData && calculateGps) {
      Offset gps = calculator.gpsCoordinates(record.distance!);
      exportRecord.longitude = gps.dx;
      exportRecord.latitude = gps.dy;
    }

    return exportRecord;
  }

  Future<List<int>> getExport(
    Activity activity,
    bool rawData,
    bool calculateGps,
    bool compress,
    int exportTarget,
  ) async {
    final descriptor = activity.deviceDescriptor();
    final track = await TrackManager().getTrack(activity.sport);
    final calculator = TrackCalculator(track: track);
    final records = await DbUtils().getRecords(activity.id);
    final List<ExportRecord> exportRecords = [];
    Record? previousRecord;
    for (final r in records) {
      List<Record> prepRecords = [];
      if (previousRecord != null && calculateGps) {
        if (previousRecord.distance != null && r.distance != null ||
            previousRecord.calories != null && r.calories != null) {
          final dTMillis = r.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
          if (dTMillis >= 2000) {
            final dividerCount = (dTMillis - 500) ~/ 1000;
            if (dividerCount > 0) {
              int time = previousRecord.timeStamp!.millisecondsSinceEpoch;
              int timePart = dTMillis ~/ (dividerCount + 1);
              double? dDistance =
                  (previousRecord.distance != null && r.distance != null)
                      ? r.distance! - previousRecord.distance!
                      : null;
              double? distancePart = dDistance != null ? dDistance / (dividerCount + 1) : null;
              double? distance = previousRecord.distance;
              int? dCaloriesInt =
                  (previousRecord.calories != null && r.calories != null)
                      ? r.calories! - previousRecord.calories!
                      : null;
              double? dCalories = dCaloriesInt?.toDouble();
              double? caloriesPart = dCalories != null ? dCalories / (dividerCount + 1) : null;
              double? calories = previousRecord.calories?.toDouble();
              int? dElapsed =
                  (previousRecord.elapsed != null && r.elapsed != null)
                      ? r.elapsed! - previousRecord.elapsed!
                      : null;
              int? elapsedPart = dElapsed != null ? dElapsed ~/ (dividerCount + 1) : null;
              int? elapsed = previousRecord.elapsed;
              for (final _ in List<int>.generate(dividerCount, (i) => i)) {
                time += timePart;
                final rClone = Record.clone(r);
                rClone.timeStamp = DateTime.fromMillisecondsSinceEpoch(time);
                if (elapsed != null && elapsedPart != null) {
                  elapsed += elapsedPart;
                  rClone.elapsed = elapsed;
                }

                if (distance != null && distancePart != null) {
                  distance += distancePart;
                  rClone.distance = distance;
                }

                if (calories != null && caloriesPart != null) {
                  calories += caloriesPart;
                  rClone.calories = calories.toInt();
                }

                prepRecords.add(rClone);
              }
            }
          }
        }
      }

      prepRecords.add(r);

      for (final prepRecord in prepRecords) {
        final record = recordToExport(prepRecord, activity, calculator, calculateGps, rawData);

        if (!rawData) {
          if ((record.record.speed ?? 0.0) > eps) {
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
              heartRateLimitingMethod == heartRateLimitingWriteZero) {
            record.record.heartRate = 0;
          }

          // #93, #113
          if ((record.record.heartRate == 0 || record.record.heartRate == null) &&
              _lastPositiveHeartRate > 0 &&
              heartRateGapWorkaround == dataGapWorkaroundLastPositiveValue) {
            record.record.heartRate = _lastPositiveHeartRate;
          } else if ((record.record.heartRate ?? 0) > 0) {
            _lastPositiveHeartRate = record.record.heartRate!;
          }

          // #114
          if (heartRateUpperLimit > 0 &&
              record.record.heartRate != null &&
              record.record.heartRate! > heartRateUpperLimit &&
              heartRateLimitingMethod != heartRateLimitingNoLimit) {
            if (heartRateLimitingMethod == heartRateLimitingCapAtLimit) {
              record.record.heartRate = heartRateUpperLimit;
            } else {
              record.record.heartRate = 0;
            }
          }
        }

        exportRecords.add(record);
      }

      previousRecord = r;
    }

    final versionParts = version.split(".");
    ExportModel exportModel = ExportModel(
      activity: activity,
      rawData: rawData,
      calculateGps: calculateGps,
      descriptor: descriptor,
      author: 'Csaba Consulting',
      name: appName,
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

  Future<List<int>> getFileCore(ExportModel exportModel);
}
