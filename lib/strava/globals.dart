// globals.dart

import 'package:flutter/foundation.dart';
import 'fault.dart';
import 'token.dart';

bool isInDebug = true; // set to true to see debug message in API

Token token = Token(); // Where the token info is stored when executing APIs

// Default location
// used when an activity has null
// for startLatitude and end
final defaultStartLatlng = 0.0;
final defaultEndlatlng = 0.0;

/// To display debug info in Strava API
void displayInfo(String message) {
  if (isInDebug) {
    debugPrint('--> Strava_flutter: $message');
  }
}

/// Generate the header to use with http requests
///
/// return {null, null} if there is not token yet
/// stored in globals
Map<String, String> createHeader() {
  var _token = token;
  if (_token.accessToken != null) {
    return {'Authorization': 'Bearer ${_token.accessToken}'};
  } else {
    return {'88': '00'};
  }
}

/// Nothing much inside for the moment
/// Feed the Fault with statusCode and reasonPhrase
/// Coming from http request
///
Fault errorCheck(int statusCode, String reason) {
  Fault returnFault = Fault(statusCode, reason);

  return returnFault;
}
