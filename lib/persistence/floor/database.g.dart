// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) => _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() => _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null ? await sqfliteDatabaseFactory.getDatabasePath(name!) : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ActivityDao? _activityDaoInstance;

  RecordDao? _recordDaoInstance;

  DeviceUsageDao? _deviceUsageDaoInstance;

  CalorieTuneDao? _calorieTuneDaoInstance;

  PowerTuneDao? _powerTuneDaoInstance;

  WorkoutSummaryDao? _workoutSummaryDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 17,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `activities` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT NOT NULL, `device_id` TEXT NOT NULL, `hrm_id` TEXT NOT NULL, `start` INTEGER NOT NULL, `end` INTEGER NOT NULL, `distance` REAL NOT NULL, `elapsed` INTEGER NOT NULL, `moving_time` INTEGER NOT NULL, `calories` INTEGER NOT NULL, `uploaded` INTEGER NOT NULL, `strava_id` INTEGER NOT NULL, `four_cc` TEXT NOT NULL, `sport` TEXT NOT NULL, `power_factor` REAL NOT NULL, `calorie_factor` REAL NOT NULL, `hr_calorie_factor` REAL NOT NULL, `hrm_calorie_factor` REAL NOT NULL, `hr_based_calories` INTEGER NOT NULL, `time_zone` TEXT NOT NULL, `suunto_uploaded` INTEGER NOT NULL, `suunto_blob_url` TEXT NOT NULL, `under_armour_uploaded` INTEGER NOT NULL, `training_peaks_uploaded` INTEGER NOT NULL, `ua_workout_id` INTEGER NOT NULL, `suunto_upload_id` INTEGER NOT NULL, `suunto_upload_identifier` TEXT NOT NULL, `suunto_workout_url` TEXT NOT NULL, `training_peaks_workout_id` INTEGER NOT NULL, `training_peaks_athlete_id` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `activity_id` INTEGER, `time_stamp` INTEGER, `distance` REAL, `elapsed` INTEGER, `calories` INTEGER, `power` INTEGER, `speed` REAL, `cadence` INTEGER, `heart_rate` INTEGER, FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `device_usage` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `sport` TEXT NOT NULL, `mac` TEXT NOT NULL, `name` TEXT NOT NULL, `manufacturer` TEXT NOT NULL, `manufacturer_name` TEXT, `time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `calorie_tune` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT NOT NULL, `calorie_factor` REAL NOT NULL, `hr_based` INTEGER NOT NULL, `time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `power_tune` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT NOT NULL, `power_factor` REAL NOT NULL, `time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `workout_summary` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT NOT NULL, `device_id` TEXT NOT NULL, `manufacturer` TEXT NOT NULL, `start` INTEGER NOT NULL, `distance` REAL NOT NULL, `elapsed` INTEGER NOT NULL, `moving_time` INTEGER NOT NULL, `speed` REAL NOT NULL, `sport` TEXT NOT NULL, `power_factor` REAL NOT NULL, `calorie_factor` REAL NOT NULL)');
        await database.execute('CREATE INDEX `index_activities_start` ON `activities` (`start`)');
        await database
            .execute('CREATE INDEX `index_records_time_stamp` ON `records` (`time_stamp`)');
        await database.execute('CREATE INDEX `index_device_usage_time` ON `device_usage` (`time`)');
        await database.execute('CREATE INDEX `index_device_usage_mac` ON `device_usage` (`mac`)');
        await database.execute('CREATE INDEX `index_calorie_tune_mac` ON `calorie_tune` (`mac`)');
        await database.execute('CREATE INDEX `index_power_tune_mac` ON `power_tune` (`mac`)');
        await database
            .execute('CREATE INDEX `index_workout_summary_sport` ON `workout_summary` (`sport`)');
        await database.execute(
            'CREATE INDEX `index_workout_summary_device_id` ON `workout_summary` (`device_id`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ActivityDao get activityDao {
    return _activityDaoInstance ??= _$ActivityDao(database, changeListener);
  }

  @override
  RecordDao get recordDao {
    return _recordDaoInstance ??= _$RecordDao(database, changeListener);
  }

  @override
  DeviceUsageDao get deviceUsageDao {
    return _deviceUsageDaoInstance ??= _$DeviceUsageDao(database, changeListener);
  }

  @override
  CalorieTuneDao get calorieTuneDao {
    return _calorieTuneDaoInstance ??= _$CalorieTuneDao(database, changeListener);
  }

  @override
  PowerTuneDao get powerTuneDao {
    return _powerTuneDaoInstance ??= _$PowerTuneDao(database, changeListener);
  }

  @override
  WorkoutSummaryDao get workoutSummaryDao {
    return _workoutSummaryDaoInstance ??= _$WorkoutSummaryDao(database, changeListener);
  }
}

class _$ActivityDao extends ActivityDao {
  _$ActivityDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _activityUpdateAdapter = UpdateAdapter(
            database,
            'activities',
            ['id'],
            (Activity item) => <String, Object?>{
                  'id': item.id,
                  'device_name': item.deviceName,
                  'device_id': item.deviceId,
                  'hrm_id': item.hrmId,
                  'start': item.start,
                  'end': item.end,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'moving_time': item.movingTime,
                  'calories': item.calories,
                  'uploaded': item.uploaded ? 1 : 0,
                  'strava_id': item.stravaId,
                  'four_cc': item.fourCC,
                  'sport': item.sport,
                  'power_factor': item.powerFactor,
                  'calorie_factor': item.calorieFactor,
                  'hr_calorie_factor': item.hrCalorieFactor,
                  'hrm_calorie_factor': item.hrmCalorieFactor,
                  'hr_based_calories': item.hrBasedCalories ? 1 : 0,
                  'time_zone': item.timeZone,
                  'suunto_uploaded': item.suuntoUploaded ? 1 : 0,
                  'suunto_blob_url': item.suuntoBlobUrl,
                  'under_armour_uploaded': item.underArmourUploaded ? 1 : 0,
                  'training_peaks_uploaded': item.trainingPeaksUploaded ? 1 : 0,
                  'ua_workout_id': item.uaWorkoutId,
                  'suunto_upload_id': item.suuntoUploadId,
                  'suunto_upload_identifier': item.suuntoUploadIdentifier,
                  'suunto_workout_url': item.suuntoWorkoutUrl,
                  'training_peaks_workout_id': item.trainingPeaksWorkoutId,
                  'training_peaks_athlete_id': item.trainingPeaksAthleteId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final UpdateAdapter<Activity> _activityUpdateAdapter;

  @override
  Future<List<Activity>> findAllActivities() async {
    return _queryAdapter.queryList('SELECT * FROM `activities` ORDER BY `start` DESC',
        mapper: (Map<String, Object?> row) => Activity(
            id: row['id'] as int?,
            deviceName: row['device_name'] as String,
            deviceId: row['device_id'] as String,
            hrmId: row['hrm_id'] as String,
            start: row['start'] as int,
            end: row['end'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            movingTime: row['moving_time'] as int,
            calories: row['calories'] as int,
            uploaded: (row['uploaded'] as int) != 0,
            suuntoUploaded: (row['suunto_uploaded'] as int) != 0,
            suuntoBlobUrl: row['suunto_blob_url'] as String,
            underArmourUploaded: (row['under_armour_uploaded'] as int) != 0,
            trainingPeaksUploaded: (row['training_peaks_uploaded'] as int) != 0,
            stravaId: row['strava_id'] as int,
            uaWorkoutId: row['ua_workout_id'] as int,
            suuntoUploadId: row['suunto_upload_id'] as int,
            suuntoUploadIdentifier: row['suunto_upload_identifier'] as String,
            suuntoWorkoutUrl: row['suunto_workout_url'] as String,
            trainingPeaksAthleteId: row['training_peaks_athlete_id'] as int,
            trainingPeaksWorkoutId: row['training_peaks_workout_id'] as int,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String,
            powerFactor: row['power_factor'] as double,
            calorieFactor: row['calorie_factor'] as double,
            hrCalorieFactor: row['hr_calorie_factor'] as double,
            hrmCalorieFactor: row['hrm_calorie_factor'] as double,
            hrBasedCalories: (row['hr_based_calories'] as int) != 0,
            timeZone: row['time_zone'] as String));
  }

  @override
  Future<int> updateActivity(Activity activity) {
    return _activityUpdateAdapter.updateAndReturnChangedRows(activity, OnConflictStrategy.abort);
  }
}

class _$RecordDao extends RecordDao {
  _$RecordDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<Record>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM `records` ORDER BY `time_stamp`',
        mapper: (Map<String, Object?> row) => Record(
            id: row['id'] as int?,
            activityId: row['activity_id'] as int?,
            timeStamp: row['time_stamp'] as int?,
            distance: row['distance'] as double?,
            elapsed: row['elapsed'] as int?,
            calories: row['calories'] as int?,
            power: row['power'] as int?,
            speed: row['speed'] as double?,
            cadence: row['cadence'] as int?,
            heartRate: row['heart_rate'] as int?));
  }
}

class _$DeviceUsageDao extends DeviceUsageDao {
  _$DeviceUsageDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<DeviceUsage>> findAllDeviceUsages() async {
    return _queryAdapter.queryList('SELECT * FROM `device_usage` ORDER BY `time` DESC',
        mapper: (Map<String, Object?> row) => DeviceUsage(
            id: row['id'] as int?,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String?,
            time: row['time'] as int));
  }
}

class _$CalorieTuneDao extends CalorieTuneDao {
  _$CalorieTuneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _calorieTuneUpdateAdapter = UpdateAdapter(
            database,
            'calorie_tune',
            ['id'],
            (CalorieTune item) => <String, Object?>{
                  'id': item.id,
                  'mac': item.mac,
                  'calorie_factor': item.calorieFactor,
                  'hr_based': item.hrBased ? 1 : 0,
                  'time': item.time
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final UpdateAdapter<CalorieTune> _calorieTuneUpdateAdapter;

  @override
  Future<List<CalorieTune>> findAllCalorieTunes() async {
    return _queryAdapter.queryList('SELECT * FROM `calorie_tune` ORDER BY `time` DESC',
        mapper: (Map<String, Object?> row) => CalorieTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            calorieFactor: row['calorie_factor'] as double,
            hrBased: (row['hr_based'] as int) != 0,
            time: row['time'] as int));
  }

  @override
  Future<int> updateCalorieTune(CalorieTune calorieTune) {
    return _calorieTuneUpdateAdapter.updateAndReturnChangedRows(
        calorieTune, OnConflictStrategy.abort);
  }
}

class _$PowerTuneDao extends PowerTuneDao {
  _$PowerTuneDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<PowerTune>> findAllPowerTunes() async {
    return _queryAdapter.queryList('SELECT * FROM `power_tune` ORDER BY `time` DESC',
        mapper: (Map<String, Object?> row) => PowerTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            powerFactor: row['power_factor'] as double,
            time: row['time'] as int));
  }
}

class _$WorkoutSummaryDao extends WorkoutSummaryDao {
  _$WorkoutSummaryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _workoutSummaryUpdateAdapter = UpdateAdapter(
            database,
            'workout_summary',
            ['id'],
            (WorkoutSummary item) => <String, Object?>{
                  'id': item.id,
                  'device_name': item.deviceName,
                  'device_id': item.deviceId,
                  'manufacturer': item.manufacturer,
                  'start': item.start,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'moving_time': item.movingTime,
                  'speed': item.speed,
                  'sport': item.sport,
                  'power_factor': item.powerFactor,
                  'calorie_factor': item.calorieFactor
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final UpdateAdapter<WorkoutSummary> _workoutSummaryUpdateAdapter;

  @override
  Future<List<WorkoutSummary>> findAllWorkoutSummaries() async {
    return _queryAdapter.queryList('SELECT * FROM `workout_summary`',
        mapper: (Map<String, Object?> row) => WorkoutSummary(
            id: row['id'] as int?,
            deviceName: row['device_name'] as String,
            deviceId: row['device_id'] as String,
            manufacturer: row['manufacturer'] as String,
            start: row['start'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            movingTime: row['moving_time'] as int,
            sport: row['sport'] as String,
            powerFactor: row['power_factor'] as double,
            calorieFactor: row['calorie_factor'] as double));
  }

  @override
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary) {
    return _workoutSummaryUpdateAdapter.updateAndReturnChangedRows(
        workoutSummary, OnConflictStrategy.abort);
  }
}
