import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/palettes.dart';

void main() {
  group('sevenLightBgPalette test', () {
    sevenLightBgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('sevenDarkBgPalette test', () {
    sevenDarkBgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('sevenLightFgPalette test', () {
    sevenLightFgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('sevenDarkFgPalette test', () {
    sevenDarkFgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('fiveLightBgPalette test', () {
    fiveLightBgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('fiveDarkBgPalette test', () {
    fiveDarkBgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('fiveLightFgPalette test', () {
    fiveLightFgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });

  group('fiveDarkFgPalette test', () {
    fiveDarkFgPalette.forEach((color) {
      test("$color", () async {
        expect(color.toString().length, greaterThan(0));
      });
    });
  });
}
