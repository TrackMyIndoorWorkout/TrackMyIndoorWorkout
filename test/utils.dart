import 'dart:math';

import '../lib/tcx/activity_type.dart';

const SMALL_REPETITION = 10;
const REPETITION = 50;

const SPORTS = [
  ActivityType.Ride,
  ActivityType.VirtualRide,
  ActivityType.Run,
  ActivityType.VirtualRun,
  ActivityType.Kayaking,
  ActivityType.Canoeing,
  ActivityType.Rowing,
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
