import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';
import 'package:tuple/tuple.dart';

import 'utils.dart';

class TestPair {
  final String address;
  final Tuple2<String, int> expected;

  const TestPair({required this.address, required this.expected});
}

void main() {
  group('parseNetworkAddress corner cases', () {
    for (final testPair in [
      const TestPair(address: "", expected: dummyAddressTuple),
      const TestPair(address: "", expected: dummyAddressTuple),
      const TestPair(address: " ", expected: dummyAddressTuple),
      const TestPair(address: "*^&@%", expected: dummyAddressTuple),
      const TestPair(address: "abc", expected: dummyAddressTuple),
      const TestPair(address: " abc ", expected: dummyAddressTuple),
      const TestPair(address: " abc123 ", expected: dummyAddressTuple),
      const TestPair(address: " 123abc ", expected: dummyAddressTuple),
      const TestPair(address: "1", expected: dummyAddressTuple),
      const TestPair(address: " 1", expected: dummyAddressTuple),
      const TestPair(address: "1 ", expected: dummyAddressTuple),
      const TestPair(address: "  1  ", expected: dummyAddressTuple),
      const TestPair(address: "1.", expected: dummyAddressTuple),
      const TestPair(address: "...", expected: dummyAddressTuple),
      const TestPair(address: " . . . ", expected: dummyAddressTuple),
      const TestPair(address: "1.2", expected: dummyAddressTuple),
      const TestPair(address: "1.2.", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.", expected: dummyAddressTuple),
      const TestPair(address: "1.a.2.3", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.444", expected: dummyAddressTuple),
      const TestPair(address: "1111.2.3.4", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4.5", expected: dummyAddressTuple),
      const TestPair(address: "-1.2.3.4", expected: dummyAddressTuple),
      const TestPair(address: "1.-2.3.4", expected: dummyAddressTuple),
      const TestPair(address: " 1 . 2 . 3 . 4 ", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4:0", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4:65536", expected: dummyAddressTuple),
      const TestPair(address: "2.3.4.5:100000", expected: dummyAddressTuple),
      const TestPair(address: "0.0.0.0", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4:443", expected: Tuple2<String, int>("1.2.3.4", httpsPort)),
      const TestPair(address: " 1.2.3.4:443", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4:443 ", expected: Tuple2<String, int>("1.2.3.4", httpsPort)),
      const TestPair(address: " 1.2.3.4", expected: dummyAddressTuple),
      const TestPair(address: "1.2.3.4:55", expected: Tuple2<String, int>("1.2.3.4", 55)),
      const TestPair(address: "6.7.8.9:100", expected: Tuple2<String, int>("6.7.8.9", 100)),
      const TestPair(address: "ffff::1:100", expected: Tuple2<String, int>("ffff::1", 100)),
      const TestPair(address: "[ffff::1]:100", expected: Tuple2<String, int>("ffff::1", 100)),
      const TestPair(
        address: "[2001:db8:3333:4444:5555:6666:7777:8888]:100",
        expected: Tuple2<String, int>("2001:db8:3333:4444:5555:6666:7777:8888", 100),
      ),
      const TestPair(
        address: "[2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF]:100",
        expected: Tuple2<String, int>("2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF", 100),
      ),
      const TestPair(address: "[::]:100", expected: Tuple2<String, int>("::", 100)),
      const TestPair(address: "[2001:db8::]:100", expected: Tuple2<String, int>("2001:db8::", 100)),
      const TestPair(
        address: "[::1234:5678]:100",
        expected: Tuple2<String, int>("::1234:5678", 100),
      ),
      const TestPair(
        address: "[2001:db8::1234:5678]:100",
        expected: Tuple2<String, int>("2001:db8::1234:5678", 100),
      ),
      const TestPair(
        address: "[2001:0db8:0001:0000:0000:0ab9:C0A8:0102]:100",
        expected: Tuple2<String, int>("2001:0db8:0001:0000:0000:0ab9:C0A8:0102", 100),
      ),
      const TestPair(
        address: "[2001:db8:1::ab9:C0A8:102]:100",
        expected: Tuple2<String, int>("2001:db8:1::ab9:C0A8:102", 100),
      ),
      const TestPair(
        address: "2001:db8:3333:4444:5555:6666:7777:8888:100",
        expected: Tuple2<String, int>("2001:db8:3333:4444:5555:6666:7777:8888", 100),
      ),
      const TestPair(
        address: "2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF:100",
        expected: Tuple2<String, int>("2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF", 100),
      ),
      const TestPair(address: ":::100", expected: Tuple2<String, int>("::", 100)),
      const TestPair(address: "2001:db8:::100", expected: Tuple2<String, int>("2001:db8::", 100)),
      const TestPair(address: "::1234:5678:100", expected: Tuple2<String, int>("::1234:5678", 100)),
      const TestPair(
        address: "2001:db8::1234:5678:100",
        expected: Tuple2<String, int>("2001:db8::1234:5678", 100),
      ),
      const TestPair(
        address: "2001:0db8:0001:0000:0000:0ab9:C0A8:0102:100",
        expected: Tuple2<String, int>("2001:0db8:0001:0000:0000:0ab9:C0A8:0102", 100),
      ),
      const TestPair(
        address: "2001:db8:1::ab9:C0A8:102:100",
        expected: Tuple2<String, int>("2001:db8:1::ab9:C0A8:102", 100),
      ),
      const TestPair(
        address: "www.mydomain.com:55",
        expected: Tuple2<String, int>("www.mydomain.com", 55),
      ),
      const TestPair(address: "a.b.app:100", expected: Tuple2<String, int>("a.b.app", 100)),
    ]) {
      test("${testPair.address} -> ${testPair.expected}", () async {
        final tuple = parseNetworkAddress(testPair.address, false);
        expect(tuple, testPair.expected);
      });
    }
  });

  group('parseNetworkAddress does not accept domain names by default', () {
    for (final testPair in [
      const TestPair(address: "6.7.8.9:100", expected: Tuple2<String, int>("6.7.8.9", 100)),
      const TestPair(address: "www.mydomain.com:55", expected: dummyAddressTuple),
      const TestPair(address: "a.b.app:100", expected: dummyAddressTuple),
    ]) {
      test("${testPair.address} -> ${testPair.expected}", () async {
        final tuple = parseNetworkAddress(testPair.address);
        expect(tuple, testPair.expected);
      });
    }
  });

  group('parseNetworkAddress IPv4 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(4, 320, rnd);
      final port = rnd.nextInt(81920);
      final valid =
          ipParts.fold<bool>(true, (prev, part) => prev && part < maxUint8) &&
          port > 0 &&
          port < maxUint16;
      final addressString = ipParts.map((part) => part.toString()).join(".");
      final fullAddress = "$addressString:$port";
      final expected = valid ? Tuple2<String, int>(addressString, port) : dummyAddressTuple;
      test('$index.: $fullAddress -> $expected', () async {
        expect(parseNetworkAddress(fullAddress), expected);
      });
    }
  });
}
