import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/palettes.dart';

void main() {
  group('sevenLightBgPalette test', () {
    for (var color in sevenLightBgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('sevenDarkBgPalette test', () {
    for (var color in sevenDarkBgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('sevenLightFgPalette test', () {
    for (var color in sevenLightFgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('sevenDarkFgPalette test', () {
    for (var color in sevenDarkFgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('fiveLightBgPalette test', () {
    for (var color in fiveLightBgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('fiveDarkBgPalette test', () {
    for (var color in fiveDarkBgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('fiveLightFgPalette test', () {
    for (var color in fiveLightFgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });

  group('fiveDarkFgPalette test', () {
    for (var color in fiveDarkFgPalette) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    }
  });
}
