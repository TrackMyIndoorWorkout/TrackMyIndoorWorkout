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
      await Get.delete<SuuntoToken>(force: true);
      Get.put<SuuntoToken>(
        SuuntoToken(
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
    await prefService.set<String>(suuntoAccessTokenTag, token ?? '');
    await prefService.set<String>(suuntoRefreshTokenTag, refreshToken ?? '');
    await prefService.set<int>(suuntoExpiresAtTag, expire ?? 0); // Stored in seconds
    await registerToken(token, refreshToken, expire);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get SuuntoToken
  ///
  Future<SuuntoToken> _getStoredToken() async {
    var localToken = SuuntoToken();
    debugPrint('Entering _getStoredToken');

    try {
      final prefService = Get.find<BasePrefService>();
      localToken.accessToken = prefService.get<String>(suuntoAccessTokenTag);
      localToken.refreshToken = prefService.get<String>(suuntoRefreshTokenTag);
      // localToken.expiresAt = prefService.get<int>('expire') * 1000; // To get in ms
      localToken.expiresAt = prefService.get<int>(suuntoExpiresAtTag);

      // load the data into Get
      await registerToken(localToken.accessToken, localToken.refreshToken, localToken.expiresAt);
    } catch (error) {
      debugPrint('Error while retrieving the token');
      localToken.accessToken = null;
      localToken.expiresAt = null;
    }

    if (localToken.expiresAt != null) {
      final dateExpired = DateTime.fromMillisecondsSinceEpoch(localToken.expiresAt!);
      final details = '${dateExpired.day.toString()}/${dateExpired.month.toString()} '
          '${dateExpired.hour.toString()} hours';
      debugPrint(
          'stored token ${localToken.accessToken} ${localToken.expiresAt} expires: $details');
    }

    return localToken;
  }

  /// Get the authorization code from SUUNTO server
  ///
  Future<void> _getSuuntoCode(String clientId) async {
    debugPrint('Entering getSuuntoCode');

    final encodedRedirectUrl = Uri.encodeQueryComponent(redirectUrl);
    final params = "?response_type=code&client_id=$clientId&redirect_uri=$encodedRedirectUrl";
    final oAuth2Url = authorizationEndpoint + params;

    debugPrint(oAuth2Url);

    StreamSubscription? sub;

    launchUrlString(oAuth2Url, mode: LaunchMode.externalApplication);

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
    String? accessToken = prefService.get<String>(suuntoAccessTokenTag);
    if (accessToken == null || accessToken.isEmpty) {
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
  Future<bool> oauth(String clientId, String secret, String subscriptionKey) async {
    debugPrint('Welcome to SUUNTO OAuth');
    bool isAuthOk = false;

    final tokenStored = await _getStoredToken();
    final token = tokenStored.accessToken;

    final isExpired = _isTokenExpired(tokenStored);
    debugPrint('is token expired? $isExpired');

    bool storedBefore = token != null && token.isNotEmpty && token != "null";
    if (storedBefore) {
      debugPrint('token has been stored before! '
          '${tokenStored.accessToken}  exp. ${tokenStored.expiresAt}');
    }

    // Use the refresh token to get a new access token
    if (isExpired && storedBefore) {
      RefreshAnswer refreshAnswer = await _getNewAccessToken(
        clientId,
        secret,
        tokenStored,
        subscriptionKey,
      );
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
    if (token == "null" || token == null) {
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

  /// _getNewAccessToken
  /// Ask to SUUNTO a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because SUUNTO can change it when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientId,
    String secret,
    SuuntoToken suuntoToken,
    String subscriptionKey,
  ) async {
    var returnToken = RefreshAnswer();

    debugPrint('Entering getNewAccessToken');

    final params = "?grant_type=refresh_token&refresh_token=${suuntoToken.refreshToken}";
    final tokenRefreshUrl = tokenEndpoint + params;

    debugPrint('urlRefresh $tokenRefreshUrl ${suuntoToken.refreshToken}');

    final headers = getBasicAuthorizationHeader(clientId, secret);
    final refreshResponse = await http.post(
      Uri.parse(tokenRefreshUrl),
      headers: headers,
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

  /// Generate the header to use with the token requests
  Map<String, String> getBasicAuthorizationHeader(String clientId, String secret) {
    final basicCredentialString = "$clientId:$secret";
    final credentialBytes = utf8.encode(basicCredentialString);
    final base64String = base64.encode(credentialBytes);

    return {"Authorization": "Basic $base64String"};
  }

  Future<SuuntoToken> _getSuuntoToken(
    String clientId,
    String secret,
    String code,
  ) async {
    var answer = SuuntoToken();

    debugPrint('Entering getSuuntoToken!!');

    const tokenRequestUrl = tokenEndpoint;

    debugPrint('urlToken $tokenRequestUrl');

    final headers = getBasicAuthorizationHeader(clientId, secret);
    final tokenResponse = await http.post(
      Uri.parse(tokenRequestUrl),
      headers: headers,
      body: {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectUrl,
      },
    );

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
    debugPrint(' current time in ms ${DateTime.now().millisecondsSinceEpoch ~/ 1000}'
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
  /// Useful when doing test to force the Suunto login
  ///
  ///return codes:
  /// true or false
  Future<bool> deAuthorize(String clientId, String subscriptionKey) async {
    final token =
        Get.isRegistered<SuuntoToken>() ? Get.find<SuuntoToken>() : await _getStoredToken();
    final header = token.getAuthorizationHeader(subscriptionKey);
    // If header is "empty"
    if (header.containsKey('88')) {
      debugPrint('Access token seems to be already cleared');
      return true;
    }

    final deAuthorizeUrl = "$deauthorizationEndpoint?client_id=$clientId";

    debugPrint('request $deAuthorizeUrl');
    bool success = false;
    final response = await http.post(Uri.parse(deAuthorizeUrl), headers: header);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('DeAuthorize done');
      debugPrint('response ${response.body}');
      success = true;
    } else {
      debugPrint('Error while deauthorizing');
    }
    await _saveToken(null, null, null);

    return success;
  }
}
