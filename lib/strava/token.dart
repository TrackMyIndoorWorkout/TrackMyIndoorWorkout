import 'fault.dart';

class Token {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresAt;
  String? scope;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) => Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    return {
      'access_token': model.accessToken ?? 'Error',
      'token_type': model.tokenType ?? 'Error',
      'refresh_token': model.refreshToken ?? 'Error',
      'expires_at': model.expiresAt ?? 'Error',
    };
  }

  static Token fromMap(Map<String, dynamic> map) {
    return Token()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..tokenType = map['token_type']
      ..expiresAt = map['expires_at'];
  }
}

class RefreshAnswer {
  Fault? fault;
  String? accessToken;
  String? refreshToken;
  int? expiresAt;

  RefreshAnswer();

  factory RefreshAnswer.fromJson(Map<String, dynamic> json) => RefreshAnswer.fromMap(json);

  static RefreshAnswer fromMap(Map<String, dynamic> map) {
    RefreshAnswer model = RefreshAnswer()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..expiresAt = map['expires_at'];

    return model;
  }
}
