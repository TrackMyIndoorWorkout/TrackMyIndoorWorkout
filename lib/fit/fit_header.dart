class FitHeader {
  final int	headerSize = 14;
  final int protocolVersion = 32; // 0x20
  final int profileVersion = 2066; // 0x0812, little endian
  int dataSize; // 4 bytes, little endian
  final String dataType = ".FIT";
  int crc; // 2 bytes little endian
}
