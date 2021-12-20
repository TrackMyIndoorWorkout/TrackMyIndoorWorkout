import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../export/activity_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/database.dart';
import '../../utils/constants.dart';

import 'constants.dart';
import 'training_peaks_token.dart';

abstract class Upload {
  String trainingPeaksSport(String sport) {
    if (sport == ActivityType.canoeing || sport == ActivityType.kayaking) {
      sport = "Rowing";
    } else if (sport == ActivityType.ride) {
      sport = "Bike";
    } else if (sport == ActivityType.elliptical) {
      sport = "X-train";
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

    final persistenceValues = exporter.getPersistenceValues(activity, true);
    String fileContentString = base64.encode(fileContent);
    String contentString = '{"UploadClient": "$appName",'
        '"Filename": "${persistenceValues["fileName"]}",'
        '"Data": "$fileContentString",'
        '"Title": "${persistenceValues["name"]}",'
        '"Comment": "${persistenceValues["description"]}",'
        '"WorkoutDay": "${DateFormat('yyyy-MM-dd').format(activity.startDateTime!)}",'
        '"StartTime": "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(activity.startDateTime!)}",'
        '"Type": "${trainingPeaksSport(activity.sport)}"}';
    const uploadUrl = tpProductionApiUrlBase + uploadPath;
    final uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: headers,
      body: contentString,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    final uploadBody = uploadResponse.body;
    debugPrint("status body: $uploadBody");
    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      // response.statusCode != 201
      debugPrint('Error while uploading the activity');
    } else {
      const workoutIdTag = '"Id":';
      int idBeginningIndex = uploadBody.indexOf(workoutIdTag);
      if (idBeginningIndex > 0) {
        int beginningIndex = idBeginningIndex + workoutIdTag.length;
        int idEndIndex = uploadBody.indexOf(',', beginningIndex);
        if (idEndIndex > 0) {
          final workoutIdString = uploadBody.substring(beginningIndex, idEndIndex);
          final workoutId = int.tryParse(workoutIdString) ?? 0;

          const athleteIdTag = '"AthleteId":';
          int athleteId = 0;
          int matchBeginningIndex = uploadBody.indexOf(athleteIdTag);
          if (matchBeginningIndex > 0) {
            final beginningIndex = matchBeginningIndex + athleteIdTag.length;
            final idEndIndex = uploadBody.indexOf(',', matchBeginningIndex);
            if (idEndIndex > 0) {
              final athleteIdString = uploadBody.substring(beginningIndex, idEndIndex);
              athleteId = int.tryParse(athleteIdString) ?? 0;
            }
          }

          debugPrint('id $workoutId athlete $athleteId');
          if (workoutId > 0 || athleteId > 0) {
            final database = Get.find<AppDatabase>();
            activity.markTrainingPeaksUploaded(athleteId, workoutId);
            await database.activityDao.updateActivity(activity);
          }
        }
      }
    }

    return uploadResponse.statusCode;
  }
}
