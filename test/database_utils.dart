import 'dart:math';

import 'package:collection/collection.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/activity_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/calorie_tune_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/device_usage_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/power_tune_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/record_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/dao/workout_summary_dao.dart';
import 'package:track_my_indoor_exercise/persistence/floor/database.dart';
import 'package:track_my_indoor_exercise/persistence/isar/activity.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';

class InMemoryActivityDao extends ActivityDao {
  int idCounter = Random().nextInt(1000);
  List<Activity> activities = [];

  Activity? _getActivityById(int id) {
    return activities.firstWhereOrNull((element) => element.id == id);
  }

  @override
  Future<int> deleteActivity(Activity activity) async {
    final act = _getActivityById(activity.id);
    if (act == null) {
      return 0;
    }

    return activities.remove(act) ? 1 : 0;
  }

  @override
  Future<List<Activity>> findActivities(int limit, int offset) async {
    return activities.skip(offset).take(limit).toList();
  }

  @override
  Future<Activity?> findActivityById(int id) async {
    return activities.firstWhereOrNull((element) => element.id == id);
  }

  @override
  Future<List<Activity>> findAllActivities() async {
    return activities;
  }

  @override
  Future<List<Activity>> findUnfinishedDeviceActivities(String deviceId) async {
    return activities
        .where((element) => element.deviceId == deviceId && element.end == 0)
        .sortedByCompare<int>((element) => element.start, (int e1, int e2) => e1 - e2)
        .toList();
  }

  @override
  Future<List<Activity>> findUnfinishedActivities() async {
    return activities.where((element) => element.end == 0).toList();
  }

  @override
  Future<int> insertActivity(Activity activity) async {
    final act = _getActivityById(activity.id);
    if (act != null) {
      // Falls back to update
      final index = activities.indexOf(act);
      activities[index] = activity;
    } else {
      activities.add(activity);
    }

    return activity.id;
  }

  @override
  Future<int> updateActivity(Activity activity) async {
    final act = _getActivityById(activity.id);
    if (act == null) {
      return 0;
    }

    final index = activities.indexOf(act);
    activities[index] = activity;

    return 1;
  }
}

class InMemoryRecordDao extends RecordDao {
  int idCounter = Random().nextInt(1000);
  List<Record> records = [];

  Record? _getRecordById(int id) {
    return records.firstWhereOrNull((element) => element.id == id);
  }

  @override
  Future<List<Record>> deleteAllActivityRecords(int activityId) async {
    records.removeWhere((element) => element.activityId == activityId);
    return [];
  }

  @override
  Future<List<Record>> findAllActivityRecords(int activityId) async {
    return records.where((element) => element.activityId == activityId).toList();
  }

  @override
  Future<List<Record>> findAllRecords() async {
    return records;
  }

  @override
  Future<Record?> findLastRecordOfActivity(int activityId) async {
    return records
        .where((element) => element.activityId == activityId)
        .sortedByCompare<int?>(
            (element) => element.timeStamp, (int? e1, int? e2) => (e1 ?? 0).compareTo(e2 ?? 0))
        .last;
  }

  @override
  Future<Record?> findRecordById(int id) async {
    return records.firstWhereOrNull((element) => element.id == id);
  }

  @override
  Future<void> insertRecord(Record record) async {
    record.id ??= idCounter++;
    final rec = _getRecordById(record.id);
    if (rec != null) {
      // Falls back to update
      final index = records.indexOf(rec);
      records[index] = record;
    } else {
      records.add(record);
    }
  }

  @override
  Future<void> updateRecord(Record record) async {
    final rec = _getRecordById(record.id);
    if (rec == null) {
      return;
    }

    final index = records.indexOf(rec);
    records[index] = record;
  }
}

class InMemoryDatabase extends AppDatabase {
  late InMemoryActivityDao activityDaoImpl;
  late InMemoryRecordDao recordDaoImpl;

  @override
  ActivityDao get activityDao => activityDaoImpl;
  @override
  RecordDao get recordDao => recordDaoImpl;
  @override
  CalorieTuneDao get calorieTuneDao => throw UnimplementedError();
  @override
  DeviceUsageDao get deviceUsageDao => throw UnimplementedError();
  @override
  PowerTuneDao get powerTuneDao => throw UnimplementedError();
  @override
  WorkoutSummaryDao get workoutSummaryDao => throw UnimplementedError();

  InMemoryDatabase() {
    activityDaoImpl = InMemoryActivityDao();
    recordDaoImpl = InMemoryRecordDao();
  }
}
