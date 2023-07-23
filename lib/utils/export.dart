import 'dart:typed_data';

List<int> lengthToBytes(int len) {
  final List<int> bytes = [];
  for (int i = 0; i < 4; i++) {
    bytes.add(len & 0xFF);
    len = len ~/ 256;
  }

  return bytes;
}

int lengthBytesToInt(List<int> lengthBytes) {
  var blob = ByteData.sublistView(Int8List.fromList(lengthBytes));
  return blob.getUint32(0, Endian.little);
}
