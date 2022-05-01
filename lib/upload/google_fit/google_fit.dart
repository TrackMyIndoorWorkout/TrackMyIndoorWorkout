import 'oauth.dart';
import 'upload.dart';

/// Initialize the Google Fit API
class GoogleFit with Upload, Auth {
  final String clientId;
  final String secret;

  /// Initialize the Google Fit class
  /// Needed to call Google Fit API
  ///
  /// secretKey is the key found in Google Fit settings my Application (secret key)
  GoogleFit(this.clientId, this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
