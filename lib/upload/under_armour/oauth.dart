import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'under_armour_status_code.dart';
import 'constants.dart';
import 'under_armour_token.dart';
import 'fault.dart';

///===========================================
/// Class related to Authorization process
///===========================================
abstract class Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  Future<void> registerToken(
    String? token,
    String? refreshToken,
    int? expire,
    String? scope,
  ) async {
    if (Get.isRegistered<UnderArmourToken>()) {
      var underArmourToken = Get.find<UnderArmourToken>();
      // Save also in Get
      underArmourToken.accessToken = token;
      underArmourToken.refreshToken = refreshToken;
      underArmourToken.expiresAt = expire;
      underArmourToken.scope = scope;
    } else {
      await Get.delete<UnderArmourToken>();
      Get.put<UnderArmourToken>(UnderArmourToken(
        accessToken: token,
        refreshToken: refreshToken,
        expiresAt: expire,
        scope: scope,
      ));
    }
  }

  /// Save the token and the expiry date
  Future<void> _saveToken(
    String? token,
    String? refreshToken,
    int? expire,
    String? scope,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(UNDER_ARMOUR_ACCESS_TOKEN_TAG, token ?? '');
    prefs.setString(UNDER_ARMOUR_REFRESH_TOKEN_TAG, refreshToken ?? '');
    prefs.setInt(UNDER_ARMOUR_EXPIRES_AT_TAG, expire ?? 0); // Stored in seconds
    prefs.setString(UNDER_ARMOUR_TOKEN_SCOPE_TAG, scope ?? '');
    await registerToken(token, refreshToken, expire, scope);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get UnderArmourToken
  ///
  Future<UnderArmourToken> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    var localToken = UnderArmourToken();
    debugPrint('Entering _getStoredToken');

    try {
      localToken.accessToken = prefs.getString(UNDER_ARMOUR_ACCESS_TOKEN_TAG)?.toString();
      localToken.refreshToken = prefs.getString(UNDER_ARMOUR_REFRESH_TOKEN_TAG);
      // localToken.expiresAt = prefs.getInt('expire') * 1000; // To get in ms
      localToken.expiresAt = prefs.getInt(UNDER_ARMOUR_EXPIRES_AT_TAG);
      localToken.scope = prefs.getString(UNDER_ARMOUR_TOKEN_SCOPE_TAG);

      // load the data into Get
      await registerToken(
          localToken.accessToken, localToken.refreshToken, localToken.expiresAt, localToken.scope);
    } catch (error) {
      debugPrint('Error while retrieving the token');
      localToken.accessToken = null;
      localToken.expiresAt = null;
      localToken.scope = null;
    }

    if (localToken.expiresAt != null) {
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt!);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} ' +
          '${dateExpired.hour.toString()} hours';
      debugPrint('stored token ${localToken.accessToken} ${localToken.expiresAt} ' +
          '${localToken.scope} expires: $details');
    }

    return localToken;
  }

  /// Get the code from Under Armour server
  ///
  Future<void> _getUnderArmourCode(
    String clientId,
    String scope,
    String prompt,
  ) async {
    debugPrint('Entering getUnderArmourCode');

    final params = '?client_id=$clientId&response_type=code&redirect_uri=$REDIRECT_URL';

    final reqAuth = AUTHORIZATION_ENDPOINT + params;
    debugPrint(reqAuth);
    StreamSubscription? sub;

    // closeWebView();
    launch(reqAuth,
        forceWebView: false,
        // forceWebView: true,
        forceSafariVC: false,
        enableJavaScript: true);

    //--------  NOT working yet on web
    if (kIsWeb) {
      debugPrint('Running in web ');

      // listening on http the answer from Under Armour
      final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
      await for (HttpRequest request in server) {
        // Get the answer from Under Armour
        // final uri = request.uri;
        debugPrint('Get the answer from Under Armour to authenticate! ${request.uri}');
      }
    } else {
      debugPrint('Running on iOS or Android');

      // Attach a listener to the stream
      sub = uriLinkStream.listen((Uri? uri) {
        if (uri == null) {
          debugPrint('Subscription was null');
          sub?.cancel();
        } else {
          // Parse the link and warn the user, if it is not correct
          debugPrint('Got a link!! $uri');
          if (uri.scheme.compareTo('${REDIRECT_URL_SCHEME}_$clientId') != 0) {
            debugPrint('This is not the good scheme ${uri.scheme}');
          }
          final code = uri.queryParameters["code"] ?? "N/A";
          final error = uri.queryParameters["error"];

          debugPrint('code $code, error $error');

          closeWebView();
          onCodeReceived.add(code);

          debugPrint('Got the new code: $code');

          sub?.cancel();
        }
      }, onError: (err) {
        // Handle exception by warning the user their action did not succeed
        debugPrint('Found an error $err');
        sub?.cancel();
      });
    }
  }

  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(UNDER_ARMOUR_ACCESS_TOKEN_TAG)?.toString();
    if (accessToken == null || accessToken.length == 0) {
      return false;
    }
    final UnderArmourToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do Under Armour Authentication.
  /// clientId: ID of your Under Armour app
  /// scope: Under Armour scope check https://developers.strava.com/docs/oauth-updates/
  /// prompt: to choose to ask Under Armour always to authenticate or only when needed (with 'auto')
  ///
  /// Do not do/show the Under Armour login if a token has been stored previously
  /// and is not expired
  ///
  /// Do/show the Under Armour login if the scope has been changed since last storage of the token
  /// return true if no problem in authentication has been found
  Future<bool> oauth(
    String clientId,
    String scope,
    String secret,
    String prompt,
  ) async {
    debugPrint('Welcome to Under Armour OAuth');
    bool isAuthOk = false;
    bool isExpired;

    final tokenStored = await _getStoredToken();
    final token = tokenStored.accessToken;

    isExpired = _isTokenExpired(tokenStored);
    debugPrint('is token expired? $isExpired');

    // Check if the token is not expired
    if (token != null) {
      // && token != "null"
      debugPrint('token has been stored before! ' +
          '${tokenStored.accessToken}  exp. ${tokenStored.expiresAt}');
    }

    // Use the refresh token to get a new access token
    if (isExpired) {
      // token != null || token != "null"
      RefreshAnswer _refreshAnswer =
          await _getNewAccessToken(clientId, secret, tokenStored.refreshToken ?? "0");
      // Update with new values if HTTP status code is 200
      if (_refreshAnswer.fault != null &&
          _refreshAnswer.fault!.statusCode >= 200 &&
          _refreshAnswer.fault!.statusCode < 300) {
        await _saveToken(
          _refreshAnswer.accessToken,
          _refreshAnswer.refreshToken,
          _refreshAnswer.expiresAt,
          scope,
        );
      } else {
        debugPrint('Problem doing the refresh process');
        isAuthOk = false;
      }
    }

    // Check if the scope has changed
    if (tokenStored.scope != scope || token == "null" || token == null) {
      // Ask for a new authorization
      debugPrint('Doing a new authorization');
      isAuthOk = await _newAuthorization(clientId, secret, scope, prompt);
    } else {
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(
    String clientId,
    String secret,
    String scope,
    String prompt,
  ) async {
    bool returnValue = false;

    await _getUnderArmourCode(clientId, scope, prompt);

    final underArmourCode = await onCodeReceived.stream.first;

    final answer = await _getUnderArmourToken(clientId, secret, underArmourCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt, scope);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to Under Armour a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because Under Armour can change it
  ///     when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientId,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    final tokenRefreshUrl = TOKEN_ENDPOINT +
        '?client_id=$clientId&client_secret=$secret' +
        '&grant_type=refresh_token&refresh_token=$refreshToken';

    debugPrint('Entering getNewAccessToken');
    // debugPrint('urlRefresh $urlRefresh');

    final refreshResponse = await http.post(Uri.parse(tokenRefreshUrl));

    debugPrint('body ${refreshResponse.body}');
    if (refreshResponse.statusCode >= 200 && refreshResponse.statusCode < 300) {
      // resp.statusCode == 200
      returnToken = RefreshAnswer.fromJson(json.decode(refreshResponse.body));

      debugPrint('new exp. date: ${returnToken.expiresAt}');
    } else {
      debugPrint('Error while refreshing the token');
    }

    returnToken.fault = Fault(refreshResponse.statusCode, refreshResponse.reasonPhrase ?? "N/A");
    return returnToken;
  }

  Future<UnderArmourToken> _getUnderArmourToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = UnderArmourToken();

    debugPrint('Entering getUnderArmourToken!!');

    final tokenRequestUrl = TOKEN_ENDPOINT;

    debugPrint('urlToken $tokenRequestUrl');

    final tokenResponse = await http.post(
      Uri.parse(tokenRequestUrl),
      headers: {
        "Api-Key": clientId,
      },
      body: {
        // "Content-Type": "application/x-www-form-urlencoded",
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URL,
      },
    );

    debugPrint('body ${tokenResponse.body}');

    if (tokenResponse.body.contains('message')) {
      // This is not the normal message
      debugPrint('Error in getUnderArmourToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(tokenResponse.body);
      final UnderArmourToken body = UnderArmourToken.fromJson(tokenBody);
      // var expiresAt = body.expiresAt * 1000; // To get the exp. date in ms
      answer.accessToken = body.accessToken;
      answer.refreshToken = body.refreshToken;
      answer.expiresAt = body.expiresAt;
    }

    return (answer);
  }

  /// Return true the expiry date is passed
  ///
  /// Otherwise return false
  ///
  /// including when there is no token yet
  bool _isTokenExpired(UnderArmourToken token) {
    debugPrint(' current time in ms ${DateTime.now().millisecondsSinceEpoch / 1000}' +
        ' exp. time: ${token.expiresAt}');

    // when it is the first run or after a deAuthorize
    if (token.expiresAt == null) {
      return false;
    }

    if (token.expiresAt! < DateTime.now().millisecondsSinceEpoch / 1000) {
      return true;
    } else {
      return false;
    }
  }

  /// To revoke the current token
  /// Useful when doing test to force the Under Armour login
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<Fault> deAuthorize(String clientId) async {
    if (!Get.isRegistered<UnderArmourToken>()) {
      debugPrint('Token not yet known');
      return Fault(UnderArmourStatusCode.statusTokenNotKnownYet, 'Token not yet known');
    }
    var underArmourToken = Get.find<UnderArmourToken>();

    if (underArmourToken.accessToken == null) {
      // Token has not been yet stored in memory
      underArmourToken = await _getStoredToken();
    }

    final header = underArmourToken.getAuthorizationHeader(clientId);
    var fault = Fault(UnderArmourStatusCode.statusUnknownError, "Unknown reason");
    // If header is not "empty"
    if (header.containsKey('88') == false) {
      final deAuthorizationUrl = DEAUTHORIZATION_ENDPOINT;
      debugPrint('request $deAuthorizationUrl');
      final rep = await http.post(Uri.parse(deAuthorizationUrl), headers: header);
      if (rep.statusCode >= 200 && rep.statusCode < 300) {
        debugPrint('DeAuthorize done');
        debugPrint('response ${rep.body}');
        await _saveToken(null, null, null, null);
        fault.statusCode = UnderArmourStatusCode.statusOk;
        fault.message = 'DeAuthorize done';
      } else {
        await _saveToken(null, null, null, null);
        debugPrint('Problem in deAuthorize request');
        fault.statusCode = UnderArmourStatusCode.statusDeAuthorizeError;
      }
    } else {
      // No authorization has been done before
      debugPrint('No Authentication has been done yet');
      fault.statusCode = UnderArmourStatusCode.statusNoAuthenticationYet;
      fault.message = 'No Authentication has been done yet';
    }

    return fault;
  }
}
