class TrainingPeaksToken {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresAt; // in seconds
  String? scope;

  TrainingPeaksToken({this.accessToken, this.refreshToken, this.expiresAt, this.scope});

  factory TrainingPeaksToken.fromJson(Map<String, dynamic> json) =>
      TrainingPeaksToken.fromMap(json);

  Map toMap() => TrainingPeaksToken.toJsonMap(this);

  @override
  String toString() => TrainingPeaksToken.toJsonMap(this).toString();

  static Map toJsonMap(TrainingPeaksToken model) {
    return {
      'access_token': model.accessToken ?? 'Error',
      'token_type': model.tokenType ?? 'Error',
      'refresh_token': model.refreshToken ?? 'Error',
      'expires_in': model.expiresAt != null
          ? (model.expiresAt! - DateTime.now().millisecondsSinceEpoch ~/ 1000)
          : 'Error',
    };
  }

  static TrainingPeaksToken fromMap(Map<String, dynamic> map) {
    return TrainingPeaksToken()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..tokenType = map['token_type']
      ..expiresAt = map['expires_in'] + DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Generate the header to use with http requests
  ///
  /// return {null, null} if there is not token yet
  /// stored in globals
  Map<String, String> getAuthorizationHeader(String clientId) {
    if (accessToken != null && accessToken!.length > 0 && accessToken != "Error") {
      return {
        'Authorization': 'Bearer $accessToken',
        'Api-Key': clientId,
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
