import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pref/pref.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'google_fit_token.dart';

///===========================================
/// Class related to Authorization process
///===========================================
abstract class Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  Future<void> registerToken(String? token, String? refreshToken, int? expire) async {
    if (Get.isRegistered<GoogleFitToken>()) {
      var googleFitToken = Get.find<GoogleFitToken>();
      // Save also in Get
      googleFitToken.accessToken = token;
      googleFitToken.refreshToken = refreshToken;
      googleFitToken.expiresAt = expire;
    } else {
      await Get.delete<GoogleFitToken>(force: true);
      Get.put<GoogleFitToken>(
        GoogleFitToken(
          accessToken: token,
          refreshToken: refreshToken,
          expiresAt: expire,
        ),
        permanent: true,
      );
    }
  }

  /// Save the token and the expiry date
  Future<void> _saveToken(
    String? token,
    String? refreshToken,
    int? expire,
  ) async {
    final prefService = Get.find<BasePrefService>();
    await prefService.set<String>(googleFitAccessTokenTag, token ?? '');
    await prefService.set<String>(googleFitRefreshTokenTag, refreshToken ?? '');
    await prefService.set<int>(googleFitExpiresAtTag, expire ?? 0); // Stored in seconds
    await registerToken(token, refreshToken, expire);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get GoogleFitToken
  ///
  Future<GoogleFitToken> _getStoredToken() async {
    var localToken = GoogleFitToken();
    debugPrint('Entering _getStoredToken');

    try {
      final prefService = Get.find<BasePrefService>();
      localToken.accessToken = prefService.get<String>(googleFitAccessTokenTag);
      localToken.refreshToken = prefService.get<String>(googleFitRefreshTokenTag);
      localToken.expiresAt = prefService.get<int>(googleFitExpiresAtTag);

      // load the data into Get
      await registerToken(localToken.accessToken, localToken.refreshToken, localToken.expiresAt);
    } catch (error) {
      debugPrint('Error while retrieving the token');
      localToken.accessToken = null;
      localToken.expiresAt = null;
    }

    if (localToken.expiresAt != null) {
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt! * 1000);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} '
          '${dateExpired.hour.toString()} hours';
      debugPrint(
          'stored token ${localToken.accessToken} ${localToken.expiresAt} expires: $details');
    }

    return localToken;
  }

  /// Get the code from Google Fit server
  ///
  Future<void> _getGoogleFitCode(String clientId) async {
    debugPrint('Entering getGoogleFitCode');

    // &state=state_parameter_passthrough_value
    final params =
        '?redirect_uri=$redirectUrl&prompt=consent&response_type=code&client_id=$clientId&scope=$googleOAuthScope&access_type=offline';
    final reqAuth = googleOAuthEndpoint + params;
    debugPrint(reqAuth);
    StreamSubscription? sub;

    launch(reqAuth,
        forceWebView: false,
        // forceWebView: true,
        forceSafariVC: false,
        enableJavaScript: true);

    debugPrint('Running on iOS or Android');

    // Attach a listener to the stream
    sub = uriLinkStream.listen((Uri? uri) {
      if (uri == null) {
        debugPrint('Subscription was null');
        sub?.cancel();
      } else {
        // Parse the link and warn the user, if it is not correct
        debugPrint('Got a link!! $uri');
        if (uri.scheme.compareTo('${redirectUrlScheme}_$clientId') != 0) {
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
    final prefService = Get.find<BasePrefService>();
    String? accessToken = prefService.get<String>(googleFitAccessTokenTag);
    if (accessToken == null || accessToken.isEmpty || accessToken == "null") {
      return false;
    }
    final GoogleFitToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do Google Fit Authentication.
  /// clientId: ID of your Google Fit app
  ///
  /// Do not do/show the  Google Fit login if a token has been stored previously
  /// and is not expired
  ///
  /// return true if no problem in authentication has been found
  Future<bool> oauth(String clientId, String secret) async {
    debugPrint('Welcome to  Google Fit OAuth');
    bool isAuthOk = false;

    final tokenStored = await _getStoredToken();
    final token = tokenStored.accessToken;

    // Check if the token is not expired
    bool isExpired = _isTokenExpired(tokenStored);
    debugPrint('is token expired? $isExpired');

    bool storedBefore = token != null && token.isNotEmpty && token != "null";
    if (storedBefore) {
      debugPrint('token has been stored before! '
          '${tokenStored.accessToken}  exp. ${tokenStored.expiresAt}');
    }

    // Use the refresh token to get a new access token
    if (isExpired && storedBefore) {
      RefreshAnswer _refreshAnswer =
          await _getNewAccessToken(clientId, secret, tokenStored.refreshToken ?? "0");
      // Update with new values if HTTP status code is 200
      if (_refreshAnswer.statusCode != null &&
          _refreshAnswer.statusCode! >= 200 &&
          _refreshAnswer.statusCode! < 300) {
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

    // Check token
    if (token == "null" || token == null || token.isEmpty) {
      // Ask for a new authorization
      debugPrint('Doing a new authorization');
      isAuthOk = await _newAuthorization(clientId, secret);
    } else {
      debugPrint('token has been stored before! '
          '${tokenStored.accessToken} exp. ${tokenStored.expiresAt}');
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(String clientId, String secret) async {
    bool returnValue = false;

    await _getGoogleFitCode(clientId);

    final googleFitCode = await onCodeReceived.stream.first;

    final answer = await _getGoogleFitToken(clientId, secret, googleFitCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.accessToken!.isNotEmpty && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to  Google Fit a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because  Google Fit can change it when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientId,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    debugPrint('Entering getNewAccessToken');
    debugPrint('urlRefresh $googleTokenEndpoint $refreshToken');

    final refreshResponse = await http.post(
      Uri.parse(googleTokenEndpoint),
      headers: {
        "Accept": "application/json",
        "Api-Key": clientId,
      },
      body: {
        "grant_type": "refresh_token",
        "client_id": clientId,
        "client_secret": secret,
        "refresh_token": refreshToken,
      },
    );

    debugPrint('body ${refreshResponse.body}');
    if (refreshResponse.statusCode >= 200 && refreshResponse.statusCode < 300) {
      // resp.statusCode == 200
      returnToken = RefreshAnswer.fromJson(json.decode(refreshResponse.body));

      debugPrint('new exp. date: ${returnToken.expiresAt}');
    } else {
      debugPrint('Error while refreshing the token');
    }

    returnToken.statusCode = refreshResponse.statusCode;

    return returnToken;
  }

  Future<GoogleFitToken> _getGoogleFitToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = GoogleFitToken();

    debugPrint('Entering getGoogleFitToken!!');
    debugPrint('urlToken $googleTokenEndpoint');

    final tokenResponse = await http.post(
      Uri.parse(googleTokenEndpoint),
      headers: {
        "Accept": "application/json",
        "Api-Key": clientId,
      },
      body: {
        "grant_type": "authorization_code",
        "client_id": clientId,
        "client_secret": secret,
        "code": code,
        "redirect_uri": redirectUrl,
      },
    );

    debugPrint('body ${tokenResponse.body}');

    if (tokenResponse.body.contains('message')) {
      // This is not the normal message
      debugPrint('Error in getGoogleFitToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(tokenResponse.body);
      final GoogleFitToken body = GoogleFitToken.fromJson(tokenBody);
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
  bool _isTokenExpired(GoogleFitToken token) {
    debugPrint(' current Epoch time ${DateTime.now().millisecondsSinceEpoch ~/ 1000}'
        ' exp. time: ${token.expiresAt}');

    // when it is the first run or after a deAuthorize
    if (token.expiresAt == null) {
      return false;
    }

    if (token.expiresAt! * 1000 < DateTime.now().millisecondsSinceEpoch) {
      return true;
    } else {
      return false;
    }
  }

  /// To revoke the current token
  /// Useful when doing test to force the Google Fit login
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<int> deAuthorize(String clientId) async {
    await _saveToken(null, null, null);
    // TODO: we'd need the user ID: https://developer.underarmour.com/docs/v71_OAuth2ConnectionRevokeResource/
    return 200;
  }
}
