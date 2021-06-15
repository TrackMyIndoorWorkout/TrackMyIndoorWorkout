import 'oauth.dart';
import 'upload.dart';

/// Initialize the Strava API
///  clientID: ID of your Strava app
/// redirectURL: url that will be called after Strava authorize your app
/// prompt: to choose to ask Strava always to authenticate or only when needed (with 'auto')
/// scope: Strava scope check https://developers.strava.com/docs/oauth-updates/
class Strava with Upload, Auth {
  final String secret;

  /// Initialize the Strava class
  /// Needed to call Strava API
  ///
  /// secretKey is the key found in strava settings my Application (secret key)
  Strava(this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
