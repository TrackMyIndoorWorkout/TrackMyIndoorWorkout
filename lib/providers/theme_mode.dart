import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<ThemeMode> themeModeProvider =
    StateProvider<ThemeMode>((StateProviderRef<ThemeMode> ref) {
  return ThemeMode.system;
});
