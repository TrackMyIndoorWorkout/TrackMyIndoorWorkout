import 'oauth.dart';
import 'upload.dart';

/// Initialize the Strava API
class Strava with Upload, Auth {
  final String clientId;
  final String secret;

  /// Initialize the Strava class
  /// Needed to call Strava API
  ///
  /// secretKey is the key found in strava settings my Application (secret key)
  Strava(this.clientId, this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
