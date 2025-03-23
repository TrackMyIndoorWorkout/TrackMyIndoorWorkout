import 'fault.dart';

class StravaToken {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresAt; // in seconds
  String? scope;

  StravaToken({this.accessToken, this.refreshToken, this.expiresAt, this.scope});

  factory StravaToken.fromJson(Map<String, dynamic> json) => StravaToken.fromMap(json);

  Map toMap() => StravaToken.toJsonMap(this);

  @override
  String toString() => StravaToken.toJsonMap(this).toString();

  static Map toJsonMap(StravaToken model) {
    return {
      'access_token': model.accessToken ?? 'Error',
      'token_type': model.tokenType ?? 'Error',
      'refresh_token': model.refreshToken ?? 'Error',
      'expires_at': model.expiresAt ?? 'Error',
    };
  }

  static StravaToken fromMap(Map<String, dynamic> map) {
    return StravaToken()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..tokenType = map['token_type']
      ..expiresAt = map['expires_at'];
  }

  /// Generate the header to use with http requests
  ///
  /// return {null, null} if there is not token yet
  /// stored in globals
  Map<String, String> getAuthorizationHeader() {
    if (accessToken != null &&
        accessToken!.isNotEmpty &&
        accessToken != "Error" &&
        accessToken != "null") {
      return {'Authorization': 'Bearer $accessToken'};
    } else {
      return {'88': '00'};
    }
  }
}

class RefreshAnswer {
  Fault? fault;
  String? accessToken;
  String? refreshToken;
  int? expiresAt; // in seconds

  RefreshAnswer();

  factory RefreshAnswer.fromJson(Map<String, dynamic> json) => RefreshAnswer.fromMap(json);

  static RefreshAnswer fromMap(Map<String, dynamic> map) {
    RefreshAnswer model =
        RefreshAnswer()
          ..accessToken = map['access_token']
          ..refreshToken = map['refresh_token']
          ..expiresAt = map['expires_at'];

    return model;
  }
}
