import 'fit_serializable.dart';

class FitHeader extends FitSerializable {
  static const GYM_TRACKER_PROFILE_VERSION = 2066; // 0x0812, little endian
  static const SUUNTO_PROFILE_VERSION = 2083; // 0x0823, little endian

  final int headerSize = 14;
  int protocolVersion = 32; // 0x20
  int profileVersion = SUUNTO_PROFILE_VERSION;
  int dataSize; // 4 bytes, little endian
  final List<int> dataType = [0x2E, 0x46, 0x49, 0x54]; // ".FIT"

  FitHeader({this.protocolVersion, this.profileVersion}) : super();

  List<int> binarySerialize() {
    output = [headerSize, profileVersion];
    addInteger(profileVersion);
    addLong(dataSize);
    output.addAll(dataType);
    return super.binarySerialize();
  }
}
