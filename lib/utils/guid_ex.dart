import 'package:flutter_blue/flutter_blue.dart';
import 'string_ex.dart';

extension GuidEx on Guid {
  String uuidString() {
    return this.toString().uuidString();
  }
}
