import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
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
    String fileContentString = base64.encode(fileContent);
    String contentString =
        '{"UploadClient": "$appName",'
        '"Filename": "$fileName",'
        '"Data": "$fileContentString",'
        '"Title": "${activity.getTitle(false)}",'
        '"Comment": "${activity.getDescription(false)}",'
        '"WorkoutDay": "${DateFormat('yyyy-MM-dd').format(activity.start)}",'
        '"StartTime": "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(activity.start)}",'
        '"SetWorkoutPublic": $workoutPublic,'
        '"Type": "${trainingPeaksSport(activity.sport)}"}';
    const uploadUrl = tpProductionApiUrlBase + uploadPath;
    final uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: headers,
      body: contentString,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      // response.statusCode != 202 // the new async endpoint should return 202 and a fileTrackingId
      debugPrint('Error while uploading the activity');
    } else {
      // Upload is processed by the server
      // now wait for the upload to be finished
      //----------------------------------------
      if (!uploadResponse.headers.containsKey("location")) {
        // Why didn't we get a status check URL?
        return uploadResponse.statusCode;
      }

      final statusUrl = uploadResponse.headers["location"]!;
      final fileTrackingUuid = statusUrl.split("/").last;
      debugPrint('trackingUUID $fileTrackingUuid');
      if (fileTrackingUuid.isNotEmpty) {
        activity.markTrainingPeaksUploading(fileTrackingUuid);
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });

        await Future<void>.delayed(const Duration(milliseconds: 500));

        final uploadStatusUrl = tpProductionApiUrlBase + uploadStatusPath + fileTrackingUuid;
        final uri = Uri.parse(uploadStatusUrl);
        bool processingFinished = false;
        while (!processingFinished) {
          final resp = await http.get(uri, headers: headers);
          debugPrint('Check Status ${resp.statusCode}');

          // Everything is fine the file has been loaded
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            // resp.statusCode == 200
            debugPrint('Check Body: ${resp.body}');
          }

          // 404 the temp id does not exist anymore
          // Activity has been probably already loaded
          if (resp.statusCode == 404) {
            debugPrint('---> 404 activity already loaded  ${resp.reasonPhrase}');
            processingFinished = true;
          } else {
            final processingBody = resp.body;
            const completedTag = '"Completed":';
            int completedBeginningIndex = processingBody.indexOf(completedTag);
            if (completedBeginningIndex > 0) {
              int beginningIndex = completedBeginningIndex + completedTag.length;
              int completedEndIndex = processingBody.indexOf(',', beginningIndex);
              if (completedEndIndex > 0) {
                final completedString = processingBody.substring(beginningIndex, completedEndIndex);
                final completed = completedString.toLowerCase() == "true";
                debugPrint('---> Completed  $completed');
                processingFinished = completed;
                const statusTag = '"Status":';
                int statusBeginningIndex = processingBody.indexOf(statusTag);
                if (statusBeginningIndex > 0) {
                  beginningIndex = statusBeginningIndex + statusTag.length;
                  final statusEndIndex = processingBody.indexOf(',', statusBeginningIndex);
                  if (statusEndIndex > 0) {
                    final statusString = processingBody.substring(beginningIndex, statusEndIndex);
                    debugPrint('---> Status  $statusString');
                  }
                }

                const workoutIdsTag = '"WorkoutIds":[';
                int workoutBeginningIndex = processingBody.indexOf(workoutIdsTag);
                if (workoutBeginningIndex > 0) {
                  beginningIndex = workoutBeginningIndex + workoutIdsTag.length;
                  int workoutIdsEndIndex = processingBody.indexOf(']', beginningIndex);
                  if (workoutIdsEndIndex > 0) {
                    final workoutIdsString = processingBody.substring(
                      beginningIndex,
                      workoutIdsEndIndex,
                    );
                    debugPrint('---> Workout IDs  $workoutIdsString');
                    final workoutIds = workoutIdsString
                        .split(",")
                        .map((workoutIdString) => int.tryParse(workoutIdString))
                        .nonNulls
                        .toList(growable: false);
                    if (workoutIds.isNotEmpty) {
                      activity.markTrainingPeaksUploaded(workoutIds.first);
                      database.writeTxnSync(() {
                        database.activitys.putSync(activity);
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return uploadResponse.statusCode;
  }
}
