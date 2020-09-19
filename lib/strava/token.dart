import 'fault.dart';

class Token {
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresAt;
  String scope;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) => Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    Map ret = new Map();
    ret['access_token'] = model.accessToken ?? 'Error';
    ret['token_type'] = model.tokenType ?? 'Error';
    ret['refresh_token'] = model.refreshToken ?? 'Error';
    ret['expires_at'] = model.expiresAt ?? 'Error';

    return ret;
  }

  static Token fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Token model = new Token();
    model.accessToken = map['access_token'];
    model.refreshToken = map['refresh_token'];
    model.tokenType = map['token_type'];
    model.expiresAt = map['expires_at'];
    return model;
  }
}

class RefreshAnswer {
  Fault fault;
  String accessToken;
  String refreshToken;
  int expiresAt;

  RefreshAnswer();

  factory RefreshAnswer.fromJson(Map<String, dynamic> json) =>
      RefreshAnswer.fromMap(json);

  static RefreshAnswer fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    RefreshAnswer model = RefreshAnswer();
    model.accessToken = map['access_token'];
    model.refreshToken = map['refresh_token'];
    model.expiresAt = map['expires_at'];
    return model;
  }
}
