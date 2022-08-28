import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences.dart';

final StateProvider<ThemeMode> themeModeProvider =
    StateProvider<ThemeMode>((StateProviderRef<ThemeMode> ref) {
  return initialPreferredThemeMode();
});
