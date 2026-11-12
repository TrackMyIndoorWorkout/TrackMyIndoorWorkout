import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:isar_community/isar.dart';

import '../../export/activity_export.dart';
import '../../persistence/activity.dart';
import 'constants.dart';
import 'fault.dart';
import 'strava_status_code.dart';
import 'strava_status_text.dart';
import 'strava_token.dart';
import 'upload_activity.dart';

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
  Future<Fault> uploadActivity(
    Activity activity,
    List<int> fileContent,
    ActivityExport exporter,
  ) async {
    debugPrint('Starting to upload activity');

    if (!Get.isRegistered<StravaToken>()) {
      debugPrint('Token not yet known');
      return Fault(StravaStatusCode.statusTokenNotKnownYet, 'Token not yet known');
    }

    final stravaToken = Get.find<StravaToken>();
    final header = stravaToken.getAuthorizationHeader();

    if (header.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return Fault(StravaStatusCode.statusTokenNotKnownYet, 'Token not yet known');
    }

    if (activity.stravaId > 0 && activity.stravaActivityId == 0) {
      final statusResult = await checkStatus(header, activity, activity.stravaId);
      if (statusResult.statusCode >= 200 && statusResult.statusCode < 300) {
        return statusResult;
      }
      activity.clearStravaUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
    }

    final postUri = Uri.parse(uploadsEndpoint);
    var request = http.MultipartRequest("POST", postUri);
    request.fields['data_type'] = exporter.fileExtension(true);
    request.fields['trainer'] = 'false';
    request.fields['commute'] = 'false';
    request.fields['name'] = activity.getTitle(true);
    request.fields['external_id'] = 'strava_flutter';
    request.fields['description'] = activity.getDescription(true);
    request.headers.addAll(header);

    final fileName = activity.getFileNameStub() + exporter.fileExtension(true);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileContent,
        filename: fileName,
        contentType: MediaType("application", "x-gzip"),
      ),
    );
    debugPrint(request.toString());

    final streamedResponse = await request.send();

    debugPrint('Response: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}');

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      debugPrint('Error while uploading the activity');
      debugPrint('${streamedResponse.statusCode} - ${streamedResponse.reasonPhrase}');
      activity.clearStravaUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
      return Fault(streamedResponse.statusCode, streamedResponse.reasonPhrase ?? "Unknown reason");
    }

    debugPrint('Activity upload initiated');
    final response = await http.Response.fromStream(streamedResponse);
    final body = response.body;
    debugPrint(body);
    final Map<String, dynamic> bodyMap;
    try {
      bodyMap = json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode Strava upload response: $e');
      activity.clearStravaUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
      return Fault(0, 'Failed to decode upload response');
    }

    final decodedResponse = ResponseUploadActivity.fromJson(bodyMap);

    if (decodedResponse.id <= 0) {
      debugPrint('Invalid upload ID from Strava');
      activity.clearStravaUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
      return Fault(0, 'Invalid upload ID');
    }

    activity.markStravaUploadInitiated(decodedResponse.id);
    if (Get.isRegistered<Isar>()) {
      final database = Get.find<Isar>();
      database.writeTxnSync(() {
        database.activitys.putSync(activity);
      });
    }

    return await checkStatus(header, activity, decodedResponse.id);
  }

  Future<Fault> checkStatus(Map<String, String> header, Activity activity, int uploadId) async {
    final statusUri = Uri.parse('$uploadsEndpoint/$uploadId');

    for (int attempt = 0; attempt < 10; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      final resp = await http.get(statusUri, headers: header);
      debugPrint('Check Strava Status: ${resp.statusCode}');

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('Error while checking upload status: ${resp.statusCode}');
        activity.clearStravaUpload();
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
        return Fault(resp.statusCode, resp.reasonPhrase ?? "Error checking upload status");
      }

      final Map<String, dynamic> statusMap;
      try {
        statusMap = json.decode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to decode Strava status body: $e');
        continue;
      }

      final decodedStatus = ResponseUploadActivity.fromJson(statusMap);

      if (decodedStatus.error.isNotEmpty) {
        debugPrint('Strava processing error: ${decodedStatus.error}');
        activity.clearStravaUpload();
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
        return Fault(400, decodedStatus.error);
      }

      if (decodedStatus.activityId > 0) {
        activity.markStravaUploaded(decodedStatus.activityId);
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
        return Fault(201, StravaStatusText.ready);
      }

      if (decodedStatus.status == StravaStatusText.ready && decodedStatus.activityId > 0) {
        activity.markStravaUploaded(decodedStatus.activityId);
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
        return Fault(201, StravaStatusText.ready);
      }
    }

    debugPrint('Strava upload polling timed out');
    activity.clearStravaUpload();
    if (Get.isRegistered<Isar>()) {
      final database = Get.find<Isar>();
      database.writeTxnSync(() {
        database.activitys.putSync(activity);
      });
    }
    return Fault(408, 'Polling timed out');
  }
}
