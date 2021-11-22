import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final String input;
  final String expected;

  TestPair({required this.input, required this.expected});
}

void main() {
  group('TrainingPeaks sport conversions', () {
    for (var testPair in [
      TestPair(input: "", expected: "Other"),
      TestPair(input: " ", expected: "Other"),
      TestPair(input: "abc", expected: "Other"),
      TestPair(input: ActivityType.Swim, expected: "Swim"),
      TestPair(input: ActivityType.Canoeing, expected: "Rowing"),
      TestPair(input: ActivityType.Kayaking, expected: "Rowing"),
      TestPair(input: ActivityType.Rowing, expected: "Rowing"),
      TestPair(input: ActivityType.Run, expected: "Run"),
      TestPair(input: ActivityType.Ride, expected: "Bike"),
      TestPair(input: ActivityType.Elliptical, expected: "X-train"),
      TestPair(input: ActivityType.NordicSki, expected: "Other"),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        final tp = TrainingPeaks("", "");
        expect(tp.trainingPeaksSport(testPair.input), testPair.expected);
      });
    }
  });
}
