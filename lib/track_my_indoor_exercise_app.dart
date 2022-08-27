import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import 'providers/theme_mode.dart';
import 'ui/find_devices.dart';
import 'utils/theme_manager.dart';

class TrackMyIndoorExerciseApp extends ConsumerStatefulWidget {
  final BasePrefService prefService;

  const TrackMyIndoorExerciseApp({
    key,
    required this.prefService,
  }) : super(key: key);

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
        color: _themeManager.getHeaderColor(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: const FindDevicesScreen(),
      ),
    );
  }
}
