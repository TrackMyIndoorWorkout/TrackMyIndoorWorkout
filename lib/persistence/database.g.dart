// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

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
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
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
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ActivityDao _activityDaoInstance;

  RecordDao _recordDaoInstance;

  DeviceUsageDao _deviceUsageDaoInstance;

  CalorieTuneDao _calorieTuneDaoInstance;

  PowerTuneDao _powerTuneDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `activities` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT, `device_id` TEXT, `start` INTEGER, `end` INTEGER, `distance` REAL, `elapsed` INTEGER, `calories` INTEGER, `uploaded` INTEGER, `strava_id` INTEGER, `four_cc` TEXT, `sport` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `activity_id` INTEGER, `time_stamp` INTEGER, `distance` REAL, `elapsed` INTEGER, `calories` INTEGER, `power` INTEGER, `speed` REAL, `cadence` INTEGER, `heart_rate` INTEGER, FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `device_usage` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `sport` TEXT, `mac` TEXT, `name` TEXT, `manufacturer` TEXT, `manufacturer_name` TEXT, `time` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `calorie_tune` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT, `original_calories` INTEGER, `override_calories` INTEGER, `time` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `power_tune` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mac` TEXT, `original_calories` INTEGER, `override_calories` INTEGER, `time` INTEGER)');
        await database.execute(
            'CREATE INDEX `index_activities_start` ON `activities` (`start`)');
        await database.execute(
            'CREATE INDEX `index_records_time_stamp` ON `records` (`time_stamp`)');
        await database.execute(
            'CREATE INDEX `index_device_usage_time` ON `device_usage` (`time`)');
        await database.execute(
            'CREATE INDEX `index_device_usage_mac` ON `device_usage` (`mac`)');
        await database.execute(
            'CREATE INDEX `index_calorie_tune_mac` ON `calorie_tune` (`mac`)');
        await database.execute(
            'CREATE INDEX `index_power_tune_mac` ON `power_tune` (`mac`)');

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
    return _deviceUsageDaoInstance ??=
        _$DeviceUsageDao(database, changeListener);
  }

  @override
  CalorieTuneDao get calorieTuneDao {
    return _calorieTuneDaoInstance ??=
        _$CalorieTuneDao(database, changeListener);
  }

  @override
  PowerTuneDao get powerTuneDao {
    return _powerTuneDaoInstance ??= _$PowerTuneDao(database, changeListener);
  }
}

class _$ActivityDao extends ActivityDao {
  _$ActivityDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _activityInsertionAdapter = InsertionAdapter(
            database,
            'activities',
            (Activity item) => <String, dynamic>{
                  'id': item.id,
                  'device_name': item.deviceName,
                  'device_id': item.deviceId,
                  'start': item.start,
                  'end': item.end,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'calories': item.calories,
                  'uploaded':
                      item.uploaded == null ? null : (item.uploaded ? 1 : 0),
                  'strava_id': item.stravaId,
                  'four_cc': item.fourCC,
                  'sport': item.sport
                },
            changeListener),
        _activityUpdateAdapter = UpdateAdapter(
            database,
            'activities',
            ['id'],
            (Activity item) => <String, dynamic>{
                  'id': item.id,
                  'device_name': item.deviceName,
                  'device_id': item.deviceId,
                  'start': item.start,
                  'end': item.end,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'calories': item.calories,
                  'uploaded':
                      item.uploaded == null ? null : (item.uploaded ? 1 : 0),
                  'strava_id': item.stravaId,
                  'four_cc': item.fourCC,
                  'sport': item.sport
                },
            changeListener),
        _activityDeletionAdapter = DeletionAdapter(
            database,
            'activities',
            ['id'],
            (Activity item) => <String, dynamic>{
                  'id': item.id,
                  'device_name': item.deviceName,
                  'device_id': item.deviceId,
                  'start': item.start,
                  'end': item.end,
                  'distance': item.distance,
                  'elapsed': item.elapsed,
                  'calories': item.calories,
                  'uploaded':
                      item.uploaded == null ? null : (item.uploaded ? 1 : 0),
                  'strava_id': item.stravaId,
                  'four_cc': item.fourCC,
                  'sport': item.sport
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Activity> _activityInsertionAdapter;

  final UpdateAdapter<Activity> _activityUpdateAdapter;

  final DeletionAdapter<Activity> _activityDeletionAdapter;

  @override
  Future<List<Activity>> findAllActivities() async {
    return _queryAdapter.queryList(
        'SELECT * FROM activities ORDER BY start DESC',
        mapper: (Map<String, dynamic> row) => Activity(
            id: row['id'] as int,
            deviceName: row['device_name'] as String,
            deviceId: row['device_id'] as String,
            start: row['start'] as int,
            end: row['end'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            uploaded:
                row['uploaded'] == null ? null : (row['uploaded'] as int) != 0,
            stravaId: row['strava_id'] as int,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String));
  }

  @override
  Stream<Activity> findActivityById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM activities WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'activities',
        isView: false,
        mapper: (Map<String, dynamic> row) => Activity(
            id: row['id'] as int,
            deviceName: row['device_name'] as String,
            deviceId: row['device_id'] as String,
            start: row['start'] as int,
            end: row['end'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            uploaded:
                row['uploaded'] == null ? null : (row['uploaded'] as int) != 0,
            stravaId: row['strava_id'] as int,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String));
  }

  @override
  Future<List<Activity>> findActivities(int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM activities ORDER BY start DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[limit, offset],
        mapper: (Map<String, dynamic> row) => Activity(
            id: row['id'] as int,
            deviceName: row['device_name'] as String,
            deviceId: row['device_id'] as String,
            start: row['start'] as int,
            end: row['end'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            uploaded:
                row['uploaded'] == null ? null : (row['uploaded'] as int) != 0,
            stravaId: row['strava_id'] as int,
            fourCC: row['four_cc'] as String,
            sport: row['sport'] as String));
  }

  @override
  Future<int> insertActivity(Activity activity) {
    return _activityInsertionAdapter.insertAndReturnId(
        activity, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateActivity(Activity activity) {
    return _activityUpdateAdapter.updateAndReturnChangedRows(
        activity, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteActivity(Activity activity) {
    return _activityDeletionAdapter.deleteAndReturnChangedRows(activity);
  }
}

class _$RecordDao extends RecordDao {
  _$RecordDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _recordInsertionAdapter = InsertionAdapter(
            database,
            'records',
            (Record item) => <String, dynamic>{
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
                },
            changeListener),
        _recordUpdateAdapter = UpdateAdapter(
            database,
            'records',
            ['id'],
            (Record item) => <String, dynamic>{
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
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Record> _recordInsertionAdapter;

  final UpdateAdapter<Record> _recordUpdateAdapter;

  @override
  Future<List<Record>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM records ORDER BY time_stamp',
        mapper: (Map<String, dynamic> row) => Record(
            id: row['id'] as int,
            activityId: row['activity_id'] as int,
            timeStamp: row['time_stamp'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            power: row['power'] as int,
            speed: row['speed'] as double,
            cadence: row['cadence'] as int,
            heartRate: row['heart_rate'] as int));
  }

  @override
  Stream<Record> findRecordById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM records WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'records',
        isView: false,
        mapper: (Map<String, dynamic> row) => Record(
            id: row['id'] as int,
            activityId: row['activity_id'] as int,
            timeStamp: row['time_stamp'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            power: row['power'] as int,
            speed: row['speed'] as double,
            cadence: row['cadence'] as int,
            heartRate: row['heart_rate'] as int));
  }

  @override
  Future<List<Record>> findAllActivityRecords(int activityId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM records WHERE activity_id = ? ORDER BY time_stamp',
        arguments: <dynamic>[activityId],
        mapper: (Map<String, dynamic> row) => Record(
            id: row['id'] as int,
            activityId: row['activity_id'] as int,
            timeStamp: row['time_stamp'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            power: row['power'] as int,
            speed: row['speed'] as double,
            cadence: row['cadence'] as int,
            heartRate: row['heart_rate'] as int));
  }

  @override
  Future<List<Record>> deleteAllActivityRecords(int activityId) async {
    return _queryAdapter.queryList('DELETE FROM records WHERE activity_id = ?',
        arguments: <dynamic>[activityId],
        mapper: (Map<String, dynamic> row) => Record(
            id: row['id'] as int,
            activityId: row['activity_id'] as int,
            timeStamp: row['time_stamp'] as int,
            distance: row['distance'] as double,
            elapsed: row['elapsed'] as int,
            calories: row['calories'] as int,
            power: row['power'] as int,
            speed: row['speed'] as double,
            cadence: row['cadence'] as int,
            heartRate: row['heart_rate'] as int));
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
  _$DeviceUsageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _deviceUsageInsertionAdapter = InsertionAdapter(
            database,
            'device_usage',
            (DeviceUsage item) => <String, dynamic>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                },
            changeListener),
        _deviceUsageUpdateAdapter = UpdateAdapter(
            database,
            'device_usage',
            ['id'],
            (DeviceUsage item) => <String, dynamic>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                },
            changeListener),
        _deviceUsageDeletionAdapter = DeletionAdapter(
            database,
            'device_usage',
            ['id'],
            (DeviceUsage item) => <String, dynamic>{
                  'id': item.id,
                  'sport': item.sport,
                  'mac': item.mac,
                  'name': item.name,
                  'manufacturer': item.manufacturer,
                  'manufacturer_name': item.manufacturerName,
                  'time': item.time
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DeviceUsage> _deviceUsageInsertionAdapter;

  final UpdateAdapter<DeviceUsage> _deviceUsageUpdateAdapter;

  final DeletionAdapter<DeviceUsage> _deviceUsageDeletionAdapter;

  @override
  Future<List<DeviceUsage>> findAllDeviceUsages() async {
    return _queryAdapter.queryList(
        'SELECT * FROM device_usage ORDER BY time DESC',
        mapper: (Map<String, dynamic> row) => DeviceUsage(
            id: row['id'] as int,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String,
            time: row['time'] as int));
  }

  @override
  Stream<DeviceUsage> findDeviceUsageById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM device_usage WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'device_usage',
        isView: false,
        mapper: (Map<String, dynamic> row) => DeviceUsage(
            id: row['id'] as int,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String,
            time: row['time'] as int));
  }

  @override
  Stream<DeviceUsage> findDeviceUsageByMac(String mac) {
    return _queryAdapter.queryStream(
        'SELECT * FROM device_usage WHERE mac = ? ORDER BY time DESC LIMIT 1',
        arguments: <dynamic>[mac],
        queryableName: 'device_usage',
        isView: false,
        mapper: (Map<String, dynamic> row) => DeviceUsage(
            id: row['id'] as int,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String,
            time: row['time'] as int));
  }

  @override
  Future<List<DeviceUsage>> findDeviceUsages(int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM device_usage ORDER BY time DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[limit, offset],
        mapper: (Map<String, dynamic> row) => DeviceUsage(
            id: row['id'] as int,
            sport: row['sport'] as String,
            mac: row['mac'] as String,
            name: row['name'] as String,
            manufacturer: row['manufacturer'] as String,
            manufacturerName: row['manufacturer_name'] as String,
            time: row['time'] as int));
  }

  @override
  Future<int> insertDeviceUsage(DeviceUsage deviceUsage) {
    return _deviceUsageInsertionAdapter.insertAndReturnId(
        deviceUsage, OnConflictStrategy.abort);
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
  _$CalorieTuneDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _calorieTuneInsertionAdapter = InsertionAdapter(
            database,
            'calorie_tune',
            (CalorieTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener),
        _calorieTuneUpdateAdapter = UpdateAdapter(
            database,
            'calorie_tune',
            ['id'],
            (CalorieTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener),
        _calorieTuneDeletionAdapter = DeletionAdapter(
            database,
            'calorie_tune',
            ['id'],
            (CalorieTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CalorieTune> _calorieTuneInsertionAdapter;

  final UpdateAdapter<CalorieTune> _calorieTuneUpdateAdapter;

  final DeletionAdapter<CalorieTune> _calorieTuneDeletionAdapter;

  @override
  Future<List<CalorieTune>> findAllCalorieTunes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM calorie_tune ORDER BY time DESC',
        mapper: (Map<String, dynamic> row) => CalorieTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Stream<CalorieTune> findCalorieTuneById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM calorie_tune WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'calorie_tune',
        isView: false,
        mapper: (Map<String, dynamic> row) => CalorieTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Stream<CalorieTune> findCalorieTuneByMac(String mac) {
    return _queryAdapter.queryStream(
        'SELECT * FROM calorie_tune WHERE mac = ? ORDER BY time DESC LIMIT 1',
        arguments: <dynamic>[mac],
        queryableName: 'calorie_tune',
        isView: false,
        mapper: (Map<String, dynamic> row) => CalorieTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Future<List<CalorieTune>> findCalorieTunes(int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM calorie_tune ORDER BY time DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[limit, offset],
        mapper: (Map<String, dynamic> row) => CalorieTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Future<int> insertCalorieTune(CalorieTune calorieTune) {
    return _calorieTuneInsertionAdapter.insertAndReturnId(
        calorieTune, OnConflictStrategy.abort);
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
  _$PowerTuneDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _powerTuneInsertionAdapter = InsertionAdapter(
            database,
            'power_tune',
            (PowerTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener),
        _powerTuneUpdateAdapter = UpdateAdapter(
            database,
            'power_tune',
            ['id'],
            (PowerTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener),
        _powerTuneDeletionAdapter = DeletionAdapter(
            database,
            'power_tune',
            ['id'],
            (PowerTune item) => <String, dynamic>{
                  'id': item.id,
                  'mac': item.mac,
                  'original_calories': item.originalCalories,
                  'override_calories': item.overrideCalories,
                  'time': item.time
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PowerTune> _powerTuneInsertionAdapter;

  final UpdateAdapter<PowerTune> _powerTuneUpdateAdapter;

  final DeletionAdapter<PowerTune> _powerTuneDeletionAdapter;

  @override
  Future<List<PowerTune>> findAllPowerTunes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM power_tune ORDER BY time DESC',
        mapper: (Map<String, dynamic> row) => PowerTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Stream<PowerTune> findPowerTuneById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM power_tune WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'power_tune',
        isView: false,
        mapper: (Map<String, dynamic> row) => PowerTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Stream<PowerTune> findPowerTuneByMac(String mac) {
    return _queryAdapter.queryStream(
        'SELECT * FROM power_tune WHERE mac = ? ORDER BY time DESC LIMIT 1',
        arguments: <dynamic>[mac],
        queryableName: 'power_tune',
        isView: false,
        mapper: (Map<String, dynamic> row) => PowerTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Future<List<PowerTune>> findPowerTunes(int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM power_tune ORDER BY time DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[limit, offset],
        mapper: (Map<String, dynamic> row) => PowerTune(
            id: row['id'] as int,
            mac: row['mac'] as String,
            originalCalories: row['original_calories'] as int,
            overrideCalories: row['override_calories'] as int,
            time: row['time'] as int));
  }

  @override
  Future<int> insertPowerTune(PowerTune powerTune) {
    return _powerTuneInsertionAdapter.insertAndReturnId(
        powerTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePowerTune(PowerTune powerTune) {
    return _powerTuneUpdateAdapter.updateAndReturnChangedRows(
        powerTune, OnConflictStrategy.abort);
  }

  @override
  Future<int> deletePowerTune(PowerTune powerTune) {
    return _powerTuneDeletionAdapter.deleteAndReturnChangedRows(powerTune);
  }
}
