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
import 'under_armour_token.dart';

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

    if (!Get.isRegistered<UnderArmourToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final underArmourToken = Get.find<UnderArmourToken>();
    final headers = underArmourToken.getAuthorizationHeader(clientId);

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
      Uri.parse(UPLOADS_ENDPOINT),
      headers: headers,
      body: contentString,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      debugPrint('Error while uploading the activity');
    } else {
      debugPrint('$uploadResponse');
    }

    final database = Get.find<AppDatabase>();
    activity.markSuuntoUploaded();
    await database.activityDao.updateActivity(activity);

    return uploadResponse.statusCode;
  }
}
