import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pref/pref.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/constants.dart';
import 'strava_status_code.dart';
import 'constants.dart';
import 'strava_token.dart';
import 'fault.dart';

///===========================================
/// Class related to Authorization process
///===========================================
mixin Auth {
  StreamController<String> onCodeReceived = StreamController<String>.broadcast();

  Future<void> registerToken(
    String? token,
    String? refreshToken,
    int? expire,
    String? scope,
  ) async {
    if (Get.isRegistered<StravaToken>()) {
      var stravaToken = Get.find<StravaToken>();
      // Save also in Get
      stravaToken.accessToken = token;
      stravaToken.refreshToken = refreshToken;
      stravaToken.expiresAt = expire;
      stravaToken.scope = scope;
    } else {
      await Get.delete<StravaToken>(force: true);
      Get.put<StravaToken>(
        StravaToken(
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
    await prefService.set<String>(stravaAccessTokenTag, token ?? '');
    await prefService.set<String>(stravaRefreshTokenTag, refreshToken ?? '');
    await prefService.set<int>(stravaExpiresAtTag, expire ?? 0); // Stored in seconds
    await prefService.set<String>(stravaTokenScopeTag, scope ?? '');
    await registerToken(token, refreshToken, expire, scope);
    debugPrint('token saved!!!');
  }

  /// Get the stored token and expiry date
  ///
  /// And refreshToken as well
  /// Stored them in Get StravaToken
  ///
  Future<StravaToken> _getStoredToken() async {
    var localToken = StravaToken();
    debugPrint('Entering _getStoredToken');

    try {
      final prefService = Get.find<BasePrefService>();
      localToken.accessToken = prefService.get<String>(stravaAccessTokenTag);
      localToken.refreshToken = prefService.get<String>(stravaRefreshTokenTag);
      localToken.expiresAt = prefService.get<int>(stravaExpiresAtTag);
      localToken.scope = prefService.get<String>(stravaTokenScopeTag);

      // load the data into Get
      await registerToken(
        localToken.accessToken,
        localToken.refreshToken,
        localToken.expiresAt,
        localToken.scope,
      );
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

  /// Get the code from Strava server
  ///
  Future<void> _getStravaCode(
    String clientID,
    String scope,
    String prompt,
  ) async {
    debugPrint('Entering getStravaCode');
    String redirectUrl = kIsWeb ? appUrl : redirectUrlMobile;

    final params = '?client_id=$clientID&redirect_uri=$redirectUrl'
        '&response_type=code&approval_prompt=$prompt&scope=$scope';

    final reqAuth = authorizationEndpoint + params;
    debugPrint(reqAuth);
    StreamSubscription? sub;

    // closeWebView();
    launchUrlString(reqAuth, mode: LaunchMode.externalApplication);

    //--------  NOT working yet on web
    if (kIsWeb) {
      debugPrint('Running in web ');

      // listening on http the answer from Strava
      final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
      await for (HttpRequest request in server) {
        // Get the answer from Strava
        // final uri = request.uri;
        debugPrint('Get the answer from Strava to authenticate! ${request.uri}');
      }
    } else {
      debugPrint('Running on iOS or Android');

      // Attach a listener to the stream
      sub = AppLinks().uriLinkStream.listen((Uri? uri) {
        if (uri == null) {
          debugPrint('Subscription was null');
          sub?.cancel();
        } else {
          // Parse the link and warn the user, if it is not correct
          debugPrint('Got a link!! $uri');
          if (uri.scheme.compareTo('${redirectUrlScheme}_$clientID') != 0) {
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

/****
    if (Platform.isIOS) {
      // Launch small http server to collect the answer from Strava
      //------------------------------------------------------------
      final server =
          // await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
          await HttpServer.bind(InternetAddress.loopbackIPv4, 8080,
              shared: true);
      // server.listen((HttpRequest request) async {
      await for (HttpRequest request in server) {
        // Get the answer from Strava
        final uri = request.uri;

        code = uri.queryParameters["code"];
        final error = uri.queryParameters["error"];
        request.response.close();
        debugPrint('code $code, error $error');

        closeWebView();
        server.close(force: true);

        onCodeReceived.add(code);

        debugPrint('iOS Got the new code: $code');
      }
    }
    // });
***/
  }

  Future<bool> hasValidToken() async {
    final prefService = Get.find<BasePrefService>();
    String? accessToken = prefService.get<String>(stravaAccessTokenTag);
    if (accessToken == null || accessToken.isEmpty || accessToken == "null") {
      return false;
    }
    final StravaToken tokenStored = await _getStoredToken();
    accessToken = tokenStored.accessToken;
    return (accessToken?.length ?? 0) > 0;
  }

  /// Do Strava Authentication.
  /// clientID: ID of your Strava app
  /// scope: Strava scope check https://developers.strava.com/docs/oauth-updates/
  /// prompt: to choose to ask Strava always to authenticate or only when needed (with 'auto')
  ///
  /// Do not do/show the Strava login if a token has been stored previously
  /// and is not expired
  ///
  /// Do/show the Strava login if the scope has been changed since last storage of the token
  /// return true if no problem in authentication has been found
  Future<bool> oauth(
    String clientId,
    String scope,
    String secret,
    String prompt,
  ) async {
    debugPrint('Welcome to Strava OAuth');
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
      // token != null || token != "null"
      RefreshAnswer refreshAnswer =
          await _getNewAccessToken(clientId, secret, tokenStored.refreshToken ?? "0");
      // Update with new values if HTTP status code is 200
      if (refreshAnswer.fault != null &&
          refreshAnswer.fault!.statusCode >= 200 &&
          refreshAnswer.fault!.statusCode < 300) {
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
      isAuthOk = await _newAuthorization(clientId, secret, scope, prompt);
    } else {
      isAuthOk = true;
    }

    return isAuthOk;
  }

  Future<bool> _newAuthorization(
    String clientID,
    String secret,
    String scope,
    String prompt,
  ) async {
    bool returnValue = false;

    await _getStravaCode(clientID, scope, prompt);

    final stravaCode = await onCodeReceived.stream.first;

    final answer = await _getStravaToken(clientID, secret, stravaCode);

    debugPrint('answer ${answer.expiresAt}, ${answer.accessToken}');

    // Save the token information
    if (answer.accessToken != null && answer.accessToken!.isNotEmpty && answer.expiresAt != null) {
      await _saveToken(answer.accessToken, answer.refreshToken, answer.expiresAt, scope);
      returnValue = true;
    }

    return returnValue;
  }

  /// _getNewAccessToken
  /// Ask to Strava a new access token
  /// Return
  ///   accessToken
  ///   refreshToken (because Strava can change it
  ///     when asking for new access token)
  Future<RefreshAnswer> _getNewAccessToken(
    String clientID,
    String secret,
    String refreshToken,
  ) async {
    var returnToken = RefreshAnswer();

    final params = '?client_id=$clientID&client_secret=$secret'
        '&grant_type=refresh_token&refresh_token=$refreshToken';
    final urlRefresh = tokenEndpoint + params;

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

  Future<StravaToken> _getStravaToken(
    String clientID,
    String secret,
    String code,
  ) async {
    var answer = StravaToken();

    debugPrint('Entering getStravaToken!!');
    // Put your own secret in secret.dart
    final params =
        '?client_id=$clientID&client_secret=$secret&code=$code&grant_type=authorization_code';
    final urlToken = tokenEndpoint + params;

    debugPrint('urlToken $urlToken');

    final value = await http.post(Uri.parse(urlToken));

    debugPrint('body ${value.body}');

    if (value.body.contains('message')) {
      // This is not the normal message
      debugPrint('Error in getStravaToken');
      // will return answer null
    } else {
      final Map<String, dynamic> tokenBody = json.decode(value.body);
      final StravaToken body = StravaToken.fromJson(tokenBody);
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
  bool _isTokenExpired(StravaToken token) {
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
  /// Useful when doing test to force the Strava login
  ///
  ///return codes:
  /// statusOK or statusNoAuthenticationYet
  Future<Fault> deAuthorize() async {
    final token =
        Get.isRegistered<StravaToken>() ? Get.find<StravaToken>() : await _getStoredToken();
    final header = token.getAuthorizationHeader();
    var fault = Fault(StravaStatusCode.statusUnknownError, "Unknown reason");
    // If header is not "empty"
    if (header.containsKey('88') == false) {
      debugPrint('request $deauthorizationEndpoint');
      final rep = await http.post(Uri.parse(deauthorizationEndpoint), headers: header);
      if (rep.statusCode >= 200 && rep.statusCode < 300) {
        debugPrint('DeAuthorize done');
        debugPrint('response ${rep.body}');
        fault.statusCode = StravaStatusCode.statusOk;
        fault.message = 'DeAuthorize done';
      } else {
        debugPrint('Problem in deAuthorize request');
        fault.statusCode = StravaStatusCode.statusDeAuthorizeError;
      }
    } else {
      // No authorization has been done before
      debugPrint('No Authentication has been done yet');
      fault.statusCode = StravaStatusCode.statusNoAuthenticationYet;
      fault.message = 'No Authentication has been done yet';
    }
    await _saveToken(null, null, null, null);

    return fault;
  }
}
