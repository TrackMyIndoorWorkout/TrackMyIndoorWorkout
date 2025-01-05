import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import 'preferences/show_performance_overlay.dart';
import 'providers/theme_mode.dart';
import 'ui/find_devices.dart';
import 'utils/theme_manager.dart';

class TrackMyIndoorExerciseApp extends ConsumerStatefulWidget {
  final BasePrefService prefService;

  const TrackMyIndoorExerciseApp({super.key, required this.prefService});

  @override
  TrackMyIndoorExerciseAppState createState() => TrackMyIndoorExerciseAppState();
}

class TrackMyIndoorExerciseAppState extends ConsumerState<TrackMyIndoorExerciseApp> {
  late final ThemeManager _themeManager;

  TrackMyIndoorExerciseAppState() {
    _themeManager = Get.put<ThemeManager>(ThemeManager(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return PrefService(
      service: widget.prefService,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: widget.prefService.get<bool>(showPerformanceOverlayTag) ??
            showPerformanceOverlayDefault,
        color: _themeManager.getHeaderColor(themeMode),
        theme: FlexThemeData.light(
          scheme: FlexScheme.indigoM3,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.indigoM3,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        ),
        themeMode: themeMode,
        home: const FindDevicesScreen(),
      ),
    );
  }
}
