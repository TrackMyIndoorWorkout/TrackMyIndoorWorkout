import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../export/activity_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/database.dart';
import '../../persistence/secret.dart';

import 'constants.dart';
import 'suunto_token.dart';
// import 'upload_activity.dart';

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

    final headers = suuntoToken.getAuthorizationHeader(SUUNTO_SUBSCRIPTION_PRIMARY_KEY);
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

    StreamController<int> onUploadPending = StreamController();

    final putUri = Uri.parse(blobUrl);
    var request = http.MultipartRequest("PUT", putUri);

    headers["Content-Type"] = "application/vnd.ant.fit";
    request.headers.addAll(headers);

    request.files.add(http.MultipartFile.fromBytes('file', fileContent,
        filename: persistenceValues["fileName"],
        contentType: MediaType("application", "vnd.ant.fit")));
    debugPrint(request.toString());

    final response = await request.send();

    debugPrint('Response: ${response.statusCode} ${response.reasonPhrase}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // response.statusCode != 201
      debugPrint('Error while uploading the activity');
      debugPrint('${response.statusCode} - ${response.reasonPhrase}');
    }

    int idUpload;

    /*
    // Upload is processed by the server
    // now wait for the upload to be finished
    //----------------------------------------
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // response.statusCode == 201
      debugPrint('Activity successfully created');
      response.stream.transform(utf8.decoder).listen((value) async {
        debugPrint(value);
        final Map<String, dynamic> _body = json.decode(value);
        final response = ResponseUploadActivity.fromJson(_body);

        if (response.id > 0) {
          final database = Get.find<AppDatabase>();
          activity.markUploaded(response.id);
          await database.activityDao.updateActivity(activity);
          debugPrint('id ${response.id}');
          idUpload = response.id;
          onUploadPending.add(idUpload);
        }
      });

      String reqCheckUpgrade = '$UPLOADS_ENDPOINT/';
      onUploadPending.stream.listen((id) async {
        reqCheckUpgrade = reqCheckUpgrade + id.toString();
        final resp = await http.get(Uri.parse(reqCheckUpgrade), headers: header);
        debugPrint('check status ${resp.reasonPhrase}  ${resp.statusCode}');

        // Everything is fine the file has been loaded
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          // resp.statusCode == 200
          debugPrint('${resp.statusCode} ${resp.reasonPhrase}');
        }

        // 404 the temp id does not exist anymore
        // Activity has been probably already loaded
        if (resp.statusCode == 404) {
          debugPrint('---> 404 activity already loaded  ${resp.reasonPhrase}');
        }

        if (resp.reasonPhrase != null) {
          if (resp.reasonPhrase!.compareTo(StravaStatusText.ready) == 0) {
            debugPrint('---> Activity successfully uploaded');
            onUploadPending.close();
          }

          if ((resp.reasonPhrase!.compareTo(StravaStatusText.notFound) == 0) ||
              (resp.reasonPhrase!.compareTo(StravaStatusText.errorMsg) == 0)) {
            debugPrint('---> Error while checking status upload');
            onUploadPending.close();
          }

          if (resp.reasonPhrase!.compareTo(StravaStatusText.deleted) == 0) {
            debugPrint('---> Activity deleted');
            onUploadPending.close();
          }

          if (resp.reasonPhrase!.compareTo(StravaStatusText.processed) == 0) {
            debugPrint('---> try another time');
            // wait 2 sec before checking again status
            Timer(Duration(seconds: 2), () => onUploadPending.add(id));
          }
        } else {
          debugPrint('---> Unknown error');
          onUploadPending.close();
        }
      });
    }

    return Fault(response.statusCode, response.reasonPhrase ?? "Unknown reason");*/
    return 0;
  }
}
