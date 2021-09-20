import 'oauth.dart';
import 'upload.dart';

/// Initialize the Under Armour API
class UnderArmour with Upload, Auth {
  final String clientId;
  final String secret;

  /// Initialize the Under Armour class
  /// Needed to call Under Armour API
  ///
  /// secretKey is the key found in Under Armour settings my Application (secret key)
  UnderArmour(this.clientId, this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
