import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../export/activity_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/database.dart';
import '../../persistence/secret.dart';

import 'constants.dart';
import 'suunto_token.dart';

abstract class Upload {
  /// Tested with gpx and tcx
  /// For the moment the parameters
  ///
  /// trainer and commute are set to false
  ///
  /// statusCode:
  /// 201 activity created
  /// 400 problem could be that activity already uploaded
  ///
  Future<int> uploadActivity(
    Activity activity,
    List<int> fileContent,
    ActivityExport exporter,
  ) async {
    debugPrint('Starting to upload activity');

    if (!Get.isRegistered<SuuntoToken>()) {
      debugPrint('Token not yet known');
      return 0;
    }
    var suuntoToken = Get.find<SuuntoToken>();

    if (suuntoToken.accessToken == null) {
      // Token has not been yet stored in memory
      return 0;
    }

    var headers = suuntoToken.getAuthorizationHeader(SUUNTO_SUBSCRIPTION_PRIMARY_KEY);
    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 0;
    }

    headers.addAll({
      "Accept": "application/json",
      "Content-Type": "application/json",
    });

    Map<String, dynamic> persistenceValues = exporter.getPersistenceValues(activity, false);
    final postUri = Uri.parse(UPLOADS_ENDPOINT);
    final uploadInitResponse = await http.post(
      postUri,
      headers: headers,
      body: '{"description": "${persistenceValues["description"]}", '
          '"comment": "${persistenceValues["name"]}"}',
    );

    // https://apizone.suunto.com/how-to-workout-upload
    final initResponse = uploadInitResponse.body;
    int uploadId = 0;
    String blobUrl = "";
    const idPrefixPart = '"id":"';
    int matchBeginningIndex = initResponse.indexOf(idPrefixPart);
    int idEndIndex = -1;
    if (matchBeginningIndex > 0) {
      final idBeginningIndex = matchBeginningIndex + idPrefixPart.length;
      idEndIndex = initResponse.indexOf('"', idBeginningIndex);
      if (idEndIndex > 0) {
        final idString = initResponse.substring(idBeginningIndex, idEndIndex);
        uploadId = int.tryParse(idString) ?? 0;
        if (uploadId > 0) {
          debugPrint('uploadId: $uploadId');
        }
      }
    }

    const blobPrefixPart = '"url":"';
    matchBeginningIndex = initResponse.indexOf(blobPrefixPart, idEndIndex);
    if (matchBeginningIndex > 0) {
      final blobBeginningIndex = matchBeginningIndex + blobPrefixPart.length;
      final blobEndIndex = initResponse.indexOf('"', blobBeginningIndex);
      if (blobEndIndex > 0) {
        blobUrl = initResponse.substring(blobBeginningIndex, blobEndIndex);
      }
    }

    if (uploadId <= 0 || blobUrl.isEmpty) {
      return 0;
    }

    final database = Get.find<AppDatabase>();
    activity.suuntoUploadInitiated(uploadId, blobUrl);
    await database.activityDao.updateActivity(activity);

    headers["Content-Type"] = "application/vnd.ant.fit";
    final putUri = Uri.parse(blobUrl);

    final uploadBlobResponse = await http.put(
      putUri,
      headers: headers,
      body: fileContent,
    );

    if (uploadBlobResponse.statusCode < 200 || uploadBlobResponse.statusCode >= 300) {
      debugPrint('Error while uploading the workout');
    } else {
      debugPrint('$uploadBlobResponse');

      final statusUri = Uri.parse(UPLOADS_ENDPOINT + "/$uploadId");

      headers["Content-Type"] = "application/json";

      final uploadStatusResponse = await http.post(
        statusUri,
        headers: headers,
      );

      const workoutUrl = '"webUrl": "';
      final statusBody = uploadStatusResponse.body;
      matchBeginningIndex = statusBody.indexOf(workoutUrl);
      if (matchBeginningIndex > 0) {
        final urlBeginningIndex = matchBeginningIndex + workoutUrl.length;
        final urlEndIndex = statusBody.indexOf('"', urlBeginningIndex);
        if (urlEndIndex > 0) {
          final webUrl = statusBody.substring(urlBeginningIndex, urlEndIndex);
          activity.markSuuntoUploaded(webUrl);
          await database.activityDao.updateActivity(activity);
        }
      }

      return uploadStatusResponse.statusCode;
    }

    return uploadBlobResponse.statusCode;
  }
}
