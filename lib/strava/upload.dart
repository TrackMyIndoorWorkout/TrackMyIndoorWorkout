import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../persistence/models/activity.dart';
import '../persistence/database.dart';
import '../tcx/tcx_output.dart';

import 'constants.dart';
import 'error_codes.dart' as error;
import 'fault.dart';
import 'globals.dart' as globals;
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
  Future<Fault> uploadActivity(Activity activity, List<int> fileContent) async {
    globals.displayInfo('Starting to upload activity');

    // To check if the activity has been uploaded successfully
    // No numeric error code for the moment given by Strava
    final String ready = "Your activity is ready.";
    final String deleted = "The created activity has been deleted.";
    final String errorMsg = "There was an error processing your activity.";
    final String processed = "Your activity is still being processed.";
    final String notFound = 'Not Found';

    final postUri = Uri.parse(UPLOADS_ENDPOINT);
    StreamController<int> onUploadPending = StreamController();

    var fault = Fault(888, '');

    final persistenceValues = activity.getPersistenceValues();
    var request = http.MultipartRequest("POST", postUri);
    request.fields['data_type'] = TCXOutput.FILE_EXTENSION;
    request.fields['trainer'] = 'false';
    request.fields['commute'] = 'false';
    request.fields['name'] = persistenceValues["name"];
    request.fields['external_id'] = 'strava_flutter';
    request.fields['description'] = persistenceValues["description"];

    var _header = globals.createHeader();

    if (_header.containsKey('88') == true) {
      globals.displayInfo('Token not yet known');
      fault = Fault(error.statusTokenNotKnownYet, 'Token not yet known');
      return fault;
    }

    request.headers.addAll(_header);

    request.files.add(http.MultipartFile.fromBytes('file', fileContent,
        filename: persistenceValues["fileName"], contentType: MediaType("application", "x-gzip")));
    globals.displayInfo(request.toString());

    var response = await request.send();

    globals.displayInfo('Response: ${response.statusCode} ${response.reasonPhrase}');

    fault.statusCode = response.statusCode;
    fault.message = response.reasonPhrase;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // response.statusCode != 201
      globals.displayInfo('Error while uploading the activity');
      globals.displayInfo('${response.statusCode} - ${response.reasonPhrase}');
    }

    int idUpload;

    // Upload is processed by the server
    // now wait for the upload to be finished
    //----------------------------------------
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // response.statusCode == 201
      globals.displayInfo('Activity successfully created');
      response.stream.transform(utf8.decoder).listen((value) {
        debugPrint(value);
        final Map<String, dynamic> _body = json.decode(value);
        ResponseUploadActivity _response = ResponseUploadActivity.fromJson(_body);

        $FloorAppDatabase
            .databaseBuilder('app_database.db')
            .addMigrations([migration1to2, migration2to3, migration3to4])
            .build()
            .then((db) async {
              activity.markUploaded(_response.id);
              await db.activityDao.updateActivity(activity);
            });
        debugPrint('id ${_response.id}');
        idUpload = _response.id;
        onUploadPending.add(idUpload);
      });

      String reqCheckUpgrade = '$UPLOADS_ENDPOINT/';
      onUploadPending.stream.listen((id) async {
        reqCheckUpgrade = reqCheckUpgrade + id.toString();
        var resp = await http.get(reqCheckUpgrade, headers: _header);
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

        if (resp.reasonPhrase.compareTo(ready) == 0) {
          debugPrint('---> Activity successfully uploaded');
          onUploadPending.close();
        }

        if ((resp.reasonPhrase.compareTo(notFound) == 0) ||
            (resp.reasonPhrase.compareTo(errorMsg) == 0)) {
          debugPrint('---> Error while checking status upload');
          onUploadPending.close();
        }

        if (resp.reasonPhrase.compareTo(deleted) == 0) {
          debugPrint('---> Activity deleted');
          onUploadPending.close();
        }

        if (resp.reasonPhrase.compareTo(processed) == 0) {
          debugPrint('---> try another time');
          // wait 2 sec before checking again status
          Timer(Duration(seconds: 2), () => onUploadPending.add(id));
        }
      });
    }

    return fault;
  }
}
