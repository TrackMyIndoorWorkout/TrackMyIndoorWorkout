import 'oauth.dart';
import 'upload.dart';

/// Initialize the Training Peaks API
class TrainingPeaks with Upload, Auth {
  final String clientId;
  final String secret;

  /// Initialize the Training Peaks class
  /// Needed to call Training Peaks API
  ///
  /// secretKey is the key found in Training Peaks settings my Application (secret key)
  TrainingPeaks(this.clientId, this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
