import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:pref/pref.dart';

import '../../export/activity_export.dart';
import '../../persistence/activity.dart';
import '../../preferences/training_peaks_upload_public.dart';
import '../../utils/constants.dart';
import 'constants.dart';
import 'training_peaks_token.dart';

mixin Upload {
  String trainingPeaksSport(String sport) {
    if (sport == ActivityType.canoeing || sport == ActivityType.kayaking) {
      sport = "Rowing";
    } else if (sport == ActivityType.ride) {
      sport = "Bike";
    } else if (sport == ActivityType.elliptical) {
      sport = "X-train";
    } else if (sport == ActivityType.nordicSki) {
      sport = "XC-ski";
    } else if (sport != ActivityType.swim &&
        sport != ActivityType.rowing &&
        sport != ActivityType.run) {
      sport = "Other";
    }

    return sport;
  }

  /// statusCode:
  /// 201 activity created
  /// 400 problem could be that activity already uploaded
  ///
  Future<int> uploadActivity(
    Activity activity,
    List<int> fileContent,
    ActivityExport exporter,
    String clientId,
  ) async {
    debugPrint('Starting to upload activity');

    if (!Get.isRegistered<TrainingPeaksToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final trainingPeaksToken = Get.find<TrainingPeaksToken>();
    final headers = trainingPeaksToken.getAuthorizationHeader();

    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 401;
    }

    headers.addAll({
      "Accept": "application/json",
      "Accept-Encoding": "gzip",
      "Content-Type": "application/json",
      "User-Agent": "$clientId/1.0",
    });

    final prefService = Get.find<BasePrefService>();
    final workoutPublic =
        prefService.get<bool>(trainingPeaksUploadPublicTag) ?? trainingPeaksUploadPublicDefault;
    final fileName = activity.getFileNameStub() + exporter.fileExtension(true);
    final fileContentString = base64.encode(fileContent);

    final payload = {
      "UploadClient": appName,
      "Filename": fileName,
      "Data": fileContentString,
      "Title": activity.getTitle(false),
      "Comment": activity.getDescription(false),
      "WorkoutDay": DateFormat('yyyy-MM-dd').format(activity.start),
      "StartTime": DateFormat('yyyy-MM-ddTHH:mm:ss').format(activity.start),
      "SetWorkoutPublic": workoutPublic,
      "Type": trainingPeaksSport(activity.sport),
    };
    final contentString = jsonEncode(payload);

    const uploadUrl = tpProductionApiUrlBase + uploadPath;
    final uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: headers,
      body: contentString,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      debugPrint('Error while uploading the activity to TrainingPeaks');
      return uploadResponse.statusCode;
    }

    if (!uploadResponse.headers.containsKey("location")) {
      // Direct success without async location polling
      return uploadResponse.statusCode;
    }

    final statusUrl = uploadResponse.headers["location"]!;
    final fileTrackingUuid = statusUrl.split("/").last;
    debugPrint('trackingUUID $fileTrackingUuid');
    if (fileTrackingUuid.isEmpty) {
      return uploadResponse.statusCode;
    }

    activity.markTrainingPeaksUploading(fileTrackingUuid);
    if (Get.isRegistered<Isar>()) {
      final database = Get.find<Isar>();
      database.writeTxnSync(() {
        database.activitys.putSync(activity);
      });
    }

    final uploadStatusUrl = tpProductionApiUrlBase + uploadStatusPath + fileTrackingUuid;
    final uri = Uri.parse(uploadStatusUrl);
    const maxPollAttempts = 10;
    int attempts = 0;
    bool processingFinished = false;

    while (!processingFinished && attempts < maxPollAttempts) {
      attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final resp = await http.get(uri, headers: headers);
      debugPrint('Check Status ${resp.statusCode} (attempt $attempts/$maxPollAttempts)');

      if (resp.statusCode == 404) {
        // The temp tracking id no longer exists (activity finished ingestion or expired)
        debugPrint('---> 404 activity already processed or expired: ${resp.reasonPhrase}');
        processingFinished = true;
        break;
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          final dynamic decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            final completedVal = decoded['Completed'] ?? decoded['completed'];
            final completed =
                completedVal == true || completedVal?.toString().toLowerCase() == 'true';
            final status = (decoded['Status'] ?? decoded['status'])?.toString();
            debugPrint('---> Completed: $completed, Status: $status');

            if (completed) {
              processingFinished = true;
              final rawWorkoutIds = decoded['WorkoutIds'] ?? decoded['workoutIds'];
              List<int> workoutIds = [];
              if (rawWorkoutIds is List) {
                workoutIds = rawWorkoutIds
                    .map((id) => int.tryParse(id.toString()))
                    .nonNulls
                    .toList(growable: false);
              }
              debugPrint('---> Workout IDs: $workoutIds');
              if (workoutIds.isNotEmpty) {
                activity.markTrainingPeaksUploaded(workoutIds.first);
                if (Get.isRegistered<Isar>()) {
                  final database = Get.find<Isar>();
                  database.writeTxnSync(() {
                    database.activitys.putSync(activity);
                  });
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error parsing TrainingPeaks status JSON: $e, body: ${resp.body}');
        }
      } else {
        debugPrint('Unexpected status code during TrainingPeaks polling: ${resp.statusCode}');
        break;
      }
    }

    if (!activity.trainingPeaksUploaded && !processingFinished) {
      // Ingestion timed out or failed; clear in-flight state to prevent retry deadlocks
      activity.clearTrainingPeaksUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
      return 408; // Request Timeout
    }

    return uploadResponse.statusCode;
  }
}
