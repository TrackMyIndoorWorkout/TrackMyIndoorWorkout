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
  Future<SuuntoToken> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    var localToken = SuuntoToken();
    debugPrint('Entering _getStoredToken');

    try {
      localToken.accessToken = prefs.getString(SUUNTO_ACCESS_TOKEN_TAG)?.toString();
      localToken.refreshToken = prefs.getString(SUUNTO_REFRESH_TOKEN_TAG);
      // localToken.expiresAt = prefs.getInt('expire') * 1000; // To get in ms
      localToken.expiresAt = prefs.getInt(SUUNTO_EXPIRES_AT_TAG);

      // load the data into Get
      await registerToken(localToken.accessToken, localToken.refreshToken, localToken.expiresAt);
    } catch (error) {
      debugPrint('Error while retrieving the token');
      localToken.accessToken = null;
      localToken.expiresAt = null;
    }

    if (localToken.expiresAt != null) {
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt!);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} ' +
          '${dateExpired.hour.toString()} hours';
      debugPrint(
          'stored token ${localToken.accessToken} ${localToken.expiresAt} ' + 'expires: $details');
    }

    return localToken;
  }

  /// Generate the header to use with the token requests
  Map<String, String> getBasicAuthorizationHeader(String clientId, String secret) {
    var basicCredentialString = "$clientId:$secret";
    var credentialBytes = utf8.encode(basicCredentialString);
    var base64String = base64.encode(credentialBytes);

    return {'Authorization': 'Basic: $base64String'};
  }

  /// Get the authorization code from SUUNTO server
  ///
  Future<void> _getSuuntoCode(String clientId) async {
    debugPrint('Entering getSuuntoCode');

    final oAuth2Url =
        "$OAUTH_API_HOST/authorize?response_type=code&client_id=$clientId&redirect_uri=$REDIRECT_URL_MOBILE";
    debugPrint(oAuth2Url);
    StreamSubscription? sub;

    launch(oAuth2Url, forceWebView: false, forceSafariVC: false, enableJavaScript: true);

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

  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(SUUNTO_ACCESS_TOKEN_TAG)?.toString();
    if (accessToken == null || accessToken.length == 0) {
      return false;
    }
    final SuuntoToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do SUUNTO Authentication.
  ///
  /// clientId: ID of your Suunto app
  /// secret: Secret of your Suunto app
  Future<bool> oauth(String clientId, String secret) async {
    debugPrint('Welcome to SUUNTO OAuth');
    bool isAuthOk = false;
    bool isExpired;

    final tokenStored = await _getStoredToken();
    final token = tokenStored.accessToken;

    isExpired = _isTokenExpired(tokenStored);
    debugPrint('is token expired? $isExpired');

    if (token == "null" || token == null) {
      debugPrint('Doing a new authorization');
      isAuthOk = await _newAuthorization(clientId, secret);
    } else {
      debugPrint('token has been stored before! ' +
          '${tokenStored.accessToken} exp. ${tokenStored.expiresAt}');
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(String clientId, String secret) async {
    bool returnValue = false;

    await _getSuuntoCode(clientId);

    final suuntoCode = await onCodeReceived.stream.first;

    final answer = await _getSuuntoToken(clientId, secret, suuntoCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt);
      returnValue = true;
    }

    return returnValue;
  }

  Future<SuuntoToken> _getSuuntoToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = SuuntoToken();

    debugPrint('Entering getSuuntoToken!!');
    // Put your own secret in secret.dart

    final tokenRequestUrl = "$OAUTH_API_HOST/token";

    debugPrint('urlToken $tokenRequestUrl');

    final header = getBasicAuthorizationHeader(clientId, secret);
    final tokenResponse = await http.post(Uri.parse(tokenRequestUrl), headers: header, body: {
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": REDIRECT_URL_MOBILE,
    });

    debugPrint('body ${tokenResponse.body}');

    if (tokenResponse.body.contains('message')) {
      // This is not the normal message
      debugPrint('Error in getSuuntoToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(tokenResponse.body);
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
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<bool> deAuthorize(String clientId) async {
    if (!Get.isRegistered<SuuntoToken>()) {
      debugPrint('Token not yet known');
      return false;
    }
    var stravaToken = Get.find<SuuntoToken>();

    if (stravaToken.accessToken == null) {
      // Token has not been yet stored in memory
      stravaToken = await _getStoredToken();
    }

    final header = stravaToken.getAuthorizationHeader();
    // If header is "empty"
    if (header.containsKey('88')) {
      debugPrint('No Authentication has been done yet');
      return true;
    }

    final deAuthorizeUrl = "$OAUTH_API_HOST/deauthorize?client_id=$clientId";

    debugPrint('request $deAuthorizeUrl');
    final rseponse = await http.post(Uri.parse(deAuthorizeUrl), headers: header);
    if (rseponse.statusCode >= 200 && rseponse.statusCode < 300) {
      debugPrint('DeAuthorize done');
      debugPrint('response ${rseponse.body}');
      await _saveToken(null, null, null);
      return true;
    }

    return false;
  }
}
