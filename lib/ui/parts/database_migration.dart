import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pref/pref.dart';
import '../../persistence/floor/database.dart';
import '../../persistence/floor/models/activity.dart' as fla;
import '../../persistence/floor/models/calorie_tune.dart' as flc;
import '../../persistence/floor/models/device_usage.dart' as fld;
import '../../persistence/floor/models/power_tune.dart' as flp;
import '../../persistence/floor/models/workout_summary.dart' as flw;
import '../../persistence/isar/activity.dart' as isa;
import '../../persistence/isar/calorie_tune.dart' as isc;
import '../../persistence/isar/device_usage.dart' as isd;
import '../../persistence/isar/power_tune.dart' as isp;
import '../../persistence/isar/workout_summary.dart' as isw;
import '../../persistence/isar/record.dart';
import '../../persistence/isar/db_utils.dart';
import '../../persistence/isar/floor_migration.dart';
import '../../persistence/isar/floor_record_migration.dart';
import '../../preferences/database_migration_needed.dart';
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
    setState(() {
      _progressValue = 0.0;
    });

    final dbUtils = DbUtils();
    final database = Get.find<Isar>();
    final floorDatabase = await _openFloorDatabase();
    final activities = await floorDatabase.activityDao.findAllActivities();
    final migrationProgressCount = activities.length + 4;
    var migrationItemCounter = 0;
    // #1 Activities and Records
    setMigrationPhase("Activities & Records");
    for (final fla.Activity floorActivity in activities) {
      if (floorActivity.id != null) {
        // final recordCount = floorDatabase.recordDao.getActivityRecordCount(floorActivity.id!);
        final isarId = await dbUtils.getIsarId("Activity", floorActivity.id!);
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
              entityName: "Activity",
              floorId: floorActivity.id!,
              isarId: activity.id,
            ));
          });
        }

        assert(activity.id != Isar.autoIncrement);

        final latestRecordId = await dbUtils.latestFloorRecordId(activity.id);
        final floorRecords = latestRecordId == null
            ? await floorDatabase.recordDao.findActivityRecords(activity.id)
            : await floorDatabase.recordDao.findPartialActivityRecords(activity.id, latestRecordId);
        final records = floorRecords
            .map((fr) => Record(
                  activityId: activity.id,
                  timeStamp: fr.dt,
                  distance: fr.distance,
                  elapsed: fr.elapsed,
                  calories: fr.calories,
                  power: fr.power,
                  speed: fr.speed,
                  cadence: fr.cadence,
                  heartRate: fr.heartRate,
                ))
            .toList(growable: false);

        database.writeTxnSync(() {
          database.records.putAllSync(records);
          final recordMigrations = IterableZip([
            floorRecords.map((fr) => fr.id),
            records.map((ir) => ir.id),
          ])
              .map((pair) => FloorRecordMigration(
                  activityId: activity.id, floorId: pair[0]!, isarId: pair[1]!))
              .toList(growable: false);
          database.floorRecordMigrations.putAllSync(recordMigrations);
        });

        migrationItemCounter++;
        setState(() {
          _progressValue = migrationItemCounter / migrationProgressCount;
        });
      }
    }

    setMigrationPhase("Device Usages");
    final migratedDeviceUsageIds = database.floorMigrations
        .where()
        .filter()
        .entityNameEqualTo("DeviceUsage")
        .floorIdProperty()
        .findAllSync();
    final List<fld.DeviceUsage> floorDeviceUsages =
        (await floorDatabase.deviceUsageDao.findAllDeviceUsages())
            .whereNot((du) => migratedDeviceUsageIds.contains(du.id))
            .toList(growable: false);
    final List<isd.DeviceUsage> deviceUsages = floorDeviceUsages
        .map((du) => isd.DeviceUsage(
              sport: du.sport,
              mac: du.mac,
              name: du.name,
              manufacturer: du.manufacturer,
              manufacturerName: du.manufacturerName,
              time: du.timeStamp,
            ))
        .toList(growable: false);

    database.writeTxnSync(() {
      database.deviceUsages.putAllSync(deviceUsages);
      final deviceUsageMigrations = IterableZip([
        floorDeviceUsages.map((fdu) => fdu.id),
        deviceUsages.map((idu) => idu.id),
      ])
          .map((pair) =>
              FloorMigration(entityName: "DeviceUsage", floorId: pair[0]!, isarId: pair[1]!))
          .toList(growable: false);
      database.floorMigrations.putAllSync(deviceUsageMigrations);
    });

    migrationItemCounter++;
    setState(() {
      _progressValue = migrationItemCounter / migrationProgressCount;
    });

    setMigrationPhase("Calorie Tunes");
    final migratedCalorieTunesIds = database.floorMigrations
        .where()
        .filter()
        .entityNameEqualTo("CalorieTune")
        .floorIdProperty()
        .findAllSync();
    final List<flc.CalorieTune> floorCalorieTunes =
        (await floorDatabase.calorieTuneDao.findAllCalorieTunes())
            .whereNot((ct) => migratedCalorieTunesIds.contains(ct.id))
            .toList(growable: false);
    final List<isc.CalorieTune> calorieTunes = floorCalorieTunes
        .map((ct) => isc.CalorieTune(
              mac: ct.mac,
              calorieFactor: ct.calorieFactor,
              hrBased: ct.hrBased,
              time: ct.timeStamp,
            ))
        .toList(growable: false);

    database.writeTxnSync(() {
      database.calorieTunes.putAllSync(calorieTunes);
      final calorieTuneMigrations = IterableZip([
        floorCalorieTunes.map((fct) => fct.id),
        calorieTunes.map((ict) => ict.id),
      ])
          .map((pair) =>
              FloorMigration(entityName: "CalorieTune", floorId: pair[0]!, isarId: pair[1]!))
          .toList(growable: false);
      database.floorMigrations.putAllSync(calorieTuneMigrations);
    });

    migrationItemCounter++;
    setState(() {
      _progressValue = migrationItemCounter / migrationProgressCount;
    });

    setMigrationPhase("Power Tunes");
    final migratedPowerTunesIds = database.floorMigrations
        .where()
        .filter()
        .entityNameEqualTo("PowerTune")
        .floorIdProperty()
        .findAllSync();
    final List<flp.PowerTune> floorPowerTunes =
        (await floorDatabase.powerTuneDao.findAllPowerTunes())
            .whereNot((ct) => migratedPowerTunesIds.contains(ct.id))
            .toList(growable: false);
    final List<isp.PowerTune> powerTunes = floorPowerTunes
        .map((pt) => isp.PowerTune(
              mac: pt.mac,
              powerFactor: pt.powerFactor,
              time: pt.timeStamp,
            ))
        .toList(growable: false);

    database.writeTxnSync(() {
      database.powerTunes.putAllSync(powerTunes);
      final powerTuneMigrations = IterableZip([
        floorPowerTunes.map((fct) => fct.id),
        powerTunes.map((ict) => ict.id),
      ])
          .map((pair) =>
              FloorMigration(entityName: "PowerTune", floorId: pair[0]!, isarId: pair[1]!))
          .toList(growable: false);
      database.floorMigrations.putAllSync(powerTuneMigrations);
    });

    migrationItemCounter++;
    setState(() {
      _progressValue = migrationItemCounter / migrationProgressCount;
    });

    setMigrationPhase("Workout Summary");
    final migratedWorkoutSummaryIds = database.floorMigrations
        .where()
        .filter()
        .entityNameEqualTo("WorkoutSummary")
        .floorIdProperty()
        .findAllSync();
    final List<flw.WorkoutSummary> floorWorkoutSummaries =
        (await floorDatabase.workoutSummaryDao.findAllWorkoutSummaries())
            .whereNot((ct) => migratedWorkoutSummaryIds.contains(ct.id))
            .toList(growable: false);
    final List<isw.WorkoutSummary> workoutSummaries = floorWorkoutSummaries
        .map((ws) => isw.WorkoutSummary(
              deviceName: ws.deviceName,
              deviceId: ws.deviceId,
              manufacturer: ws.manufacturer,
              start: ws.startDateTime,
              distance: ws.distance,
              elapsed: ws.elapsed,
              movingTime: ws.movingTime,
              sport: ws.sport,
              powerFactor: ws.powerFactor,
              calorieFactor: ws.calorieFactor,
            ))
        .toList(growable: false);

    database.writeTxnSync(() {
      database.workoutSummarys.putAllSync(workoutSummaries);
      final workoutSummaryMigrations = IterableZip([
        floorWorkoutSummaries.map((fws) => fws.id),
        workoutSummaries.map((iws) => iws.id),
      ])
          .map((pair) =>
              FloorMigration(entityName: "WorkoutSummary", floorId: pair[0]!, isarId: pair[1]!))
          .toList(growable: false);
      database.floorMigrations.putAllSync(workoutSummaryMigrations);
    });

    migrationItemCounter++;
    setState(() {
      _progressValue = migrationItemCounter / migrationProgressCount;
    });

    setState(() {
      _isMigrating = false;
    });

    final prefService = Get.find<BasePrefService>();
    prefService.set<bool>(databaseMigrationNeededTag, false);
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
