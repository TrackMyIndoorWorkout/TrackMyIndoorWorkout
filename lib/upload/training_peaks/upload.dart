import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../export/activity_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/database.dart';

import 'constants.dart';
import 'training_peaks_token.dart';

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

    if (!Get.isRegistered<TrainingPeaksToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final trainingPeaksToken = Get.find<TrainingPeaksToken>();
    final headers = trainingPeaksToken.getAuthorizationHeader(clientId);

    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 401;
    }

    headers.addAll({
      "Accept": "application/json",
      "Accept-Encoding": "gzip",
      "Content-Type": "application/json",
      // "Content-Encoding": "gzip",
      // "Content-Length": fileContent.length.toString()
    });

    String contentString = utf8.decode(fileContent);
    final uploadResponse = await http.post(
      Uri.parse(TP_SANDBOX_OAUTH_URL_BASE + UPLOAD_PATH),
      headers: headers,
      body: contentString,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      // response.statusCode != 201
      debugPrint('Error while uploading the activity');
    } else {
      debugPrint('$uploadResponse');
    }

    // if (response.id > 0) {
    //   final database = Get.find<AppDatabase>();
    //   activity.markUploaded(response.id);
    //   await database.activityDao.updateActivity(activity);
    //   debugPrint('id ${response.id}');
    // }

    return uploadResponse.statusCode;
  }
}
