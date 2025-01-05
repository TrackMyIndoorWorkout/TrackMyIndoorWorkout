import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../utils/color_ex.dart';
import 'metric_spec.dart';

extension ColorEx on Color {
  String toRawString() {
    return toARGB32.toRadixString(16).padLeft(8, '0');
  }
}

class PaletteSpec {
  static final Map<int, List<Color>> lightBgPaletteDefaults = {
    7: [
      Colors.lightBlueAccent.shade100,
      Colors.cyanAccent.shade100,
      Colors.tealAccent.shade400,
      Colors.limeAccent.shade400,
      Colors.yellowAccent.shade200,
      Colors.redAccent.shade100,
      Colors.pinkAccent.shade100,
    ],
    6: [
      Colors.lightBlueAccent.shade100,
      Colors.cyanAccent.shade100,
      Colors.limeAccent.shade400,
      Colors.yellowAccent.shade200,
      Colors.redAccent.shade100,
      Colors.pinkAccent.shade100,
    ],
    5: [
      Colors.lightBlueAccent.shade100,
      Colors.cyanAccent.shade100,
      Colors.lightGreenAccent.shade100,
      Colors.yellowAccent.shade100,
      Colors.redAccent.shade100,
    ],
  };

  static final Map<int, List<Color>> darkBgPaletteDefaults = {
    7: [
      Colors.indigo.shade900,
      Colors.cyan.shade800,
      Colors.teal.shade900,
      Colors.green.shade800,
      Colors.yellow.shade900,
      Colors.red.shade900,
      Colors.purple.shade900,
    ],
    6: [
      Colors.indigo.shade900,
      Colors.cyan.shade800,
      Colors.green.shade800,
      Colors.yellow.shade900,
      Colors.red.shade900,
      Colors.purple.shade900,
    ],
    5: [
      Colors.indigo.shade900,
      Colors.cyan.shade800,
      Colors.green.shade900,
      Colors.yellow.shade900,
      Colors.red.shade900,
    ],
  };

  static final Map<int, List<Color>> lightFgPaletteDefaults = {
    7: [
      Colors.indigo,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ],
    6: [
      Colors.indigo,
      Colors.cyan,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ],
    5: [
      Colors.indigo,
      Colors.cyan,
      Colors.green,
      Colors.orange,
      Colors.red,
    ],
  };

  static final Map<int, List<Color>> darkFgPaletteDefaults = {
    7: [
      Colors.blueAccent,
      Colors.cyanAccent,
      Colors.tealAccent,
      Colors.lightGreenAccent,
      Colors.yellowAccent,
      Colors.redAccent,
      Colors.pinkAccent,
    ],
    6: [
      Colors.blueAccent,
      Colors.cyanAccent,
      Colors.lightGreenAccent,
      Colors.yellowAccent,
      Colors.redAccent,
      Colors.pinkAccent,
    ],
    5: [
      Colors.blueAccent,
      Colors.cyanAccent,
      Colors.lightGreenAccent,
      Colors.yellowAccent,
      Colors.redAccent,
    ],
  };

  final Map<int, List<Color>> lightBgPalette = {7: [], 6: [], 5: []};
  final Map<int, List<Color>> darkBgPalette = {7: [], 6: [], 5: []};
  final Map<int, List<Color>> lightFgPalette = {7: [], 6: [], 5: []};
  final Map<int, List<Color>> darkFgPalette = {7: [], 6: [], 5: []};

  static Map<int, List<Color>> getDefaultPaletteSet(bool lightOrDark, bool fgOrBg) {
    if (lightOrDark) {
      if (fgOrBg) {
        return lightFgPaletteDefaults;
      } else {
        return lightBgPaletteDefaults;
      }
    } else {
      if (fgOrBg) {
        return darkFgPaletteDefaults;
      } else {
        return darkBgPaletteDefaults;
      }
    }
  }

  static List<Color> getDefaultPalette(bool lightOrDark, bool fgOrBg, int paletteSize) {
    return getDefaultPaletteSet(lightOrDark, fgOrBg)[paletteSize]!;
  }

