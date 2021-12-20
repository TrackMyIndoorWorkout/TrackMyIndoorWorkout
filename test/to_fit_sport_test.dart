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
      const TestPair(input: "", expected: ActivityType.workout),
      const TestPair(input: " ", expected: ActivityType.workout),
      const TestPair(input: "abc", expected: ActivityType.workout),
      const TestPair(input: ActivityType.swim, expected: ActivityType.swim),
      const TestPair(input: ActivityType.canoeing, expected: ActivityType.kayaking),
      const TestPair(input: ActivityType.kayaking, expected: ActivityType.kayaking),
      const TestPair(input: ActivityType.rowing, expected: ActivityType.rowing),
      const TestPair(input: ActivityType.run, expected: ActivityType.run),
      const TestPair(input: ActivityType.ride, expected: ActivityType.ride),
      const TestPair(input: ActivityType.elliptical, expected: ActivityType.elliptical),
      const TestPair(input: ActivityType.nordicSki, expected: ActivityType.workout),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(toFitSport(testPair.input), fitSport[testPair.expected]);
      });
    }
  });
}
