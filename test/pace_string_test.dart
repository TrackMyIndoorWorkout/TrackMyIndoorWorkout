import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'utils.dart';

String paceString(double pace) {
  final minutes = pace.truncate();
  final seconds = ((pace - minutes) * 60.0).truncate();
  return "$minutes:" + seconds.toString().padLeft(2, "0");
}

void main() {
  group("paceString formats as expected:", () {
    const List<Tuple2<double, String>> paces = [
      Tuple2<double, String>(0.0, "0:00"),
      Tuple2<double, String>(0.5, "0:30"),
      Tuple2<double, String>(1.0, "1:00"),
      Tuple2<double, String>(1.5, "1:30"),
      Tuple2<double, String>(12.0, "12:00"),
      Tuple2<double, String>(12.5, "12:30"),
      Tuple2<double, String>(59.0, "59:00"),
      Tuple2<double, String>(59.1, "59:06"),
      Tuple2<double, String>(59.2, "59:12"),
      Tuple2<double, String>(59.5, "59:30"),
      Tuple2<double, String>(59.99, "59:59"),
      Tuple2<double, String>(60.0, "60:00"),
      Tuple2<double, String>(60.5, "60:30"),
      Tuple2<double, String>(80.0, "80:00"),
      Tuple2<double, String>(80.5, "80:30"),
    ];
    for (final pacePair in paces) {
      final expected = pacePair.item2;
      test("${pacePair.item1} -> $expected", () async {
        expect(paceString(pacePair.item1), expected);
      });
    }

    final rnd = Random();
    1.to(repetition).forEach((input) {
      final randomPace = rnd.nextDouble() * 100;
      final expected = paceString(randomPace);
      test("$randomPace -> $expected", () async {
        expect(paceString(randomPace), expected);
      });
    });
  });
}
