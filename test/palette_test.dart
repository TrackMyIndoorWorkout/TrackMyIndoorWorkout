import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/palette_spec.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('lightBgPaletteDefaults test', () {
    for (var paletteEntry in PaletteSpec.lightBgPaletteDefaults.entries) {
      for (var color in paletteEntry.value) {
        test("palette ${paletteEntry.key} $color", () async {
          expect(color.toString().length, greaterThan(0));
        });
      }
    }
  });

  group('darkBgPaletteDefaults test', () {
    for (var paletteEntry in PaletteSpec.darkBgPaletteDefaults.entries) {
      for (var color in paletteEntry.value) {
        test("palette ${paletteEntry.key} $color", () async {
          expect(color.toString().length, greaterThan(0));
        });
      }
    }
  });

  group('lightFgPaletteDefaults test', () {
    for (var paletteEntry in PaletteSpec.lightFgPaletteDefaults.entries) {
      for (var color in paletteEntry.value) {
        test("palette ${paletteEntry.key} $color", () async {
          expect(color.toString().length, greaterThan(0));
        });
      }
    }
  });

  group('sevenDarkFgPalette test', () {
    for (var paletteEntry in PaletteSpec.darkFgPaletteDefaults.entries) {
      for (var color in paletteEntry.value) {
        test("palette ${paletteEntry.key} $color", () async {
          expect(color.toString().length, greaterThan(0));
        });
      }
    }
  });

  group('determineBin test', () {
    for (var intPair in [
      const Tuple2<int, int>(2, 5),
      const Tuple2<int, int>(3, 5),
      const Tuple2<int, int>(4, 5),
      const Tuple2<int, int>(5, 6),
      const Tuple2<int, int>(6, 7),
      const Tuple2<int, int>(7, 7),
      const Tuple2<int, int>(8, 7),
      const Tuple2<int, int>(9, 7),
    ]) {
      test('bound count ${intPair.item1} -> ${intPair.item2}', () async {
        expect(PaletteSpec.determinePalette(intPair.item1), intPair.item2);
      });
    }
  });
}
