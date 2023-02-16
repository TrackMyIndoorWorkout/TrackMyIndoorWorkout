import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("hydrate should initialize dt based on timeStamp:", () {
    for (var input in List<int>.generate(smallRepetition, (index) => index)) {
      final randomDateTime = mockDate();
      for (final sport in allSports) {
        test("$input -> $randomDateTime", () {
          var record =
              RecordWithSport(timeStamp: randomDateTime.millisecondsSinceEpoch, sport: sport);
          record.hydrate(sport);
          expect(record.dt, randomDateTime);
        });
      }
    }
  });

  group('Constructor initializes dt', () {
    for (final sport in allSports) {
      test(sport, () {
        final now = DateTime.now();
        final record = RecordWithSport(sport: sport);
        expect(record.dt?.millisecondsSinceEpoch ?? 0, closeTo(now.millisecondsSinceEpoch, 100));
      });
    }
  });
}
