import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final String input;
  final String expected;

  const TestPair({required this.input, required this.expected});
}

void main() {
  group('TrainingPeaks sport conversions', () {
    for (final testPair in [
      const TestPair(input: "", expected: "Other"),
      const TestPair(input: " ", expected: "Other"),
      const TestPair(input: "abc", expected: "Other"),
      const TestPair(input: ActivityType.swim, expected: "Swim"),
      const TestPair(input: ActivityType.canoeing, expected: "Rowing"),
      const TestPair(input: ActivityType.kayaking, expected: "Rowing"),
      const TestPair(input: ActivityType.rowing, expected: "Rowing"),
      const TestPair(input: ActivityType.run, expected: "Run"),
      const TestPair(input: ActivityType.ride, expected: "Bike"),
      const TestPair(input: ActivityType.elliptical, expected: "X-train"),
      const TestPair(input: ActivityType.nordicSki, expected: "Other"),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        final tp = TrainingPeaks("", "");
        expect(tp.trainingPeaksSport(testPair.input), testPair.expected);
      });
    }
  });
}
