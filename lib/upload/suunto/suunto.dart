import 'dart:convert';

import 'oauth.dart';
import 'upload.dart';

/// Initialize the Suunto API
class Suunto with Upload, Auth {
  final String secret;
  final String clientId;

  Suunto(this.clientId, this.secret);

  void dispose() {
    onCodeReceived.close();
  }
}
