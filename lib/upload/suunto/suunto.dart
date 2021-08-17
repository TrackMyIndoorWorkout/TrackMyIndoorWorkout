import 'oauth.dart';
import 'upload.dart';

/// Initialize the Suunto API
///  clientID: ID of your Suunto app
/// redirectURL: url that will be called after Strava authorize your app
class Suunto with Upload, Auth {
  final String secret;

  Suunto(this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
