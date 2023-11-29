import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'ui/find_devices.dart';
import 'utils/theme_manager.dart';

class TrackMyIndoorExerciseApp extends StatefulWidget {
  final BasePrefService prefService;

  const TrackMyIndoorExerciseApp({super.key, required this.prefService});

  @override
  TrackMyIndoorExerciseAppState createState() => TrackMyIndoorExerciseAppState();
}

class TrackMyIndoorExerciseAppState extends State<TrackMyIndoorExerciseApp> {
  ThemeManager? _themeManager;

  @override
  void initState() {
    super.initState();
    _themeManager = Get.put<ThemeManager>(ThemeManager(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return PrefService(
      service: widget.prefService,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        color: _themeManager!.getHeaderColor(),
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
        themeMode: _themeManager!.getThemeMode(),
        home: const FindDevicesScreen(),
      ),
    );
  }
}
