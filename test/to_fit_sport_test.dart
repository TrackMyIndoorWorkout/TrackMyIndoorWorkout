import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_sport.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final String input;
  final String expected;

  const TestPair({required this.input, required this.expected});
}

void main() {
  group('toFitSport conversions', () {
    for (final testPair in [
      const TestPair(input: "", expected: ActivityType.Workout),
      const TestPair(input: " ", expected: ActivityType.Workout),
      const TestPair(input: "abc", expected: ActivityType.Workout),
      const TestPair(input: ActivityType.Swim, expected: ActivityType.Swim),
      const TestPair(input: ActivityType.Canoeing, expected: ActivityType.Kayaking),
      const TestPair(input: ActivityType.Kayaking, expected: ActivityType.Kayaking),
      const TestPair(input: ActivityType.Rowing, expected: ActivityType.Rowing),
      const TestPair(input: ActivityType.Run, expected: ActivityType.Run),
      const TestPair(input: ActivityType.Ride, expected: ActivityType.Ride),
      const TestPair(input: ActivityType.Elliptical, expected: ActivityType.Elliptical),
      const TestPair(input: ActivityType.NordicSki, expected: ActivityType.Workout),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(toFitSport(testPair.input), fitSport[testPair.expected]);
      });
    }
  });
}
