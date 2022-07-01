import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'string_ex.dart';

extension GuidEx on Guid {
  String uuidString() {
    return toString().uuidString();
  }
}
