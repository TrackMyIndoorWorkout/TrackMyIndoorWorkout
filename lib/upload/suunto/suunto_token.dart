class SuuntoToken {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresAt; // in seconds

  SuuntoToken({this.accessToken, this.refreshToken, this.expiresAt});

  factory SuuntoToken.fromJson(Map<String, dynamic> json) => SuuntoToken.fromMap(json);

  Map toMap() => SuuntoToken.toJsonMap(this);

  @override
  String toString() => SuuntoToken.toJsonMap(this).toString();

  static Map toJsonMap(SuuntoToken model) {
    return {
      'access_token': model.accessToken ?? 'Error',
      'token_type': model.tokenType ?? 'Error',
      'refresh_token': model.refreshToken ?? 'Error',
      'expires_in': model.expiresAt != null
          ? (model.expiresAt! - DateTime.now().millisecondsSinceEpoch ~/ 1000)
          : 'Error',
    };
  }

  static SuuntoToken fromMap(Map<String, dynamic> map) {
    return SuuntoToken()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..tokenType = map['token_type']
      ..expiresAt = map['expires_in'] + DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Generate the header to use with http requests
  ///
  /// return {null, null} if there is not token yet
  /// stored in globals
  Map<String, String> getAuthorizationHeader(String subscriptionKey) {
    if (accessToken != null &&
        accessToken!.isNotEmpty &&
        accessToken != "Error" &&
        accessToken != "null") {
      return {
        'Authorization': 'Bearer $accessToken',
        'Ocp-Apim-Subscription-Key': subscriptionKey,
      };
    } else {
      return {'88': '00'};
    }
  }
}

class RefreshAnswer {
  int? statusCode;
  String? accessToken;
  String? refreshToken;
  int? expiresAt; // in seconds

  RefreshAnswer();

  factory RefreshAnswer.fromJson(Map<String, dynamic> json) => RefreshAnswer.fromMap(json);

  static RefreshAnswer fromMap(Map<String, dynamic> map) {
    RefreshAnswer model = RefreshAnswer()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..expiresAt = map['expires_in'] + DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return model;
  }
}
