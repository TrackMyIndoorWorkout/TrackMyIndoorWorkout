import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  test('Schwinn AC Performance Plus constructor tests', () async {
    final bike = deviceMap[schwinnACPerfPlusFourCC]!;

    expect(bike.canMeasureHeartRate, true);
    expect(bike.defaultSport, ActivityType.ride);
    expect(bike.fourCC, schwinnACPerfPlusFourCC);
  });

  group('Schwinn AC Performance Plus can only import data, not process', () {
    final rnd = Random();
    for (var len in getRandomInts(smallRepetition, 30, rnd)) {
      final data = getRandomInts(len, maxUint8, rnd);
      final sum = data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final bike = deviceMap[schwinnACPerfPlusFourCC]!;
        bike.initFlag();

        expect(bike.canDataProcessed(data), false);
      });
    }
  });
}
