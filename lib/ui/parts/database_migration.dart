import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:loading_overlay/loading_overlay.dart';
// import 'package:pref/pref.dart';
import '../../persistence/floor/database.dart';
import '../../persistence/floor/models/activity.dart' as fla;
import '../../persistence/isar/activity.dart' as isa;
import '../../persistence/isar/db_utils.dart';
import '../../persistence/isar/floor_migration.dart';
import '../../utils/theme_manager.dart';

class DatabaseMigrationBottomSheet extends StatefulWidget {
  const DatabaseMigrationBottomSheet({Key? key}) : super(key: key);

  @override
  DatabaseMigrationBottomSheetState createState() => DatabaseMigrationBottomSheetState();
}

class DatabaseMigrationBottomSheetState extends State<DatabaseMigrationBottomSheet> {
  bool _isMigrating = true;
  double _progressValue = 0.0;
  double _sizeDefault = 10.0;
  String _migrationPhase = "";

  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();

  void setProgress(double progress) {
    setState(() {
      _progressValue = progress;
    });
  }

  void setMigrationPhase(String migrationPhase) {
    setState(() {
      _migrationPhase = migrationPhase;
    });
  }

  Future<AppDatabase> _openFloorDatabase() async {
    final floorDatabase = await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
      migration1to2,
      migration2to3,
      migration3to4,
      migration4to5,
      migration5to6,
      migration6to7,
      migration7to8,
      migration8to9,
      migration9to10,
      migration10to11,
      migration11to12,
      migration12to13,
      migration13to14,
      migration14to15,
      migration15to16,
      migration16to17,
      migration17to18,
    ]).build();
    if (AppDatabase.additional15to16Migration) {
      await floorDatabase.correctCalorieFactors();
    }

    if (AppDatabase.additional16to17Migration) {
      await floorDatabase.initializeExistingActivityMovingTimes();
    }

    return floorDatabase;
  }

  Future<void> _performMigration() async {
    final database = Get.find<Isar>();
    final floorDatabase = await _openFloorDatabase();
    final dbUtils = DbUtils();
    // #1 Activities and Records
    setMigrationPhase("Activities & Records");
    for (final fla.Activity floorActivity in await floorDatabase.activityDao.findAllActivities()) {
      if (floorActivity.id == null) {
        continue;
      }

      // final recordCount = floorDatabase.recordDao.getActivityRecordCount(floorActivity.id!);
      final isarId = dbUtils.getIsarId("Activity", floorActivity.id!);
      final activity = isarId != null
          ? database.activitys.filter().idEqualTo(isarId).findFirstSync()
          : isa.Activity(
              deviceName: floorActivity.deviceName,
              deviceId: floorActivity.deviceId,
              hrmId: floorActivity.hrmId,
              start: DateTime.fromMillisecondsSinceEpoch(floorActivity.start),
              end: DateTime.fromMillisecondsSinceEpoch(floorActivity.end),
              distance: floorActivity.distance,
              elapsed: floorActivity.elapsed,
              movingTime: floorActivity.movingTime,
              calories: floorActivity.calories,
              uploaded: floorActivity.uploaded,
              suuntoUploaded: floorActivity.suuntoUploaded,
              suuntoBlobUrl: floorActivity.suuntoBlobUrl,
              underArmourUploaded: floorActivity.underArmourUploaded,
              trainingPeaksUploaded: floorActivity.trainingPeaksUploaded,
              stravaId: floorActivity.stravaId,
              uaWorkoutId: floorActivity.uaWorkoutId,
              suuntoUploadIdentifier: floorActivity.suuntoUploadIdentifier,
              suuntoWorkoutUrl: floorActivity.suuntoWorkoutUrl,
              trainingPeaksWorkoutId: floorActivity.trainingPeaksWorkoutId,
              trainingPeaksFileTrackingUuid: floorActivity.trainingPeaksFileTrackingUuid,
              fourCC: floorActivity.fourCC,
              sport: floorActivity.sport,
              powerFactor: floorActivity.powerFactor,
              calorieFactor: floorActivity.calorieFactor,
              hrCalorieFactor: floorActivity.hrCalorieFactor,
              hrmCalorieFactor: floorActivity.hrmCalorieFactor,
              hrBasedCalories: floorActivity.hrBasedCalories,
              timeZone: floorActivity.timeZone,
            );
      if (activity == null) {
        continue;
      }

      if (activity.id == Isar.autoIncrement) {
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
          assert(activity.id != Isar.autoIncrement);
          database.floorMigrations.putSync(FloorMigration(
              entityName: "Activity", floorId: floorActivity.id!, isarId: activity.id));
        });
      }

      assert(activity.id != Isar.autoIncrement);
    }

    setState(() {
      _isMigrating = false;
    });

    // final List<String> _phaseName = [
    //   "Activities",
    //   "Records",
    //   "Device Usages",
    //   "Calorie Tunes",
    //   "Power Tunes",
    //   "Workout Summary"
    // ];

    // TOOD: mark the migration finished in the preferences variable
  }

  @override
  void initState() {
    super.initState();
    _sizeDefault = Get.textTheme.displayMedium!.fontSize!;
    _largerTextStyle = Get.textTheme.headlineMedium!;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _performMigration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isMigrating,
        progressIndicator: SizedBox(
          height: _sizeDefault * 2,
          width: _sizeDefault * 2,
          child: CircularProgressIndicator(
            strokeWidth: _sizeDefault,
            value: _progressValue,
          ),
        ),
        child: Text(_migrationPhase, style: _largerTextStyle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _isMigrating
          ? _themeManager.getBlueFab(Icons.clear,
              () => Get.snackbar("Database Migration in Progress", "Please be patient"))
          : _themeManager.getGreenFab(
              Icons.check,
              () => Get.back(result: !_isMigrating),
            ),
    );
  }
}
