import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'suunto_token.dart';

///===========================================
/// Class related to Authorization process
///===========================================
abstract class Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  Future<void> registerToken(
    String? token,
    String? refreshToken,
    int? expire,
  ) async {
    if (Get.isRegistered<SuuntoToken>()) {
      var stravaToken = Get.find<SuuntoToken>();
      // Save also in Get
      stravaToken.accessToken = token;
      stravaToken.refreshToken = refreshToken;
      stravaToken.expiresAt = expire;
    } else {
      await Get.delete<SuuntoToken>();
      Get.put<SuuntoToken>(SuuntoToken(
        accessToken: token,
        refreshToken: refreshToken,
        expiresAt: expire,
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
    prefs.setString(SUUNTO_ACCESS_TOKEN_TAG, token ?? '');
    prefs.setString(SUUNTO_REFRESH_TOKEN_TAG, refreshToken ?? '');
    prefs.setInt(SUUNTO_EXPIRES_AT_TAG, expire ?? 0); // Stored in seconds
    await registerToken(token, refreshToken, expire);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get SuuntoToken
  ///
  Future<SuuntoToken> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    var localToken = SuuntoToken();
    debugPrint('Entering getStoredToken');

    try {
      localToken.accessToken = prefs.getString(SUUNTO_ACCESS_TOKEN_TAG)?.toString();
      localToken.refreshToken = prefs.getString(SUUNTO_REFRESH_TOKEN_TAG);
      // localToken.expiresAt = prefs.getInt('expire') * 1000; // To get in ms
      localToken.expiresAt = prefs.getInt(SUUNTO_EXPIRES_AT_TAG);

      // load the data into Get
      await registerToken(
          localToken.accessToken, localToken.refreshToken, localToken.expiresAt);
    } catch (error) {
      debugPrint('Error while retrieving the token');
      localToken.accessToken = null;
      localToken.expiresAt = null;
    }

    if (localToken.expiresAt != null) {
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt!);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} ' +
          '${dateExpired.hour.toString()} hours';
      debugPrint('stored token ${localToken.accessToken} ${localToken.expiresAt} ' +
          'expires: $details');
    }

    return localToken;
  }

  /// Get the code from SUUNTO server
  ///
  Future<void> _getSuuntoCode(String clientID) async {
    debugPrint('Entering getSuuntoCode');
    String redirectUrl = REDIRECT_URL_MOBILE;

    final params = '?client_id=$clientID&redirect_uri=$redirectUrl' +
        '&response_type=code&approval_prompt=$prompt&scope=$scope';

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
    debugPrint('Running on iOS or Android');

    // Attach a listener to the stream
    sub = uriLinkStream.listen((Uri? uri) {
      if (uri == null) {
        debugPrint('Subscription was null');
        sub?.cancel();
      } else {
        // Parse the link and warn the user, if it is not correct
        debugPrint('Got a link!! $uri');
        if (uri.scheme.compareTo('${REDIRECT_URL_SCHEME}_$clientID') != 0) {
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

  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(SUUNTO_ACCESS_TOKEN_TAG)?.toString();
    if (accessToken == null || accessToken.length == 0) {
      return false;
    }
    final SuuntoToken tokenStored = await getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do SUUNTO Authentication.
  ///
  Future<bool> oauth(
    String clientID,
    String secret,
  ) async {
    debugPrint('Welcome to SUUNTO Oauth');
    bool isAuthOk = false;
    bool isExpired;

    final tokenStored = await getStoredToken();
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
          await _getNewAccessToken(clientID, secret, tokenStored.refreshToken ?? "0");
      // Update with new values if HTTP status code is 200
      if (_refreshAnswer.fault != null &&
          _refreshAnswer.fault!.statusCode >= 200 &&
          _refreshAnswer.fault!.statusCode < 300) {
        await _saveToken(
          _refreshAnswer.accessToken,
          _refreshAnswer.refreshToken,
          _refreshAnswer.expiresAt,
        );
      } else {
        debugPrint('Problem doing the refresh process');
        isAuthOk = false;
      }
    }

    // Check if the scope has changed
    if (token == "null" || token == null) {
      // Ask for a new authorization
      debugPrint('Doing a new authorization');
      isAuthOk = await _newAuthorization(clientID, secret);
    } else {
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(
    String clientID,
    String secret,
  ) async {
    bool returnValue = false;

    await _getSuuntoCode(clientID);

    final stravaCode = await onCodeReceived.stream.first;

    final answer = await _getSuuntoToken(clientID, secret, stravaCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to Suunto a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because Suunto can change it
  ///     when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientID,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    final urlRefresh = TOKEN_ENDPOINT +
        '?client_id=$clientID&client_secret=$secret' +
        '&grant_type=refresh_token&refresh_token=$refreshToken';

    debugPrint('Entering getNewAccessToken');
    // debugPrint('urlRefresh $urlRefresh');

    final resp = await http.post(Uri.parse(urlRefresh));

    debugPrint('body ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // resp.statusCode == 200
      returnToken = RefreshAnswer.fromJson(json.decode(resp.body));

      debugPrint('new exp. date: ${returnToken.expiresAt}');
    } else {
      debugPrint('Error while refreshing the token');
    }

    returnToken.fault = Fault(resp.statusCode, resp.reasonPhrase ?? "N/A");
    return returnToken;
  }

  Future<SuuntoToken> _getSuuntoToken(
    String clientID,
    String secret,
    String code,
  ) async {
    var answer = SuuntoToken();

    debugPrint('Entering getSuuntoToken!!');
    // Put your own secret in secret.dart
    final urlToken = '$TOKEN_ENDPOINT?client_id=$clientID&client_secret=$secret' +
        '&code=$code&grant_type=authorization_code';

    debugPrint('urlToken $urlToken');

    final value = await http.post(Uri.parse(urlToken));

    debugPrint('body ${value.body}');

    if (value.body.contains('message')) {
      // This is not the normal message
      debugPrint('Error in getSuuntoToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(value.body);
      final SuuntoToken body = SuuntoToken.fromJson(tokenBody);
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
  bool _isTokenExpired(SuuntoToken token) {
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
  /// Useful when doing test to force the Suunto login
  ///
  /// scope needed: none
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<Fault> deAuthorize() async {
    if (!Get.isRegistered<SuuntoToken>()) {
      debugPrint('Token not yet known');
      return Fault(StravaStatusCode.statusTokenNotKnownYet, 'Token not yet known');
    }
    var stravaToken = Get.find<SuuntoToken>();

    if (stravaToken.accessToken == null) {
      // Token has not been yet stored in memory
      stravaToken = await getStoredToken();
    }

    final header = stravaToken.getAuthorizationHeader();
    var fault = Fault(StravaStatusCode.statusUnknownError, "Unknown reason");
    // If header is not "empty"
    if (header.containsKey('88') == false) {
      final requestDeAuthorize = DEAUTHORIZATION_ENDPOINT;
      debugPrint('request $requestDeAuthorize');
      final rep = await http.post(Uri.parse(requestDeAuthorize), headers: header);
      if (rep.statusCode >= 200 && rep.statusCode < 300) {
        debugPrint('DeAuthorize done');
        debugPrint('response ${rep.body}');
        await _saveToken(null, null, null, null);
        fault.statusCode = StravaStatusCode.statusOk;
        fault.message = 'DeAuthorize done';
      } else {
        await _saveToken(null, null, null, null);
        debugPrint('Problem in deAuthorize request');
        fault.statusCode = StravaStatusCode.statusDeAuthorizeError;
      }
    } else {
      // No authorization has been done before
      debugPrint('No Authentication has been done yet');
      fault.statusCode = StravaStatusCode.statusNoAuthenticationYet;
      fault.message = 'No Authentication has been done yet';
    }

    return fault;
  }
}
