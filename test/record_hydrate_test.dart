import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import '../lib/persistence/models/record.dart';
import 'utils.dart';

void main() {
  group("hydrate should initialize dt based on timeStamp:", () {
    1.to(SMALL_REPETITION).forEach((input) {
      final randomDateTime = mockDate();
      test("$input -> $randomDateTime", () {
        var record = Record(timeStamp: randomDateTime.millisecondsSinceEpoch);
        record.hydrate();
        expect(record.dt, randomDateTime);
      });
    });

    test('no hydrate leaves dt as null', () async {
      final record = Record();
      expect(record.dt, null);
    });
  });
}
