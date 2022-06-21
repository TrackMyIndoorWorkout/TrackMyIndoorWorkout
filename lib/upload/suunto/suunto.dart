import 'oauth.dart';
import 'upload.dart';

/// Initialize the Suunto API
class Suunto with Upload, Auth {
  final String secret;
  final String clientId;
  final String subscriptionKey;

  Suunto(this.clientId, this.secret, this.subscriptionKey);

  void dispose() {
    onCodeReceived.close();
  }
}
