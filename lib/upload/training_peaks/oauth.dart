import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pref/pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/constants.dart';
import 'constants.dart';
import 'training_peaks_token.dart';

///===========================================
/// Class related to Authorization process
///===========================================
mixin Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  String getUrlBase(bool oAuthOrApi) {
    return oAuthOrApi ? tpProductionOAuthUrlBase : tpProductionApiUrlBase;
  }

  Future<void> registerToken(
    String? token,
    String? refreshToken,
    int? expire,
    String? scope,
  ) async {
    if (Get.isRegistered<TrainingPeaksToken>()) {
      var trainingPeaksToken = Get.find<TrainingPeaksToken>();
      // Save also in Get
      trainingPeaksToken.accessToken = token;
      trainingPeaksToken.refreshToken = refreshToken;
      trainingPeaksToken.expiresAt = expire;
      trainingPeaksToken.scope = scope;
    } else {
      await Get.delete<TrainingPeaksToken>(force: true);
      Get.put<TrainingPeaksToken>(
        TrainingPeaksToken(
          accessToken: token,
          refreshToken: refreshToken,
          expiresAt: expire,
          scope: scope,
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
    String? scope,
  ) async {
    final prefService = Get.find<BasePrefService>();
    await prefService.set<String>(trainingPeaksAccessTokenTag, token ?? '');
    await prefService.set<String>(trainingPeaksRefreshTokenTag, refreshToken ?? '');
    await prefService.set<int>(trainingPeaksExpiresAtTag, expire ?? 0); // Stored in seconds
    await prefService.set<String>(trainingPeaksTokenScopeTag, scope ?? '');
    await registerToken(token, refreshToken, expire, scope);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get TrainingPeaksToken
  ///
  Future<TrainingPeaksToken> _getStoredToken() async {
    var localToken = TrainingPeaksToken();
    debugPrint('Entering _getStoredToken');

    try {
      final prefService = Get.find<BasePrefService>();
      localToken.accessToken = prefService.get<String>(trainingPeaksAccessTokenTag);
      localToken.refreshToken = prefService.get<String>(trainingPeaksRefreshTokenTag);
      localToken.expiresAt = prefService.get<int>(trainingPeaksExpiresAtTag);
      localToken.scope = prefService.get<String>(trainingPeaksTokenScopeTag);

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
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt! * 1000);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} '
          '${dateExpired.hour.toString()} hours';
      debugPrint('stored token ${localToken.accessToken} ${localToken.expiresAt} '
          '${localToken.scope} expires: $details');
    }

    return localToken;
  }

  /// Get the code from Training Peaks server
  ///
  Future<void> _getTrainingPeaksCode(String clientId, String scope) async {
    debugPrint('Entering getTrainingPeaksCode');

    final params = '?response_type=code&client_id=$clientId&scope=$scope&redirect_uri=$redirectUrl';

    final reqAuth = getUrlBase(true) + authorizationPath + params;
    debugPrint(reqAuth);
    StreamSubscription? sub;

    launchUrlString(reqAuth, mode: LaunchMode.externalApplication);

    debugPrint('Running on iOS or Android');

    // Attach a listener to the stream
    sub = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri == null) {
        debugPrint('Subscription was null');
        sub?.cancel();
      } else {
        // Parse the link and warn the user, if it is not correct
        debugPrint('Got a link!! $uri');
        if (uri.scheme.compareTo('${redirectUrlScheme}_$clientId') != 0) {
          debugPrint('This is not the good scheme ${uri.scheme}');
        }
        final code = uri.queryParameters["code"] ?? notAvailable;
        final error = uri.queryParameters["error"];

        debugPrint('code $code, error $error');

        closeInAppWebView();
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
    String? accessToken = prefService.get<String>(trainingPeaksAccessTokenTag);
    if (accessToken == null || accessToken.isEmpty || accessToken == "null") {
      return false;
    }
    final TrainingPeaksToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do Training Peaks Authentication.
  /// clientId: ID of your Training Peaks app
  ///
  /// Do not do/show the Training Peaks login if a token has been stored previously
  /// and is not expired
  ///
  /// return true if no problem in authentication has been found
  Future<bool> oauth(String clientId, String secret, String scope) async {
    debugPrint('Welcome to Training Peaks OAuth');
    bool isAuthOk = false;
    bool isExpired;

    final tokenStored = await _getStoredToken();
    final token = tokenStored.accessToken;

    // Check if the token is not expired
    isExpired = _isTokenExpired(tokenStored);
    debugPrint('is token expired? $isExpired');

    bool storedBefore = token != null && token.isNotEmpty && token != "null";
    if (storedBefore) {
      debugPrint('token has been stored before! '
          '${tokenStored.accessToken}  exp. ${tokenStored.expiresAt}');
    }

    // Use the refresh token to get a new access token
    if (isExpired && storedBefore) {
      RefreshAnswer refreshAnswer =
          await _getNewAccessToken(clientId, secret, tokenStored.refreshToken ?? "0");
      // Update with new values if HTTP status code is 200
      if (refreshAnswer.statusCode != null &&
          refreshAnswer.statusCode! >= 200 &&
          refreshAnswer.statusCode! < 300) {
        await _saveToken(
          refreshAnswer.accessToken,
          refreshAnswer.refreshToken,
          refreshAnswer.expiresAt,
          scope,
        );
      } else {
        debugPrint('Problem doing the refresh process');
        isAuthOk = false;
      }
    }

    // Check if the scope has changed
    if (tokenStored.scope != scope || token == "null" || token == null || token.isEmpty) {
      // Ask for a new authorization
      debugPrint('Doing a new authorization');
      isAuthOk = await _newAuthorization(clientId, secret, scope);
    } else {
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(String clientId, String secret, String scope) async {
    bool returnValue = false;

    await _getTrainingPeaksCode(clientId, scope);

    final trainingPeaksCode = await onCodeReceived.stream.first;

    final answer = await _getTrainingPeaksToken(clientId, secret, trainingPeaksCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.accessToken!.isNotEmpty && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt, scope);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to Training Peaks a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because Training Peaks can change it
  ///     when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientId,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    debugPrint('Entering getNewAccessToken');

    final tokenRefreshUrl = getUrlBase(true) + tokenPath;

    debugPrint('urlRefresh $tokenRefreshUrl $refreshToken');

    final refreshResponse = await http.post(
      Uri.parse(tokenRefreshUrl),
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

  Future<TrainingPeaksToken> _getTrainingPeaksToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = TrainingPeaksToken();

    debugPrint('Entering getTrainingPeaksToken!!');

    final tokenRequestUrl = getUrlBase(true) + tokenPath;

    debugPrint('urlToken $tokenRequestUrl');

    final tokenResponse = await http.post(
      Uri.parse(tokenRequestUrl),
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
      debugPrint('Error in getTrainingPeaksToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(tokenResponse.body);
      final TrainingPeaksToken body = TrainingPeaksToken.fromJson(tokenBody);
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
  bool _isTokenExpired(TrainingPeaksToken token) {
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
  /// Useful when doing test to force the Training Peaks login
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<bool> deAuthorize() async {
    final token = Get.isRegistered<TrainingPeaksToken>()
        ? Get.find<TrainingPeaksToken>()
        : await _getStoredToken();
    final header = token.getAuthorizationHeader();
    // If header is "empty"
    if (header.containsKey('88')) {
      debugPrint('Access token seems to be already cleared');
      return true;
    }

    final deAuthorizeUrl = getUrlBase(true) + deauthorizationPath;

    debugPrint('request $deAuthorizeUrl');
    final response = await http.post(Uri.parse(deAuthorizeUrl), headers: header);
    bool success = false;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('DeAuthorize done');
      debugPrint('response ${response.body}');
      success = true;
    } else {
      debugPrint('Error while deauthorizing');
    }
    await _saveToken(null, null, null, null);

    return success;
  }
}
