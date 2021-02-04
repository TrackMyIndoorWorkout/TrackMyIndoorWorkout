import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import '../lib/persistence/models/record.dart';

extension RangeExtension on int {
  List<int> to(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

void main() {
  group("hydrate should initialize dt based on timeStamp:", () {
    1.to(10).forEach((input) {
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
