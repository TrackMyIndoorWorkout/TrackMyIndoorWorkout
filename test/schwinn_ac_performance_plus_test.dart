import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/schwinn_ac_performance_plus.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  test('Schwinn AC Performance Plus constructor tests', () async {
    final bike = SchwinnACPerformancePlus();

    expect(bike.defaultSport, ActivityType.ride);
    expect(bike.fourCC, schwinnACPerfPlusFourCC);
  });

  group('Schwinn AC Performance Plus can only import data, not process', () {
    final rnd = Random();
    for (var len in getRandomInts(smallRepetition, 30, rnd)) {
      final data = getRandomInts(len, maxUint8, rnd);
      final sum = data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final bike = SchwinnACPerformancePlus();
        bike.initFlag();

        expect(bike.isDataProcessable(data), false);
      });
    }
  });
}
