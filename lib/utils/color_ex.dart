import 'dart:ui';

/// This class is to supplement deprecated_member_use for value
/// value converted RGBA into a 32 bit integer, but the SDK doesn't provide
/// a successor?
/// Renaming suggestion by https://github.com/flutter/flutter/issues/160184#issuecomment-2545709723
extension ColorEx on Color {
  static int floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  int get toARGB32 {
    return floatToInt8(a) << 24 | floatToInt8(r) << 16 | floatToInt8(g) << 8 | floatToInt8(b) << 0;
  }
}
