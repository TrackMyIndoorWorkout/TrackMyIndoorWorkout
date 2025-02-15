import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';

import 'activity_collection.dart';
import 'record_collection.dart';

class InMemoryDatabase extends Isar {
  late IsarCollection<Activity> activities;
  late IsarCollection<Record> records;

  InMemoryDatabase(super.name) {
    activities = ActivityCollection(this);
    records = RecordCollection(this);
    attachCollections({Activity: activities, Record: records});
  }

  @override
  Future<void> copyToFile(String targetPath) async {}

  @override
  String? get directory => "/tmp";

  @override
  Future<int> getSize({bool includeIndexes = false, bool includeLinks = false}) async {
    return 1;
  }

  @override
  int getSizeSync({bool includeIndexes = false, bool includeLinks = false}) {
    return 1;
  }

  @override
  Future<T> txn<T>(Future<T> Function() callback) async {
    return await callback.call();
  }

  @override
  T txnSync<T>(T Function() callback) {
    return callback.call();
  }

  @override
  Future<void> verify() async {}

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) async {
    return await callback.call();
  }

  @override
  T writeTxnSync<T>(T Function() callback, {bool silent = false}) {
    return callback.call();
  }
}
