import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

import '../../export/activity_export.dart';
import '../../persistence/activity.dart';
import '../../secret.dart';
import 'constants.dart';
import 'suunto_token.dart';

mixin Upload {
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

    var headers = suuntoToken.getAuthorizationHeader(suuntoSubscriptionPrimaryKey);
    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 0;
    }

    headers.addAll({"Accept": "application/json", "Content-Type": "application/json"});

    if (activity.suuntoBlobUrl.isNotEmpty && activity.suuntoUploadIdentifier.isNotEmpty) {
      final statusResult = await checkStatus(headers, activity);
      if (statusResult >= 200 && statusResult < 300) {
        return statusResult;
      }
      // If checkStatus failed (e.g. upload expired, rejected, or blob never uploaded),
      // clear the stalled upload so we can start a fresh upload below instead of deadlocking.
      activity.clearSuuntoUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
    }

    final postUri = Uri.parse(uploadsEndpoint);
    final uploadInitResponse = await http.post(
      postUri,
      headers: headers,
      body: jsonEncode({
        "description": activity.getDescription(true),
        "comment": activity.getTitle(true),
      }),
    );

    // https://apizone.suunto.com/how-to-workout-upload
    final initResponse = uploadInitResponse.body;
    debugPrint('initResponse: $initResponse');
    String uploadId = "";
    String blobUrl = "";

    if (uploadInitResponse.statusCode < 200 || uploadInitResponse.statusCode >= 300) {
      debugPrint('Error while initializing upload: ${uploadInitResponse.statusCode}');
      return uploadInitResponse.statusCode;
    }

    try {
      final initJson = jsonDecode(initResponse) as Map<String, dynamic>;
      uploadId = initJson['id'] as String? ?? "";
      blobUrl = initJson['url'] as String? ?? "";
    } catch (e) {
      debugPrint('Failed to decode Suunto upload init response: $e');
      return 0;
    }

    if (uploadId.isEmpty || blobUrl.isEmpty) {
      debugPrint('Upload ID or blob URL empty in init response');
      return 0;
    }

    activity.suuntoUploadInitiated(uploadId, blobUrl);
    if (Get.isRegistered<Isar>()) {
      final database = Get.find<Isar>();
      database.writeTxnSync(() {
        database.activitys.putSync(activity);
      });
    }

    final putUri = Uri.parse(blobUrl);

    final uploadBlobResponse = await http.put(
      putUri,
      headers: {"x-ms-blob-type": "BlockBlob", "Content-Type": "application/vnd.ant.fit"},
      body: fileContent,
    );

    if (uploadBlobResponse.statusCode < 200 || uploadBlobResponse.statusCode >= 300) {
      debugPrint('Error while uploading the workout: ${uploadBlobResponse.statusCode}');
      activity.clearSuuntoUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
      return uploadBlobResponse.statusCode;
    } else {
      debugPrint('Blob PUT response: ${uploadBlobResponse.statusCode}');

      return await checkStatus(headers, activity);
    }
  }

  Future<int> checkStatus(Map<String, String> headers, Activity activity) async {
    if (activity.suuntoUploaded && activity.suuntoWorkoutUrl.isNotEmpty) {
      return 200;
    }

    if (activity.suuntoUploadIdentifier.isEmpty) {
      return 0;
    }

    final statusUri = Uri.parse("$uploadsEndpoint/${activity.suuntoUploadIdentifier}");

    for (int attempt = 0; attempt < 10; attempt++) {
      if (attempt > 0) {
        await Future.delayed(const Duration(seconds: 1));
      }

      final uploadStatusResponse = await http.get(statusUri, headers: headers);

      if (uploadStatusResponse.statusCode < 200 || uploadStatusResponse.statusCode >= 300) {
        debugPrint('Error while getting upload status: ${uploadStatusResponse.statusCode}');
        if (uploadStatusResponse.statusCode == 404 || uploadStatusResponse.statusCode == 400) {
          activity.clearSuuntoUpload();
          if (Get.isRegistered<Isar>()) {
            final database = Get.find<Isar>();
            database.writeTxnSync(() {
              database.activitys.putSync(activity);
            });
          }
        }
        return uploadStatusResponse.statusCode;
      }

      try {
        final statusJson = jsonDecode(uploadStatusResponse.body) as Map<String, dynamic>;
        final status = statusJson['status'] as String? ?? "";
        final webUrl = statusJson['webUrl'] as String? ?? "";

        if (status == "FAILED" || status == "ERROR") {
          debugPrint('Suunto upload status failed: $status');
          activity.clearSuuntoUpload();
          if (Get.isRegistered<Isar>()) {
            final database = Get.find<Isar>();
            database.writeTxnSync(() {
              database.activitys.putSync(activity);
            });
          }
          return 400;
        }

        if (status == "PROCESSED" || webUrl.isNotEmpty) {
          activity.markSuuntoUploaded(webUrl);
          if (Get.isRegistered<Isar>()) {
            final database = Get.find<Isar>();
            database.writeTxnSync(() {
              database.activitys.putSync(activity);
            });
          }
          return 200;
        }
      } catch (e) {
        debugPrint('Error parsing Suunto status response: $e');
      }
    }

    debugPrint('Suunto upload status polling timed out');
    return 408;
  }
}
