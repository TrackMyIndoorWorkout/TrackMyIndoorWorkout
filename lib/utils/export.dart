import 'dart:typed_data';

List<int> lengthToBytes(int len) {
  final List<int> bytes = [];
  bytes.add(len & 0xFF);
  bytes.add(len & 0xFF00);
  bytes.add(len & 0xFF0000);
  bytes.add(len & 0xFF000000);
  return bytes;
}

int lengthBytesToInt(List<int> lengthBytes) {
  var blob = ByteData.sublistView(Int8List.fromList(lengthBytes));
  return blob.getUint32(0, Endian.little);
}
