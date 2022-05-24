import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pref/pref.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'constants.dart';
import 'under_armour_token.dart';

///===========================================
/// Class related to Authorization process
///===========================================
abstract class Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  Future<void> registerToken(String? token, String? refreshToken, int? expire) async {
    if (Get.isRegistered<UnderArmourToken>()) {
      var underArmourToken = Get.find<UnderArmourToken>();
      // Save also in Get
      underArmourToken.accessToken = token;
      underArmourToken.refreshToken = refreshToken;
      underArmourToken.expiresAt = expire;
    } else {
      await Get.delete<UnderArmourToken>(force: true);
      Get.put<UnderArmourToken>(
        UnderArmourToken(
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
    await prefService.set<String>(underArmourAccessTokenTag, token ?? '');
    await prefService.set<String>(underArmourRefreshTokenTag, refreshToken ?? '');
    await prefService.set<int>(underArmourExpiresAtTag, expire ?? 0); // Stored in seconds
    await registerToken(token, refreshToken, expire);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get UnderArmourToken
  ///
  Future<UnderArmourToken> _getStoredToken() async {
    var localToken = UnderArmourToken();
    debugPrint('Entering _getStoredToken');

    try {
      final prefService = Get.find<BasePrefService>();
      localToken.accessToken = prefService.get<String>(underArmourAccessTokenTag);
      localToken.refreshToken = prefService.get<String>(underArmourRefreshTokenTag);
      localToken.expiresAt = prefService.get<int>(underArmourExpiresAtTag);

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

  /// Get the code from Under Armour server
  ///
  Future<void> _getUnderArmourCode(String clientId) async {
    debugPrint('Entering getUnderArmourCode');

    final params = '?client_id=$clientId&response_type=code&redirect_uri=$redirectUrl';

    final reqAuth = authorizationEndpoint + params;
    debugPrint(reqAuth);
    StreamSubscription? sub;

    launchUrlString(reqAuth);

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
    String? accessToken = prefService.get<String>(underArmourAccessTokenTag);
    if (accessToken == null || accessToken.isEmpty || accessToken == "null") {
      return false;
    }
    final UnderArmourToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do Under Armour Authentication.
  /// clientId: ID of your Under Armour app
  ///
  /// Do not do/show the Under Armour login if a token has been stored previously
  /// and is not expired
  ///
  /// return true if no problem in authentication has been found
  Future<bool> oauth(String clientId, String secret) async {
    debugPrint('Welcome to Under Armour OAuth');
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

    await _getUnderArmourCode(clientId);

    final underArmourCode = await onCodeReceived.stream.first;

    final answer = await _getUnderArmourToken(clientId, secret, underArmourCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.accessToken!.isNotEmpty && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to Under Armour a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because Under Armour can change it when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientId,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    debugPrint('Entering getNewAccessToken');
    debugPrint('urlRefresh $tokenEndpoint $refreshToken');

    final refreshResponse = await http.post(
      Uri.parse(tokenEndpoint),
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

  Future<UnderArmourToken> _getUnderArmourToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = UnderArmourToken();

    debugPrint('Entering getUnderArmourToken!!');
    debugPrint('urlToken $tokenEndpoint');

    final tokenResponse = await http.post(
      Uri.parse(tokenEndpoint),
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
      debugPrint('Error in getUnderArmourToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(tokenResponse.body);
      final UnderArmourToken body = UnderArmourToken.fromJson(tokenBody);
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
  /// Useful when doing test to force the Under Armour login
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<int> deAuthorize(String clientId) async {
    await _saveToken(null, null, null);
    // TODO: we'd need the user ID: https://developer.underarmour.com/docs/v71_OAuth2ConnectionRevokeResource/
    return 200;
  }
}
