import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../export/activity_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/database.dart';

// import 'constants.dart';
import 'google_fit_token.dart';

abstract class Upload {
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

    if (!Get.isRegistered<GoogleFitToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final googleFitToken = Get.find<GoogleFitToken>();
    final headers = googleFitToken.getAuthorizationHeader(clientId);

    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 401;
    }

    headers.addAll({
      "Accept": "application/json",
      "Accept-Encoding": "gzip",
      "Content-Type": "application/json",
      "Content-Encoding": "gzip",
      "Content-Length": fileContent.length.toString()
    });

    final uploadResponse = await http.post(
      Uri.parse(""), // uploadsEndpoint),
      headers: headers,
      body: fileContent,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      debugPrint('Error while uploading the activity');
    } else {
      debugPrint('$uploadResponse');
      final responseBody = uploadResponse.body;
      const workoutUrl = "/v7.1/workout/";
      final matchBeginningIndex = responseBody.indexOf(workoutUrl);
      if (matchBeginningIndex > 0) {
        final idBeginningIndex = matchBeginningIndex + workoutUrl.length;
        final idEndIndex = responseBody.indexOf("/", idBeginningIndex);
        if (idEndIndex > 0) {
          final idString = responseBody.substring(idBeginningIndex, idEndIndex);
          final workoutId = int.tryParse(idString) ?? 0;
          if (workoutId > 0) {
            debugPrint('workoutId: $workoutId');
            final database = Get.find<AppDatabase>();
            // TODO activity.markGoogleFitUploaded(workoutId);
            await database.activityDao.updateActivity(activity);
          }
        }
      }
    }

    return uploadResponse.statusCode;
  }
}
