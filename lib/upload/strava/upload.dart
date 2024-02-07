import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:isar/isar.dart';
import '../../export/activity_export.dart';
import '../../persistence/isar/activity.dart';

import 'constants.dart';
import 'strava_status_code.dart';
import 'fault.dart';
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

    final postUri = Uri.parse(uploadsEndpoint);
    var request = http.MultipartRequest("POST", postUri);
    request.fields['data_type'] = exporter.fileExtension(true);
    request.fields['trainer'] = 'false';
    request.fields['commute'] = 'false';
    request.fields['name'] = activity.getTitle();
    request.fields['external_id'] = 'strava_flutter';
    request.fields['description'] = activity.getDescription(false);

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

    request.headers.addAll(header);

    final fileName = activity.getFileNameStub() + exporter.fileExtension(true);
    request.files.add(http.MultipartFile.fromBytes('file', fileContent,
        filename: fileName, contentType: MediaType("application", "x-gzip")));
    debugPrint(request.toString());

    final streamedResponse = await request.send();

    debugPrint('Response: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}');

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      // response.statusCode indicates problem
      debugPrint('Error while uploading the activity');
      debugPrint('${streamedResponse.statusCode} - ${streamedResponse.reasonPhrase}');
    } else {
      // Upload is processed by the server
      // now wait for the upload to be finished
      //----------------------------------------
      // response.statusCode == 201
      debugPrint('Activity successfully created');

      final response = await http.Response.fromStream(streamedResponse);
      final body = response.body;
      debugPrint(body);
      final Map<String, dynamic> bodyMap = json.decode(body);
      final decodedResponse = ResponseUploadActivity.fromJson(bodyMap);

      if (decodedResponse.id > 0) {
        activity.markStravaUploadInitiated(decodedResponse.id);
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });

        debugPrint('id ${decodedResponse.id}');

        await Future<void>.delayed(const Duration(milliseconds: 500));
        final reqCheckUpgrade = '$uploadsEndpoint/${decodedResponse.id}';
        final uri = Uri.parse(reqCheckUpgrade);
        String? reasonPhrase = StravaStatusText.processed;
        http.Response? resp;
        ResponseUploadActivity decodedStatus = ResponseUploadActivity(0, "", "", "", 0);
        while (reasonPhrase == StravaStatusText.processed) {
          resp = await http.get(uri, headers: header);
          reasonPhrase = resp.reasonPhrase;
          debugPrint('Check Status $reasonPhrase ${resp.statusCode}');

          // Everything is fine the file has been loaded
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            // resp.statusCode == 200
            debugPrint('Check Body: ${resp.body}');
            final Map<String, dynamic> bodyMap = json.decode(resp.body);
            decodedStatus = ResponseUploadActivity.fromJson(bodyMap);
          }

          // 404 the temp id does not exist anymore
          // Activity has been probably already loaded
          if (resp.statusCode == 404) {
            debugPrint('---> 404 activity already loaded  $reasonPhrase');
          }

          if (reasonPhrase != null) {
            if (reasonPhrase.compareTo(StravaStatusText.ready) == 0) {
              debugPrint('---> Activity successfully uploaded');
            }

            if (reasonPhrase.compareTo(StravaStatusText.notFound) == 0 ||
                reasonPhrase.compareTo(StravaStatusText.errorMsg) == 0) {
              debugPrint('---> Error while checking status upload');
            }

            if (reasonPhrase.compareTo(StravaStatusText.deleted) == 0) {
              debugPrint('---> Activity deleted');
            }

            if (reasonPhrase.compareTo(StravaStatusText.processed) == 0) {
              debugPrint('---> try another time');
              await Future<void>.delayed(const Duration(milliseconds: 200));
            }
          } else {
            debugPrint('---> Unknown error');
          }
        }

        int stravaActivityId = decodedStatus.activityId;
        while (resp != null &&
            resp.statusCode >= 200 &&
            resp.statusCode < 300 &&
            reasonPhrase == StravaStatusText.ok &&
            decodedStatus.status == StravaStatusText.processed &&
            stravaActivityId == 0) {
          if (stravaActivityId > 0) {
            activity.markStravaUploaded(stravaActivityId);
          } else {
            await Future<void>.delayed(const Duration(seconds: 1));
            resp = await http.get(uri, headers: header);
            final Map<String, dynamic> bodyMap = json.decode(resp.body);
            decodedStatus = ResponseUploadActivity.fromJson(bodyMap);
            reasonPhrase = resp.reasonPhrase;
            stravaActivityId = decodedStatus.activityId;
            if (stravaActivityId > 0) {
              activity.markStravaUploaded(stravaActivityId);
            }
          }
        }
      }
    }

    return Fault(streamedResponse.statusCode, streamedResponse.reasonPhrase ?? "Unknown reason");
  }
}
