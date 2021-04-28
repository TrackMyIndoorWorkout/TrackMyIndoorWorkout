import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_sport.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';

import 'utils.dart';

void main() {
  test('FitSport has the expected global message number', () async {
    final sport = FitSport(0);

    expect(sport.globalMessageNumber, FitMessage.Sport);
  });

  group('FitSport data has the expected length', () {
    SPORTS.forEach((sport) {
      final fileCreator = FitSport(0);
      final expected = fileCreator.fields.fold(0, (accu, field) => accu + field.size);

      test('$sport -> $expected', () async {
        final output = fileCreator.serializeData(sport);

        expect(output.length, expected + 1);
      });
    });
  });
}
