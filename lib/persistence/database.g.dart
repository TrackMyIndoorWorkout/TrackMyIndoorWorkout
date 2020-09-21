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

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `activities` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `device_name` TEXT, `device_id` TEXT, `start` INTEGER, `end` INTEGER, `distance` REAL, `elapsed` INTEGER, `calories` INTEGER, `uploaded` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `activity_id` INTEGER, `time_stamp` INTEGER, `distance` REAL, `elapsed` INTEGER, `calories` INTEGER, `power` INTEGER, `speed` REAL, `cadence` INTEGER, `heart_rate` INTEGER, `lon` REAL, `lat` REAL, FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE INDEX `index_activities_start` ON `activities` (`start`)');
        await database.execute(
            'CREATE INDEX `index_records_time_stamp` ON `records` (`time_stamp`)');

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
                      item.uploaded == null ? null : (item.uploaded ? 1 : 0)
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
                      item.uploaded == null ? null : (item.uploaded ? 1 : 0)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _activitiesMapper = (Map<String, dynamic> row) => Activity(
      id: row['id'] as int,
      deviceName: row['device_name'] as String,
      deviceId: row['device_id'] as String,
      start: row['start'] as int,
      end: row['end'] as int,
      distance: row['distance'] as double,
      elapsed: row['elapsed'] as int,
      calories: row['calories'] as int,
      uploaded: row['uploaded'] == null ? null : (row['uploaded'] as int) != 0);

  final InsertionAdapter<Activity> _activityInsertionAdapter;

  final UpdateAdapter<Activity> _activityUpdateAdapter;

  @override
  Future<List<Activity>> findAllActivities() async {
    return _queryAdapter.queryList(
        'SELECT * FROM activities ORDER BY start DESC',
        mapper: _activitiesMapper);
  }

  @override
  Stream<Activity> findActivityById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM activities WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'activities',
        isView: false,
        mapper: _activitiesMapper);
  }

  @override
  Future<List<Activity>> findActivities(int offset, int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM activities ORDER BY start DESC LIMIT ?, ?',
        arguments: <dynamic>[offset, limit],
        mapper: _activitiesMapper);
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
                  'heart_rate': item.heartRate,
                  'lon': item.lon,
                  'lat': item.lat
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
                  'heart_rate': item.heartRate,
                  'lon': item.lon,
                  'lat': item.lat
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _recordsMapper = (Map<String, dynamic> row) => Record(
      id: row['id'] as int,
      activityId: row['activity_id'] as int,
      timeStamp: row['time_stamp'] as int,
      distance: row['distance'] as double,
      elapsed: row['elapsed'] as int,
      calories: row['calories'] as int,
      power: row['power'] as int,
      speed: row['speed'] as double,
      cadence: row['cadence'] as int,
      heartRate: row['heart_rate'] as int,
      lon: row['lon'] as double,
      lat: row['lat'] as double);

  final InsertionAdapter<Record> _recordInsertionAdapter;

  final UpdateAdapter<Record> _recordUpdateAdapter;

  @override
  Future<List<Record>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM records ORDER BY time_stamp',
        mapper: _recordsMapper);
  }

  @override
  Stream<Record> findRecordById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM records WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'records',
        isView: false,
        mapper: _recordsMapper);
  }

  @override
  Future<List<Record>> findAllActivityRecords(int activityId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM records WHERE activity_id = ? ORDER BY time_stamp',
        arguments: <dynamic>[activityId],
        mapper: _recordsMapper);
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
