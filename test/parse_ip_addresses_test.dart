import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

class TestPair {
  final String addresses;
  final List<Tuple2<String, int>> expected;

  const TestPair({required this.addresses, required this.expected});
}

void main() {
  group('parseIpAddresses corner cases', () {
    for (final testPair in [
      const TestPair(addresses: "", expected: []),
      const TestPair(addresses: "", expected: []),
      const TestPair(addresses: " ", expected: []),
      const TestPair(addresses: "*^&@%", expected: []),
      const TestPair(addresses: "abc", expected: []),
      const TestPair(addresses: " abc ", expected: []),
      const TestPair(addresses: " abc123 ", expected: []),
      const TestPair(addresses: " 123abc ", expected: []),
      const TestPair(addresses: "1", expected: []),
      const TestPair(addresses: " 1", expected: []),
      const TestPair(addresses: "1 ", expected: []),
      const TestPair(addresses: "  1  ", expected: []),
      const TestPair(addresses: "1.", expected: []),
      const TestPair(addresses: "...", expected: []),
      const TestPair(addresses: " . . . ", expected: []),
      const TestPair(addresses: "1.2", expected: []),
      const TestPair(addresses: "1.2.", expected: []),
      const TestPair(addresses: "1.2.3", expected: []),
      const TestPair(addresses: "1.2.3.", expected: []),
      const TestPair(addresses: "1.a.2.3", expected: []),
      const TestPair(addresses: "1.2.3.444", expected: []),
      const TestPair(addresses: "1111.2.3.4", expected: []),
      const TestPair(addresses: "1.2.3.4.5", expected: []),
      const TestPair(addresses: "-1.2.3.4", expected: []),
      const TestPair(addresses: "1.-2.3.4", expected: []),
      const TestPair(addresses: " 1 . 2 . 3 . 4 ", expected: []),
      const TestPair(addresses: "1.2.3.4:0", expected: []),
      const TestPair(addresses: "1.2.3.4:65536", expected: []),
      const TestPair(addresses: "1.2.3.4", expected: [Tuple2<String, int>("1.2.3.4", httpsPort)]),
      const TestPair(addresses: " 1.2.3.4", expected: [Tuple2<String, int>("1.2.3.4", httpsPort)]),
      const TestPair(addresses: "1.2.3.4:55", expected: [Tuple2<String, int>("1.2.3.4", 55)]),
      const TestPair(
          addresses: "1.2.3.4:55,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
      const TestPair(
          addresses: "1.2.3.4:55,0.0.0.0,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
      const TestPair(
          addresses: "1.2.3.4:55,2.3.4.5:100000,6.7.8.9:100",
          expected: [Tuple2<String, int>("1.2.3.4", 55), Tuple2<String, int>("6.7.8.9", 100)]),
    ]) {
      test("${testPair.addresses} -> ${testPair.expected}", () async {
        final list = parseIpAddresses(testPair.addresses);
        expect(listEquals(list, testPair.expected), true);
      });
    }
  });
}
