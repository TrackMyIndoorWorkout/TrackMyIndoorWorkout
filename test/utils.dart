import 'dart:math';

import 'package:track_my_indoor_exercise/utils/constants.dart';

const SMALL_REPETITION = 10;
const REPETITION = 50;

const SPORTS = [
  ActivityType.Ride,
  ActivityType.Run,
  ActivityType.Kayaking,
  ActivityType.Canoeing,
  ActivityType.Rowing,
  ActivityType.Swim,
  ActivityType.Elliptical,
];

extension RangeExtension on int {
  List<int> to(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

List<int> getRandomInts(int count, int max, Random source) {
  return List<int>.generate(count, (index) => source.nextInt(max));
}

List<double> getRandomDoubles(int count, double max, Random source) {
  return List<double>.generate(count, (index) => source.nextDouble() * max);
}

String getRandomSport() {
  return SPORTS[Random().nextInt(SPORTS.length)];
}
