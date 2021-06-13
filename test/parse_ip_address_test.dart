import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String address;
  final Tuple2<String, int> expected;

  TestPair({required this.address, required this.expected});
}

void main() {
  group('parseIpAddress corner cases', () {
    [
      TestPair(address: "", expected: dummyAddressTuple),
      TestPair(address: "", expected: dummyAddressTuple),
      TestPair(address: " ", expected: dummyAddressTuple),
      TestPair(address: "*^&@%", expected: dummyAddressTuple),
      TestPair(address: "abc", expected: dummyAddressTuple),
      TestPair(address: " abc ", expected: dummyAddressTuple),
      TestPair(address: " abc123 ", expected: dummyAddressTuple),
      TestPair(address: " 123abc ", expected: dummyAddressTuple),
      TestPair(address: "1", expected: dummyAddressTuple),
      TestPair(address: " 1", expected: dummyAddressTuple),
      TestPair(address: "1 ", expected: dummyAddressTuple),
      TestPair(address: "  1  ", expected: dummyAddressTuple),
      TestPair(address: "1.", expected: dummyAddressTuple),
      TestPair(address: "...", expected: dummyAddressTuple),
      TestPair(address: " . . . ", expected: dummyAddressTuple),
      TestPair(address: "1.2", expected: dummyAddressTuple),
      TestPair(address: "1.2.", expected: dummyAddressTuple),
      TestPair(address: "1.2.3", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.", expected: dummyAddressTuple),
      TestPair(address: "1.a.2.3", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.444", expected: dummyAddressTuple),
      TestPair(address: "1111.2.3.4", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.4.5", expected: dummyAddressTuple),
      TestPair(address: "-1.2.3.4", expected: dummyAddressTuple),
      TestPair(address: "1.-2.3.4", expected: dummyAddressTuple),
      TestPair(address: " 1 . 2 . 3 . 4 ", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.4:0", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.4:65536", expected: dummyAddressTuple),
      TestPair(address: "2.3.4.5:100000", expected: dummyAddressTuple),
      TestPair(address: "0.0.0.0", expected: dummyAddressTuple),
      TestPair(address: "1.2.3.4", expected: Tuple2<String, int>("1.2.3.4", HTTPS_PORT)),
      TestPair(address: " 1.2.3.4", expected: Tuple2<String, int>("1.2.3.4", HTTPS_PORT)),
      TestPair(address: "1.2.3.4:55", expected: Tuple2<String, int>("1.2.3.4", 55)),
      TestPair(address: "6.7.8.9:100", expected: Tuple2<String, int>("6.7.8.9", 100)),
    ].forEach((testPair) {
      test("${testPair.address} -> ${testPair.expected}", () async {
        final tuple = parseIpAddress(testPair.address);
        expect(tuple, testPair.expected);
      });
    });
  });

  group('parseIpAddress random test', () {
    final rnd = Random();
    List.generate(REPETITION, (index) => index).forEach((index) {
      final ipParts = getRandomInts(4, 320, rnd);
      final port = rnd.nextInt(81920);
      final valid = ipParts.fold<bool>(true, (prev, part) => prev && part < MAX_UINT8) &&
          ipParts[0] > 0 &&
          port > 0 &&
          port < MAX_UINT16;
      final addressString = ipParts.map((part) => part.toString()).join(".");
      final fullAddress = addressString + ":$port";
      final expected = valid ? Tuple2<String, int>(addressString, port) : dummyAddressTuple;
      test('$fullAddress -> $expected', () async {
        expect(parseIpAddress(fullAddress), expected);
      });
    });
  });
}
