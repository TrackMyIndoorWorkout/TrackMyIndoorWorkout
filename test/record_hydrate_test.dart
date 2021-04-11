import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'utils.dart';

void main() {
  group("hydrate should initialize dt based on timeStamp:", () {
    1.to(SMALL_REPETITION).forEach((input) {
      final randomDateTime = mockDate();
      SPORTS.forEach((sport) {
        test("$input -> $randomDateTime", () {
          var record =
              RecordWithSport(timeStamp: randomDateTime.millisecondsSinceEpoch, sport: sport);
          record.hydrate(sport);
          expect(record.dt, randomDateTime);
        });
      });
    });
  });

  group('Constructor initializes dt', () {
    SPORTS.forEach((sport) {
      test("$sport", () {
        final now = DateTime.now();
        final record = RecordWithSport(sport: sport);
        expect(now.millisecondsSinceEpoch - record.dt.millisecondsSinceEpoch < 100, true);
      });
    });
  });
}