  static String getDefaultPaletteString(bool lightOrDark, bool fgOrBg, int paletteSize) {
    final colorArray = getDefaultPalette(lightOrDark, fgOrBg, paletteSize);
    return colorArray.map((z) => z.toRawString()).join(",");
  }

  static String getPaletteTag(bool lightOrDark, bool fgOrBg, int paletteSize) {
    return "palette_${lightOrDark ? 'light' : 'dark'}_${fgOrBg ? 'fg' : 'bg'}_$paletteSize";
  }

  static Color bgColorByBinDefault(int bin, bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight
        ? PaletteSpec.lightBgPaletteDefaults[paletteSize]![bin]
        : PaletteSpec.darkBgPaletteDefaults[paletteSize]![bin];
  }

  static Color fgColorByBinDefault(int bin, bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight
        ? PaletteSpec.lightFgPaletteDefaults[paletteSize]![bin]
        : PaletteSpec.darkFgPaletteDefaults[paletteSize]![bin];
  }

  static List<Color> getPiePaletteDefault(bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    return isLight
        ? PaletteSpec.darkFgPaletteDefaults[paletteSize]!
        : PaletteSpec.lightFgPaletteDefaults[paletteSize]!;
  }

  Map<int, List<Color>> getPaletteSet(bool lightOrDark, bool fgOrBg) {
    if (lightOrDark) {
      if (fgOrBg) {
        return lightFgPalette;
      } else {
        return lightBgPalette;
      }
    } else {
      if (fgOrBg) {
        return darkFgPalette;
      } else {
        return darkBgPalette;
      }
    }
  }

  List<Color> getPalette(bool lightOrDark, bool fgOrBg, int paletteSize) {
    return getPaletteSet(lightOrDark, fgOrBg)[paletteSize]!;
  }

  void loadFromPreferences(BasePrefService prefService) {
    for (final lightOrDark in [false, true]) {
      for (final fgOrBg in [false, true]) {
        for (final paletteSize in [5, 6, 7]) {
          final tag = PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize);
          final paletteStr = prefService.get<String>(tag) ?? "";
          final palette = getPalette(lightOrDark, fgOrBg, paletteSize);
          palette.clear();
          paletteStr.split(",").forEach((colorStr) {
            final colorInt = int.parse(colorStr, radix: 16);
            palette.add(Color(colorInt));
          });
        }
      }
    }
  }

  Future<void> saveToPreferences(
    BasePrefService prefService,
    bool lightOrDark,
    bool fgOrBg,
    int paletteSize,
    Color color,
    int colorIndex,
  ) async {
    final palette = getPalette(lightOrDark, fgOrBg, paletteSize);
    assert(colorIndex >= 0 && colorIndex < palette.length);
    palette[colorIndex] = color;
    final tag = PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize);
    final paletteStr = palette.map((z) => z.toRawString()).join(",");
    prefService.set<String>(tag, paletteStr);
  }

  static PaletteSpec getInstance(BasePrefService prefService) {
    if (Get.isRegistered<PaletteSpec>()) {
      return Get.find<PaletteSpec>();
    }

    final instance = PaletteSpec();
    instance.loadFromPreferences(prefService);
    Get.put<PaletteSpec>(instance, permanent: true);
    return instance;
  }

  static int determinePalette(int boundCount) {
    return max(5, min(7, boundCount + 1));
  }

  Color bgColorByBin(int bin, bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight ? lightBgPalette[paletteSize]![bin] : darkBgPalette[paletteSize]![bin];
  }

  Color fgColorByBin(int bin, bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight ? lightFgPalette[paletteSize]![bin] : darkFgPalette[paletteSize]![bin];
  }

  List<Color> getPiePalette(bool isLight, MetricSpec metricSpec) {
    final paletteSize = determinePalette(metricSpec.zonePercents.length);
    return isLight ? darkFgPalette[paletteSize]! : lightFgPalette[paletteSize]!;
  }
}
