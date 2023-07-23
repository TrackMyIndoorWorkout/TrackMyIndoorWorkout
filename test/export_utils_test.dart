import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/export.dart';
import 'utils.dart';

main() {
  group('int32 serialization and deserialization matches', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 4294967295, rnd).forEach((length) {
      final bytes = lengthToBytes(length);
      test('$length -> $bytes', () async {
        expect(bytes.length, 4);

        final lengthDeserialized = lengthBytesToInt(bytes);

        expect(length, lengthDeserialized);
      });
    });
  });
}
