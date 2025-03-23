const List<int> crcTable = [
  0x0000,
  0xCC01,
  0xD801,
  0x1400,
  0xF001,
  0x3C00,
  0x2800,
  0xE401,
  0xA001,
  0x6C00,
  0x7800,
  0xB401,
  0x5000,
  0x9C01,
  0x8801,
  0x4400,
];

int crcByte(int crc, int byte) {
  int tmp;

  // compute checksum of lower four bits of byte
  tmp = crcTable[crc & 0xF];
  crc = (crc >> 4) & 0x0FFF;
  crc = crc ^ tmp ^ crcTable[byte & 0xF];

  // now compute checksum of upper four bits of byte
  tmp = crcTable[crc & 0xF];
  crc = (crc >> 4) & 0x0FFF;
  crc = crc ^ tmp ^ crcTable[(byte >> 4) & 0xF];

  return crc;
}

int crcData(List<int> data) {
  return data.fold<int>(0, (crc, byte) => crcByte(crc, byte));
}
