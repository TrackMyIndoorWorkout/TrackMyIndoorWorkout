import 'package:flutter/material.dart';

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
}
