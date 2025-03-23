import 'dart:ui';

/// This class is to supplement deprecated_member_use for value
/// value converted RGBA into a 32 bit integer, but the SDK doesn't provide
/// a successor?
/// Renaming suggestion by https://github.com/flutter/flutter/issues/160184#issuecomment-2545709723
extension ColorEx on Color {
  String toRawString() {
    return toARGB32().toRadixString(16).padLeft(8, '0');
  }
}
