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
      version: 18,
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
            'CREATE TABLE IF NOT EXISTS `activities` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT NOT NULL, `device_id` TEXT NOT NULL, `hrm_id` TEXT NOT NULL, `start` INTEGER NOT NULL, `end` INTEGER NOT NULL, `distance` REAL NOT NULL, `elapsed` INTEGER NOT NULL, `moving_time` INTEGER NOT NULL, `calories` INTEGER NOT NULL, `uploaded` INTEGER NOT NULL, `strava_id` INTEGER NOT NULL, `four_cc` TEXT NOT NULL, `sport` TEXT NOT NULL, `power_factor` REAL NOT NULL, `calorie_factor` REAL NOT NULL, `hr_calorie_factor` REAL NOT NULL, `hrm_calorie_factor` REAL NOT NULL, `hr_based_calories` INTEGER NOT NULL, `time_zone` TEXT NOT NULL, `suunto_uploaded` INTEGER NOT NULL, `suunto_blob_url` TEXT NOT NULL, `under_armour_uploaded` INTEGER NOT NULL, `training_peaks_uploaded` INTEGER NOT NULL, `ua_workout_id` INTEGER NOT NULL, `suunto_upload_id` INTEGER NOT NULL, `suunto_upload_identifier` TEXT NOT NULL, `suunto_workout_url` TEXT NOT NULL, `training_peaks_workout_id` INTEGER NOT NULL, `training_peaks_athlete_id` INTEGER NOT NULL, `training_peaks_file_tracking_uuid` TEXT NOT NULL)');
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
        _activityInsertionAdapter = InsertionAdapter(
            database,
            'activities',
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
                  'training_peaks_athlete_id': item.trainingPeaksAthleteId,
                  'training_peaks_file_tracking_uuid': item.trainingPeaksFileTrackingUuid
                }),
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
                  'training_peaks_athlete_id': item.trainingPeaksAthleteId,
                  'training_peaks_file_tracking_uuid': item.trainingPeaksFileTrackingUuid
                }),
        _activityDeletionAdapter = DeletionAdapter(
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
                  'training_peaks_athlete_id': item.trainingPeaksAthleteId,
                  'training_peaks_file_tracking_uuid': item.trainingPeaksFileTrackingUuid
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Activity> _activityInsertionAdapter;

  final UpdateAdapter<Activity> _activityUpdateAdapter;

  final DeletionAdapter<Activity> _activityDeletionAdapter;

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
            trainingPeaksFileTrackingUuid: row['training_peaks_file_tracking_uuid'] as String,
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
  Future<Activity?> findActivityById(int id) async {
    return _queryAdapter.query('SELECT * FROM `activities` WHERE `id` = ?1',
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
            trainingPeaksFileTrackingUuid: row['training_peaks_file_tracking_uuid'] as String,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String,
            powerFactor: row['power_factor'] as double,
            calorieFactor: row['calorie_factor'] as double,
            hrCalorieFactor: row['hr_calorie_factor'] as double,
            hrmCalorieFactor: row['hrm_calorie_factor'] as double,
            hrBasedCalories: (row['hr_based_calories'] as int) != 0,
            timeZone: row['time_zone'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Activity>> findActivities(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `activities` ORDER BY `start` DESC LIMIT ?1 OFFSET ?2',
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
            trainingPeaksFileTrackingUuid: row['training_peaks_file_tracking_uuid'] as String,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String,
            powerFactor: row['power_factor'] as double,
            calorieFactor: row['calorie_factor'] as double,
            hrCalorieFactor: row['hr_calorie_factor'] as double,
            hrmCalorieFactor: row['hrm_calorie_factor'] as double,
            hrBasedCalories: (row['hr_based_calories'] as int) != 0,
            timeZone: row['time_zone'] as String),
        arguments: [limit, offset]);
  }

  @override
  Future<List<Activity>> findUnfinishedDeviceActivities(String deviceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `activities` WHERE `device_id` = ?1 and `end` = 0 ORDER BY `start` DESC',
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
            trainingPeaksFileTrackingUuid: row['training_peaks_file_tracking_uuid'] as String,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String,
            powerFactor: row['power_factor'] as double,
            calorieFactor: row['calorie_factor'] as double,
            hrCalorieFactor: row['hr_calorie_factor'] as double,
            hrmCalorieFactor: row['hrm_calorie_factor'] as double,
            hrBasedCalories: (row['hr_based_calories'] as int) != 0,
            timeZone: row['time_zone'] as String),
        arguments: [deviceId]);
  }

  @override
  Future<List<Activity>> findUnfinishedActivities() async {
    return _queryAdapter.queryList('SELECT * FROM `activities` WHERE `end` = 0',
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
            trainingPeaksFileTrackingUuid: row['training_peaks_file_tracking_uuid'] as String,
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
  Future<int> insertActivity(Activity activity) {
    return _activityInsertionAdapter.insertAndReturnId(activity, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateActivity(Activity activity) {
    return _activityUpdateAdapter.updateAndReturnChangedRows(activity, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteActivity(Activity activity) {
    return _activityDeletionAdapter.deleteAndReturnChangedRows(activity);
  }
}

class _$RecordDao extends RecordDao {
  _$RecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recordInsertionAdapter = InsertionAdapter(
            database,
            'records',
            (Record item) => <String, Object?>{
                  'id': item.id,
                  'activity_id': item.activityId,
                  'time_stamp': item.timeStamp,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'calories': item.calories,
                  'power': item.power,
                  'speed': item.speed,
                  'cadence': item.cadence,
                  'heart_rate': item.heartRate
                }),
        _recordUpdateAdapter = UpdateAdapter(
            database,
            'records',
            ['id'],
            (Record item) => <String, Object?>{
                  'id': item.id,
                  'activity_id': item.activityId,
                  'time_stamp': item.timeStamp,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'calories': item.calories,
                  'power': item.power,
                  'speed': item.speed,
                  'cadence': item.cadence,
                  'heart_rate': item.heartRate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Record> _recordInsertionAdapter;

  final UpdateAdapter<Record> _recordUpdateAdapter;

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

  @override
  Future<Record?> findRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM `records` WHERE `id` = ?1',
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
            heartRate: row['heart_rate'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<Record>> findAllActivityRecords(int activityId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `records` WHERE `activity_id` = ?1 ORDER BY `time_stamp`',
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
            heartRate: row['heart_rate'] as int?),
        arguments: [activityId]);
  }

  @override
  Future<Record?> findLastRecordOfActivity(int activityId) async {
    return _queryAdapter.query(
        'SELECT * FROM `records` WHERE `activity_id` = ?1 ORDER BY `time_stamp` DESC LIMIT 1',
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
            heartRate: row['heart_rate'] as int?),
        arguments: [activityId]);
  }

  @override
  Future<int?> deleteAllActivityRecords(int activityId) async {
    return _queryAdapter.query('DELETE FROM `records` WHERE `activity_id` = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int, arguments: [activityId]);
  }

  @override
  Future<void> insertRecord(Record record) async {
    await _recordInsertionAdapter.insert(record, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(Record record) async {
    await _recordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }
}

class _$DeviceUsageDao extends DeviceUsageDao {
  _$DeviceUsageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _deviceUsageInsertionAdapter = InsertionAdapter(
            database,
            'device_usage',
            (DeviceUsage item) => <String, Object?>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                }),
        _deviceUsageUpdateAdapter = UpdateAdapter(
            database,
            'device_usage',
            ['id'],
            (DeviceUsage item) => <String, Object?>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                }),
        _deviceUsageDeletionAdapter = DeletionAdapter(
            database,
            'device_usage',
            ['id'],
            (DeviceUsage item) => <String, Object?>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DeviceUsage> _deviceUsageInsertionAdapter;

  final UpdateAdapter<DeviceUsage> _deviceUsageUpdateAdapter;

  final DeletionAdapter<DeviceUsage> _deviceUsageDeletionAdapter;

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

  @override
  Future<DeviceUsage?> findDeviceUsageById(int id) async {
    return _queryAdapter.query('SELECT * FROM `device_usage` WHERE `id` = ?1',
        mapper: (Map<String, Object?> row) => DeviceUsage(
            id: row['id'] as int?,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String?,
            time: row['time'] as int),
        arguments: [id]);
  }

  @override
  Future<DeviceUsage?> findDeviceUsageByMac(String mac) async {
    return _queryAdapter.query(
        'SELECT * FROM `device_usage` WHERE `mac` = ?1 ORDER BY `time` DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => DeviceUsage(
            id: row['id'] as int?,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String?,
            time: row['time'] as int),
        arguments: [mac]);
  }

  @override
  Future<List<DeviceUsage>> findDeviceUsages(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `device_usage` ORDER BY `time` DESC LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => DeviceUsage(
            id: row['id'] as int?,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String?,
            time: row['time'] as int),
        arguments: [limit, offset]);
  }

  @override
  Future<int> insertDeviceUsage(DeviceUsage deviceUsage) {
    return _deviceUsageInsertionAdapter.insertAndReturnId(deviceUsage, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateDeviceUsage(DeviceUsage deviceUsage) {
    return _deviceUsageUpdateAdapter.updateAndReturnChangedRows(
        deviceUsage, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteDeviceUsage(DeviceUsage deviceUsage) {
    return _deviceUsageDeletionAdapter.deleteAndReturnChangedRows(deviceUsage);
  }
}

class _$CalorieTuneDao extends CalorieTuneDao {
  _$CalorieTuneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _calorieTuneInsertionAdapter = InsertionAdapter(
            database,
            'calorie_tune',
            (CalorieTune item) => <String, Object?>{
                  'id': item.id,
                  'mac': item.mac,
                  'calorie_factor': item.calorieFactor,
                  'hr_based': item.hrBased ? 1 : 0,
                  'time': item.time
                }),
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
                }),
        _calorieTuneDeletionAdapter = DeletionAdapter(
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

  final InsertionAdapter<CalorieTune> _calorieTuneInsertionAdapter;

  final UpdateAdapter<CalorieTune> _calorieTuneUpdateAdapter;

  final DeletionAdapter<CalorieTune> _calorieTuneDeletionAdapter;

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
  Future<CalorieTune?> findCalorieTuneById(int id) async {
    return _queryAdapter.query('SELECT * FROM `calorie_tune` WHERE `id` = ?1',
        mapper: (Map<String, Object?> row) => CalorieTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            calorieFactor: row['calorie_factor'] as double,
            hrBased: (row['hr_based'] as int) != 0,
            time: row['time'] as int),
        arguments: [id]);
  }

  @override
  Future<CalorieTune?> findCalorieTuneByMac(String mac) async {
    return _queryAdapter.query(
        'SELECT * FROM `calorie_tune` WHERE `mac` = ?1 AND `hr_based` = 0 ORDER BY `time` DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => CalorieTune(id: row['id'] as int?, mac: row['mac'] as String, calorieFactor: row['calorie_factor'] as double, hrBased: (row['hr_based'] as int) != 0, time: row['time'] as int),
        arguments: [mac]);
  }

  @override
  Future<CalorieTune?> findHrCalorieTuneByMac(String mac) async {
    return _queryAdapter.query(
        'SELECT * FROM `calorie_tune` WHERE `mac` = ?1 AND `hr_based` = 1 ORDER BY `time` DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => CalorieTune(id: row['id'] as int?, mac: row['mac'] as String, calorieFactor: row['calorie_factor'] as double, hrBased: (row['hr_based'] as int) != 0, time: row['time'] as int),
        arguments: [mac]);
  }

  @override
  Future<List<CalorieTune>> findCalorieTunes(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `calorie_tune` ORDER BY `time` DESC LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => CalorieTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            calorieFactor: row['calorie_factor'] as double,
            hrBased: (row['hr_based'] as int) != 0,
            time: row['time'] as int),
        arguments: [limit, offset]);
  }

  @override
  Future<int> insertCalorieTune(CalorieTune calorieTune) {
    return _calorieTuneInsertionAdapter.insertAndReturnId(calorieTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateCalorieTune(CalorieTune calorieTune) {
    return _calorieTuneUpdateAdapter.updateAndReturnChangedRows(
        calorieTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteCalorieTune(CalorieTune calorieTune) {
    return _calorieTuneDeletionAdapter.deleteAndReturnChangedRows(calorieTune);
  }
}

class _$PowerTuneDao extends PowerTuneDao {
  _$PowerTuneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _powerTuneInsertionAdapter = InsertionAdapter(
            database,
            'power_tune',
            (PowerTune item) => <String, Object?>{
                  'id': item.id,
                  'mac': item.mac,
                  'power_factor': item.powerFactor,
                  'time': item.time
                }),
        _powerTuneUpdateAdapter = UpdateAdapter(
            database,
            'power_tune',
            ['id'],
            (PowerTune item) => <String, Object?>{
                  'id': item.id,
                  'mac': item.mac,
                  'power_factor': item.powerFactor,
                  'time': item.time
                }),
        _powerTuneDeletionAdapter = DeletionAdapter(
            database,
            'power_tune',
            ['id'],
            (PowerTune item) => <String, Object?>{
                  'id': item.id,
                  'mac': item.mac,
                  'power_factor': item.powerFactor,
                  'time': item.time
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PowerTune> _powerTuneInsertionAdapter;

  final UpdateAdapter<PowerTune> _powerTuneUpdateAdapter;

  final DeletionAdapter<PowerTune> _powerTuneDeletionAdapter;

  @override
  Future<List<PowerTune>> findAllPowerTunes() async {
    return _queryAdapter.queryList('SELECT * FROM `power_tune` ORDER BY `time` DESC',
        mapper: (Map<String, Object?> row) => PowerTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            powerFactor: row['power_factor'] as double,
            time: row['time'] as int));
  }

  @override
  Future<PowerTune?> findPowerTuneById(int id) async {
    return _queryAdapter.query('SELECT * FROM `power_tune` WHERE `id` = ?1',
        mapper: (Map<String, Object?> row) => PowerTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            powerFactor: row['power_factor'] as double,
            time: row['time'] as int),
        arguments: [id]);
  }

  @override
  Future<PowerTune?> findPowerTuneByMac(String mac) async {
    return _queryAdapter.query(
        'SELECT * FROM `power_tune` WHERE `mac` = ?1 ORDER BY `time` DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => PowerTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            powerFactor: row['power_factor'] as double,
            time: row['time'] as int),
        arguments: [mac]);
  }

  @override
  Future<List<PowerTune>> findPowerTunes(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `power_tune` ORDER BY `time` DESC LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => PowerTune(
            id: row['id'] as int?,
            mac: row['mac'] as String,
            powerFactor: row['power_factor'] as double,
            time: row['time'] as int),
        arguments: [limit, offset]);
  }

  @override
  Future<int> insertPowerTune(PowerTune powerTune) {
    return _powerTuneInsertionAdapter.insertAndReturnId(powerTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePowerTune(PowerTune powerTune) {
    return _powerTuneUpdateAdapter.updateAndReturnChangedRows(powerTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> deletePowerTune(PowerTune powerTune) {
    return _powerTuneDeletionAdapter.deleteAndReturnChangedRows(powerTune);
  }
}

class _$WorkoutSummaryDao extends WorkoutSummaryDao {
  _$WorkoutSummaryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _workoutSummaryInsertionAdapter = InsertionAdapter(
            database,
            'workout_summary',
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
                }),
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
                }),
        _workoutSummaryDeletionAdapter = DeletionAdapter(
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

  final InsertionAdapter<WorkoutSummary> _workoutSummaryInsertionAdapter;

  final UpdateAdapter<WorkoutSummary> _workoutSummaryUpdateAdapter;

  final DeletionAdapter<WorkoutSummary> _workoutSummaryDeletionAdapter;

  @override
  Future<List<WorkoutSummary>> findAllWorkoutSummaries() async {
    return _queryAdapter.queryList('SELECT * FROM `workout_summary` ORDER BY `speed` DESC',
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
  Future<List<String>> findDistinctWorkoutSummarySports() async {
    return _queryAdapter.queryList('SELECT DISTINCT `sport` FROM `workout_summary`',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<int?> getLeaderboardDataCount() async {
    return _queryAdapter.query('SELECT COUNT(`id`) FROM `workout_summary`',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<WorkoutSummary?> findWorkoutSummaryById(int id) async {
    return _queryAdapter.query('SELECT * FROM `workout_summary` WHERE `id` = ?1',
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
            calorieFactor: row['calorie_factor'] as double),
        arguments: [id]);
  }

  @override
  Future<List<WorkoutSummary>> findAllWorkoutSummariesByDevice(String deviceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `workout_summary` WHERE `device_id` = ?1 ORDER BY `speed` DESC',
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
            calorieFactor: row['calorie_factor'] as double),
        arguments: [deviceId]);
  }

  @override
  Future<List<WorkoutSummary>> findWorkoutSummaryByDevice(
    String deviceId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `workout_summary` WHERE `device_id` = ?1 ORDER BY `speed` DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => WorkoutSummary(id: row['id'] as int?, deviceName: row['device_name'] as String, deviceId: row['device_id'] as String, manufacturer: row['manufacturer'] as String, start: row['start'] as int, distance: row['distance'] as double, elapsed: row['elapsed'] as int, movingTime: row['moving_time'] as int, sport: row['sport'] as String, powerFactor: row['power_factor'] as double, calorieFactor: row['calorie_factor'] as double),
        arguments: [deviceId, limit, offset]);
  }

  @override
  Future<List<WorkoutSummary>> findAllWorkoutSummariesBySport(String sport) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `workout_summary` WHERE `sport` = ?1 ORDER BY `speed` DESC',
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
            calorieFactor: row['calorie_factor'] as double),
        arguments: [sport]);
  }

  @override
  Future<List<WorkoutSummary>> findWorkoutSummaryBySport(
    String sport,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `workout_summary` WHERE `sport` = ?1 ORDER BY `speed` DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => WorkoutSummary(id: row['id'] as int?, deviceName: row['device_name'] as String, deviceId: row['device_id'] as String, manufacturer: row['manufacturer'] as String, start: row['start'] as int, distance: row['distance'] as double, elapsed: row['elapsed'] as int, movingTime: row['moving_time'] as int, sport: row['sport'] as String, powerFactor: row['power_factor'] as double, calorieFactor: row['calorie_factor'] as double),
        arguments: [sport, limit, offset]);
  }

  @override
  Future<int> insertWorkoutSummary(WorkoutSummary workoutSummary) {
    return _workoutSummaryInsertionAdapter.insertAndReturnId(
        workoutSummary, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary) {
    return _workoutSummaryUpdateAdapter.updateAndReturnChangedRows(
        workoutSummary, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteWorkoutSummary(WorkoutSummary workoutSummary) {
    return _workoutSummaryDeletionAdapter.deleteAndReturnChangedRows(workoutSummary);
  }
}
