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
    if (sport == ActivityType.Swim) {
      sport = "swim";
    } else if (sport == ActivityType.Canoeing ||
        sport == ActivityType.Kayaking ||
        sport == ActivityType.Rowing) {
      sport = "rowing";
    } else if (sport == ActivityType.Run) {
      sport = "run";
    } else if (sport == ActivityType.Ride) {
      sport = "bike";
    } else if (sport == ActivityType.Elliptical) {
      sport = "x-train";
    }

    return "other";
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
    String contentString = '{"UploadClient": "$APP_NAME",'
        '"Filename": "${persistenceValues["fileName"]}",'
        '"Data": "$fileContentString",'
        '"Title": "${persistenceValues["name"]}",'
        '"Comment": "${persistenceValues["description"]}"'
        '"WorkoutDay": ${DateFormat('yyyy-MM-dd').format(activity.startDateTime!)}'
        '"StartTime": ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(activity.startDateTime!)}'
        '"Type": "${trainingPeaksSport(activity.sport)}"}';
    final uploadUrlBase = kDebugMode ? TP_SANDBOX_API_URL_BASE : TP_PRODUCTION_API_URL_BASE;
    final uploadUrl = uploadUrlBase + UPLOAD_PATH;
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
      const workoutId = '"Id":"';
      int idBeginningIndex = uploadBody.indexOf(workoutId);
      if (idBeginningIndex > 0) {
        final beginningIndex = idBeginningIndex + workoutId.length;
        final idEndIndex = uploadBody.indexOf('"', beginningIndex);
        if (idEndIndex > 0) {
          final id = uploadBody.substring(beginningIndex, idEndIndex);

          String url = "";
          const workoutUrl = '"Url":"';
          int matchBeginningIndex = uploadBody.indexOf(workoutUrl);
          if (matchBeginningIndex > 0) {
            final urlBeginningIndex = matchBeginningIndex + workoutUrl.length;
            final urlEndIndex = uploadBody.indexOf('"', urlBeginningIndex);
            if (urlEndIndex > 0) {
              url = uploadBody.substring(urlBeginningIndex, urlEndIndex);
            }
          }

          // TODO: persist id
          // if (id > 0) {
          //   final database = Get.find<AppDatabase>();
          //   activity.markTrainingPeaksUploaded(id, url);
          //   await database.activityDao.updateActivity(activity);
          //   debugPrint('id ${id}');
          // }
        }
      }
    }

    return uploadResponse.statusCode;
  }
}
