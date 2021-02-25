import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

String paceString(double pace) {
  final minutes = pace.truncate();
  final seconds = ((pace - minutes) * 60.0).truncate();
  return "$minutes:" + seconds.toString().padLeft(2, "0");
}

void main() {
  group("paceString formats as expected:", () {
    final paces = [
      [0.0, "0:00"],
      [0.5, "0:30"],
      [1.0, "1:00"],
      [1.5, "1:30"],
      [12.0, "12:00"],
      [12.5, "12:30"],
      [59.0, "59:00"],
      [59.1, "59:06"],
      [59.2, "59:12"],
      [59.5, "59:30"],
      [59.99, "59:59"],
      [60.0, "60:00"],
      [60.5, "60:30"],
      [80.0, "80:00"],
      [80.5, "80:30"],
    ];
    paces.forEach((pacePair) {
      final expected = pacePair[1];
      test("${pacePair[0]} -> $expected", () {
        expect(paceString(pacePair[0]), expected);
      });
    });

    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final randomPace = rnd.nextDouble() * 100;
      final expected = paceString(randomPace);
      test("$randomPace -> $expected", () {
        expect(paceString(randomPace), expected);
      });
    });
  });
}
