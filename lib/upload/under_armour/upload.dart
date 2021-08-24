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
import 'under_armour_status_text.dart';
import 'under_armour_token.dart';
import 'upload_activity.dart';

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
    String clientId,
  ) async {
    debugPrint('Starting to upload activity');

    final postUri = Uri.parse(UPLOADS_ENDPOINT);
    StreamController<int> onUploadPending = StreamController();

    final persistenceValues = exporter.getPersistenceValues(activity, true);
    var request = http.MultipartRequest("POST", postUri);
    request.fields['data_type'] = exporter.fileExtension(true);
    request.fields['trainer'] = 'false';
    request.fields['commute'] = 'false';
    request.fields['name'] = persistenceValues["name"];
    request.fields['external_id'] = 'under_armour_flutter';
    request.fields['description'] = persistenceValues["description"];

    if (!Get.isRegistered<UnderArmourToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final underArmourToken = Get.find<UnderArmourToken>();
    final header = underArmourToken.getAuthorizationHeader(clientId);

    if (header.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 401;
    }

    request.headers.addAll(header);

    request.files.add(http.MultipartFile.fromBytes('file', fileContent,
        filename: persistenceValues["fileName"], contentType: MediaType("application", "x-gzip")));
    debugPrint(request.toString());

    final response = await request.send();

    debugPrint('Response: ${response.statusCode} ${response.reasonPhrase}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // response.statusCode != 201
      debugPrint('Error while uploading the activity');
      debugPrint('${response.statusCode} - ${response.reasonPhrase}');
    }

    int idUpload;

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
          if (resp.reasonPhrase!.compareTo(UnderArmourStatusText.ready) == 0) {
            debugPrint('---> Activity successfully uploaded');
            onUploadPending.close();
          }

          if ((resp.reasonPhrase!.compareTo(UnderArmourStatusText.notFound) == 0) ||
              (resp.reasonPhrase!.compareTo(UnderArmourStatusText.errorMsg) == 0)) {
            debugPrint('---> Error while checking status upload');
            onUploadPending.close();
          }

          if (resp.reasonPhrase!.compareTo(UnderArmourStatusText.deleted) == 0) {
            debugPrint('---> Activity deleted');
            onUploadPending.close();
          }

          if (resp.reasonPhrase!.compareTo(UnderArmourStatusText.processed) == 0) {
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

    return 500;
  }
}
