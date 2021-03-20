import 'package:flutter/material.dart';

const FONT_SIZE_FACTOR = 1.5;

standOutStyle(TextStyle style, double fontSizeFactor) {
  return style.apply(
    fontSizeFactor: fontSizeFactor,
    color: Colors.black,
    fontWeightDelta: 3,
  );
}
