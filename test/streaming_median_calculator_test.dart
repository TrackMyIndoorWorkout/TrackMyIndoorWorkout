import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/streaming_median_calculator.dart';

import 'utils.dart';

void main() {
  test('StreamingMedianCalculator median is null after init', () async {
    final calc = StreamingMedianCalculator<int>();
    expect(calc.median, null);
  });

  test('StreamingMedianCalculator median is the same with one element', () async {
    int median = 42;
    final calc = StreamingMedianCalculator<int>();
    calc.processElement(median);
    expect(calc.median, median);
  });

  group('StreamingMedianCalculator computes median as expected', () {
    final rnd = Random();
    for (var i in List<int>.generate(smallRepetition, (index) => index)) {
      final numElements = rnd.nextInt(900) + 100;
      final elements = getRandomInts(numElements, 1000, rnd);
      final calc = StreamingMedianCalculator<int>();
      for (int element in elements) {
        calc.processElement(element);
      }
      elements.sort();
      final expected = elements[numElements ~/ 2];

      test("$i -> $numElements", () async {
        expect(calc.median, expected);
      });
    }
  });
}
