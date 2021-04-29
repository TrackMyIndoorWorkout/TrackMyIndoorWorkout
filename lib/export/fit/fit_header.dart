import 'dart:convert';

import 'fit_serializable.dart';

class FitHeader extends FitSerializable {
  static const GYM_TRACKER_PROFILE_VERSION = 2066; // 0x0812, little endian
  static const SUUNTO_PROFILE_VERSION = 2083; // 0x0823, little endian

  final int headerSize = 14;
  int protocolVersion = 32; // 0x20
  int profileVersion = SUUNTO_PROFILE_VERSION;
  final int dataSize; // 4 bytes, little endian
  final String dataType = ".FIT";

  FitHeader({this.dataSize}) : super();

  List<int> binarySerialize() {
    output = [headerSize, protocolVersion];
    addShort(profileVersion);
    addLong(dataSize);
    output.addAll(utf8.encode(dataType));
    return super.binarySerialize();
  }
}
