/// List of statuscode used by Fault set in Strava API
class StravaStatusCode {
  static const int statusOk = 0;
  static const int statusInvalidToken = 1;
  static const int statusUnknownError = 2;
  static const int statusTokenNotKnownYet = 3;
  static const int statusNotFound = 4;
  static const int statusNoAuthenticationYet = 5;
  static const int statusJsonIsEmpty = 6;
  static const int statusAuthError = 7;
  static const int statusDeAuthorizeError = 8;
  static const int statusSegmentNotRidden = 9;
}
