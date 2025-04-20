import 'dart:async';
import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pref/pref.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'i18n/strings.g.dart';
import 'import/csv_importer.dart';
import 'persistence/workout_summary.dart';
import 'preferences/leaderboard_and_rank.dart';
import 'preferences/show_performance_overlay.dart';
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
  bool _leaderboardFeature = leaderboardFeatureDefault;
  late StreamSubscription _intentSub;

  Future<int> _importActivities(List<SharedMediaFile> sharedFiles) async {
    var importedFileCount = 0;
    for (final sharedFile in sharedFiles) {
      if (!sharedFile.path.toLowerCase().endsWith(".csv")) {
        continue;
      }

      File file = File(sharedFile.path);
      String contents = await file.readAsString();
      final importer = CSVImporter(null);
      final activity = await importer.import(contents, (progress) {});
      if (activity != null) {
        importedFileCount++;
        Get.snackbar("Success", "Workout imported!");
        if (_leaderboardFeature) {
          final deviceDescriptor = activity.deviceDescriptor();
          final workoutSummary = activity.getWorkoutSummary(deviceDescriptor.manufacturerNamePart);
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.workoutSummarys.putSync(workoutSummary);
          });
        }
      } else {
        Get.snackbar("Failure", "Problem while importing: ${importer.message}");
      }
    }
    return importedFileCount;
  }

  @override
  void initState() {
    super.initState();
    _themeManager = Get.put<ThemeManager>(ThemeManager(), permanent: true);
    _leaderboardFeature =
        widget.prefService.get<bool>(leaderboardFeatureTag) ?? leaderboardFeatureDefault;

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _importActivities(value);
        });
      },
      onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      },
    );

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _importActivities(value);
        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrefService(
      service: widget.prefService,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay:
            widget.prefService.get<bool>(showPerformanceOverlayTag) ??
            showPerformanceOverlayDefault,
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
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const FindDevicesScreen(),
      ),
    );
  }
}
