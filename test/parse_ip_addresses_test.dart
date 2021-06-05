import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

class TestPair {
  final String addresses;
  final List<Tuple2<String, int>> expected;

  TestPair({required this.addresses, required this.expected});
}

void main() {
  group('parseIpAddresses corner cases', () {
    [
      TestPair(addresses: "", expected: []),
      TestPair(addresses: "", expected: []),
      TestPair(addresses: " ", expected: []),
      TestPair(addresses: "*^&@%", expected: []),
      TestPair(addresses: "abc", expected: []),
      TestPair(addresses: " abc ", expected: []),
      TestPair(addresses: " abc123 ", expected: []),
      TestPair(addresses: " 123abc ", expected: []),
      TestPair(addresses: "1", expected: []),
      TestPair(addresses: " 1", expected: []),
      TestPair(addresses: "1 ", expected: []),
      TestPair(addresses: "  1  ", expected: []),
      TestPair(addresses: "1.", expected: []),
      TestPair(addresses: "...", expected: []),
      TestPair(addresses: " . . . ", expected: []),
      TestPair(addresses: "1.2", expected: []),
      TestPair(addresses: "1.2.", expected: []),
      TestPair(addresses: "1.2.3", expected: []),
      TestPair(addresses: "1.2.3.", expected: []),
      TestPair(addresses: "1.a.2.3", expected: []),
      TestPair(addresses: "1.2.3.444", expected: []),
      TestPair(addresses: "1111.2.3.4", expected: []),
      TestPair(addresses: "1.2.3.4.5", expected: []),
      TestPair(addresses: "-1.2.3.4", expected: []),
      TestPair(addresses: "1.-2.3.4", expected: []),
      TestPair(addresses: " 1 . 2 . 3 . 4 ", expected: []),
      TestPair(addresses: "1.2.3.4:0", expected: []),
      TestPair(addresses: "1.2.3.4:65536", expected: []),
      TestPair(addresses: "1.2.3.4", expected: [Tuple2<String, int>("1.2.3.4", HTTPS_PORT)]),
      TestPair(addresses: " 1.2.3.4", expected: [Tuple2<String, int>("1.2.3.4", HTTPS_PORT)]),
      TestPair(addresses: "1.2.3.4:55", expected: [Tuple2<String, int>("1.2.3.4", 55)]),
      TestPair(
          addresses: "1.2.3.4:55,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
      TestPair(
          addresses: "1.2.3.4:55,0.0.0.0,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
      TestPair(
          addresses: "1.2.3.4:55,2.3.4.5:100000,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
    ].forEach((testPair) {
      test("${testPair.addresses} -> ${testPair.expected}", () async {
        final list = parseIpAddresses(testPair.addresses);
        expect(listEquals(list, testPair.expected), true);
      });
    });
  });
}
