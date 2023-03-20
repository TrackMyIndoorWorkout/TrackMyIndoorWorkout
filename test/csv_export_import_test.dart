import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/annotations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/csv/csv_export.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/import/csv_importer.dart';
import 'package:track_my_indoor_exercise/persistence/isar/activity.dart';
import 'package:track_my_indoor_exercise/persistence/isar/db_utils.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'utils.dart';

class InMemoryActivityQuery implements Query<Activity> {
  ActivityCollection collection;

  InMemoryActivityQuery(this.collection);

  @override
  Future<R?> aggregate<R>(AggregationOp op) async {
    return aggregateSync(op);
  }

  @override
  R? aggregateSync<R>(AggregationOp op) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteFirst() async {
    return deleteFirstSync();
  }

  @override
  bool deleteFirstSync() {
    if (collection.objs.isEmpty) {
      return false;
    }

    collection.objs.removeAt(0);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> exportJson() async {
    return exportJsonSync();
  }

  @override
  Future<R> exportJsonRaw<R>(R Function(Uint8List p1) callback) async {
    return exportJsonRawSync(callback);
  }

  @override
  R exportJsonRawSync<R>(R Function(Uint8List p1) callback) {
    throw UnimplementedError();
  }

  @override
  List<Map<String, dynamic>> exportJsonSync() {
    throw UnimplementedError();
  }

  @override
  Future<List<Activity>> findAll() async {
    return findAllSync();
  }

  @override
  List<Activity> findAllSync() {
    return collection.objs;
  }

  @override
  Future<Activity> findFirst() async {
    return findFirstSync();
  }

  @override
  Activity findFirstSync() {
    return collection.objs.first;
  }

  @override
  Future<bool> isEmpty() async {
    return isEmptySync();
  }

  @override
  bool isEmptySync() {
    return collection.objs.isEmpty;
  }

  @override
  Future<bool> isNotEmpty() async {
    return isNotEmptySync();
  }

  @override
  bool isNotEmptySync() {
    return collection.objs.isNotEmpty;
  }

  @override
  Stream<List<Activity>> watch({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteAll() async {
    return deleteAllSync();
  }

  @override
  int deleteAllSync() {
    final count = collection.objs.length;
    collection.clearSync();
    return count;
  }

  @override
  Isar get isar => collection.isar;

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Future<int> count() async {
    return countSync();
  }

  @override
  int countSync() {
    return collection.objs.length;
  }
}

class ActivityCollection extends IsarCollection<Activity> {
  int nextId = 0;
  List<Activity> objs = [];
  final Isar inMemoryIsar;

  ActivityCollection(this.inMemoryIsar);

  @override
  Query<Activity> buildQuery<Activity>({
    List<WhereClause> whereClauses = const [],
    bool whereDistinct = false,
    Sort whereSort = Sort.asc,
    FilterOperation? filter,
    List<SortProperty> sortBy = const [],
    List<DistinctProperty> distinctBy = const [],
    int? offset,
    int? limit,
    String? property,
  }) {
    return InMemoryActivityQuery(this) as Query<Activity>;
  }

  @override
  Future<void> clear() async {
    clearSync();
  }

  @override
  void clearSync() {
    objs.clear();
  }

  @override
  Future<int> count() async {
    return countSync();
  }

  @override
  int countSync() {
    return objs.length;
  }

  @override
  Future<int> deleteAll(List<Id> ids) async {
    return deleteAllSync(ids);
  }

  @override
  Future<int> deleteAllByIndex(String indexName, List<IndexKey> keys) async {
    return deleteAllByIndexSync(indexName, keys);
  }

  @override
  int deleteAllByIndexSync(String indexName, List<IndexKey> keys) {
    throw UnimplementedError();
  }

  @override
  int deleteAllSync(List<Id> ids) {
    int beforeSize = objs.length;
    objs.removeWhere((element) => ids.contains(element.id));
    return beforeSize - objs.length;
  }

  @override
  Future<List<Activity?>> getAll(List<Id> ids) async {
    return getAllSync(ids);
  }

  @override
  Future<List<Activity?>> getAllByIndex(String indexName, List<IndexKey> keys) async {
    return getAllByIndexSync(indexName, keys);
  }

  @override
  List<Activity?> getAllByIndexSync(String indexName, List<IndexKey> keys) {
    throw UnimplementedError();
  }

  @override
  List<Activity?> getAllSync(List<Id> ids) {
    return objs.where((element) => ids.contains(element.id)).toList();
  }

  @override
  Future<int> getSize({bool includeIndexes = false, bool includeLinks = false}) async {
    return getSizeSync(includeIndexes: includeIndexes, includeLinks: includeLinks);
  }

  @override
  int getSizeSync({bool includeIndexes = false, bool includeLinks = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> importJson(List<Map<String, dynamic>> json) async {
    importJsonSync(json);
  }

  @override
  Future<void> importJsonRaw(Uint8List jsonBytes) async {
    importJsonRawSync(jsonBytes);
  }

  @override
  void importJsonRawSync(Uint8List jsonBytes) {
    throw UnimplementedError();
  }

  @override
  void importJsonSync(List<Map<String, dynamic>> json) {
    throw UnimplementedError();
  }

  @override
  Isar get isar => inMemoryIsar;

  @override
  Future<List<Id>> putAll(List<Activity> objects) async {
    return putAllSync(objects);
  }

  @override
  Future<List<Id>> putAllByIndex(String indexName, List<Activity> objects) async {
    return putAllByIndexSync(indexName, objects);
  }

  @override
  List<Id> putAllByIndexSync(String indexName, List<Activity> objects, {bool saveLinks = true}) {
    return putAllSync(objects);
  }

  @override
  List<Id> putAllSync(List<Activity> objects, {bool saveLinks = true}) {
    final List<Id> newIds = [];
    for (int i = 0; i < objects.length; i++) {
      final newId = nextId + i;
      objects[i].id = newId;
      newIds.add(newId);
      objs.add(objects[i]);
    }

    return newIds;
  }

  @override
  CollectionSchema<Activity> get schema => ActivitySchema;

  @override
  Future<void> verify(List<Activity> objects) async {}

  @override
  Future<void> verifyLink(String linkName, List<int> sourceIds, List<int> targetIds) async {}

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Stream<Activity?> watchObject(Id id, {bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Stream<void> watchObjectLazy(Id id, {bool fireImmediately = false}) {
    throw UnimplementedError();
  }
}

class InMemoryRecordQuery implements Query<Record> {
  RecordCollection collection;

  InMemoryRecordQuery(this.collection);

  @override
  Future<R?> aggregate<R>(AggregationOp op) async {
    return aggregateSync(op);
  }

  @override
  R? aggregateSync<R>(AggregationOp op) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteFirst() async {
    return deleteFirstSync();
  }

  @override
  bool deleteFirstSync() {
    if (collection.objs.isEmpty) {
      return false;
    }

    collection.objs.removeAt(0);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> exportJson() async {
    return exportJsonSync();
  }

  @override
  Future<R> exportJsonRaw<R>(R Function(Uint8List p1) callback) async {
    return exportJsonRawSync(callback);
  }

  @override
  R exportJsonRawSync<R>(R Function(Uint8List p1) callback) {
    throw UnimplementedError();
  }

  @override
  List<Map<String, dynamic>> exportJsonSync() {
    throw UnimplementedError();
  }

  @override
  Future<List<Record>> findAll() async {
    return findAllSync();
  }

  @override
  List<Record> findAllSync() {
    return collection.objs;
  }

  @override
  Future<Record> findFirst() async {
    return findFirstSync();
  }

  @override
  Record findFirstSync() {
    return collection.objs.first;
  }

  @override
  Future<bool> isEmpty() async {
    return isEmptySync();
  }

  @override
  bool isEmptySync() {
    return collection.objs.isEmpty;
  }

  @override
  Future<bool> isNotEmpty() async {
    return isNotEmptySync();
  }

  @override
  bool isNotEmptySync() {
    return collection.objs.isNotEmpty;
  }

  @override
  Stream<List<Record>> watch({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteAll() async {
    return deleteAllSync();
  }

  @override
  int deleteAllSync() {
    final count = collection.objs.length;
    collection.clearSync();
    return count;
  }

  @override
  Isar get isar => collection.isar;

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Future<int> count() async {
    return countSync();
  }

  @override
  int countSync() {
    return collection.objs.length;
  }
}

class RecordCollection extends IsarCollection<Record> {
  int nextId = 0;
  List<Record> objs = [];
  final Isar inMemoryIsar;

  RecordCollection(this.inMemoryIsar);

  @override
  Query<R> buildQuery<R>({
    List<WhereClause> whereClauses = const [],
    bool whereDistinct = false,
    Sort whereSort = Sort.asc,
    FilterOperation? filter,
    List<SortProperty> sortBy = const [],
    List<DistinctProperty> distinctBy = const [],
    int? offset,
    int? limit,
    String? property,
  }) {
    return InMemoryRecordQuery(this) as Query<R>;
  }

  @override
  Future<void> clear() async {
    clearSync();
  }

  @override
  void clearSync() {
    objs.clear();
  }

  @override
  Future<int> count() async {
    return countSync();
  }

  @override
  int countSync() {
    return objs.length;
  }

  @override
  Future<int> deleteAll(List<Id> ids) async {
    return deleteAllSync(ids);
  }

  @override
  Future<int> deleteAllByIndex(String indexName, List<IndexKey> keys) async {
    return deleteAllByIndexSync(indexName, keys);
  }

  @override
  int deleteAllByIndexSync(String indexName, List<IndexKey> keys) {
    throw UnimplementedError();
  }

  @override
  int deleteAllSync(List<Id> ids) {
    int beforeSize = objs.length;
    objs.removeWhere((element) => ids.contains(element.id));
    return beforeSize - objs.length;
  }

  @override
  Future<List<Record?>> getAll(List<Id> ids) async {
    return getAllSync(ids);
  }

  @override
  Future<List<Record?>> getAllByIndex(String indexName, List<IndexKey> keys) async {
    return getAllByIndexSync(indexName, keys);
  }

  @override
  List<Record?> getAllByIndexSync(String indexName, List<IndexKey> keys) {
    throw UnimplementedError();
  }

  @override
  List<Record?> getAllSync(List<Id> ids) {
    return objs.where((element) => ids.contains(element.id)).toList();
  }

  @override
  Future<int> getSize({bool includeIndexes = false, bool includeLinks = false}) async {
    return getSizeSync(includeIndexes: includeIndexes, includeLinks: includeLinks);
  }

  @override
  int getSizeSync({bool includeIndexes = false, bool includeLinks = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> importJson(List<Map<String, dynamic>> json) async {
    importJsonSync(json);
  }

  @override
  Future<void> importJsonRaw(Uint8List jsonBytes) async {
    importJsonRawSync(jsonBytes);
  }

  @override
  void importJsonRawSync(Uint8List jsonBytes) {
    throw UnimplementedError();
  }

  @override
  void importJsonSync(List<Map<String, dynamic>> json) {
    throw UnimplementedError();
  }

  @override
  Isar get isar => inMemoryIsar;

  @override
  Future<List<Id>> putAll(List<Record> objects) async {
    return putAllSync(objects);
  }

  @override
  Future<List<Id>> putAllByIndex(String indexName, List<Record> objects) async {
    return putAllByIndexSync(indexName, objects);
  }

  @override
  List<Id> putAllByIndexSync(String indexName, List<Record> objects, {bool saveLinks = true}) {
    return putAllSync(objects);
  }

  @override
  List<Id> putAllSync(List<Record> objects, {bool saveLinks = true}) {
    final List<Id> newIds = [];
    for (int i = 0; i < objects.length; i++) {
      final newId = nextId + i;
      objects[i].id = newId;
      newIds.add(newId);
      objs.add(objects[i]);
    }

    return newIds;
  }

  @override
  CollectionSchema<Record> get schema => RecordSchema;

  @override
  Future<void> verify(List<Record> objects) async {}

  @override
  Future<void> verifyLink(String linkName, List<int> sourceIds, List<int> targetIds) async {}

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Stream<Record?> watchObject(Id id, {bool fireImmediately = false}) {
    throw UnimplementedError();
  }

  @override
  Stream<void> watchObjectLazy(Id id, {bool fireImmediately = false}) {
    throw UnimplementedError();
  }
}

class InMemoryDatabase extends Isar {
  late IsarCollection<Activity> activities;
  late IsarCollection<Record> records;

  InMemoryDatabase(String name) : super(name) {
    activities = ActivityCollection(this);
    records = RecordCollection(this);
    attachCollections({
      Activity: activities,
      Record: records,
    });
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
    return callback.call();
  }

  @override
  T txnSync<T>(T Function() callback) {
    return callback.call();
  }

  @override
  Future<void> verify() async {}

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) async {
    return callback.call();
  }

  @override
  T writeTxnSync<T>(T Function() callback, {bool silent = false}) {
    return callback.call();
  }
}

@GenerateNiceMocks([MockSpec<PackageInfo>()])
void main() {
  setUpAll(() async {
    Get.put<Isar>(InMemoryDatabase(mockUUID()), permanent: true);
  });

  group('Migration CSV imports identically', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((recordCount) {
      recordCount += 20;
      test('$recordCount', () async {
        final isar = Get.find<Isar>() as InMemoryDatabase;
        isar.records.clearSync();
        isar.activities.clearSync();

        final countChunk = recordCount ~/ 4;
        final movingCount = recordCount - 2 * countChunk;
        await initPrefServiceForTest();
        final packageInfo = PackageInfo(
          appName: "Track My Indoor Workout",
          packageName: "dev.csaba.track_my_indoor_exercise",
          buildNumber: "199",
          version: "1.0.199",
        );
        Get.put<PackageInfo>(packageInfo);
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final calories = rnd.nextInt(1000);
        final caloriesPerTick = calories / recordCount;
        final distance = rnd.nextDouble() * 10000;
        final distancePerTick = distance / recordCount;
        final activity = Activity(
          id: rnd.nextInt(100000),
          deviceName: descriptor.modelName,
          deviceId: mPowerImportDeviceId,
          hrmId: mockName(),
          start: oneSecondAgo,
          end: oneSecondAgo.add(Duration(seconds: recordCount)),
          distance: distance,
          elapsed: recordCount,
          movingTime: movingCount * 1000,
          calories: calories,
          uploaded: rnd.nextBool(),
          suuntoUploaded: rnd.nextBool(),
          suuntoBlobUrl: mockUrl("https", true),
          underArmourUploaded: rnd.nextBool(),
          trainingPeaksUploaded: rnd.nextBool(),
          stravaId: rnd.nextInt(1000000),
          uaWorkoutId: rnd.nextInt(1000000),
          suuntoUploadIdentifier: mockUUID(),
          suuntoWorkoutUrl: mockUrl("https", true),
          trainingPeaksFileTrackingUuid: mockUUID(),
          trainingPeaksWorkoutId: rnd.nextInt(1000000),
          fourCC: descriptor.fourCC,
          sport: descriptor.sport,
          powerFactor: rnd.nextDouble(),
          calorieFactor: rnd.nextDouble(),
          hrCalorieFactor: rnd.nextDouble(),
          hrmCalorieFactor: rnd.nextDouble(),
          hrBasedCalories: rnd.nextBool(),
          timeZone: "${mockName()}/${mockName()}",
        );

        final recordIdOffset = rnd.nextInt(1000);
        final preRecords = List<ExportRecord>.generate(
          countChunk,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index,
              activityId: activity.id,
              timeStamp: activity.start.add(Duration(seconds: index)),
              distance: 0.0,
              elapsed: index,
              calories: 0,
              power: 0,
              speed: 0.0,
              cadence: 0,
              heartRate: rnd.nextInt(180),
              elapsedMillis: index * 1000,
              sport: descriptor.sport,
            ),
          ),
        );
        final movingRecords = List<ExportRecord>.generate(
          movingCount,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index + countChunk,
              activityId: activity.id,
              timeStamp: activity.start.add(Duration(seconds: index + countChunk)),
              distance: distancePerTick * (index + countChunk),
              elapsed: index + countChunk,
              calories: (caloriesPerTick * (index + countChunk)).round(),
              power: rnd.nextInt(500),
              speed: rnd.nextDouble() * 40.0,
              cadence: rnd.nextInt(120),
              heartRate: rnd.nextInt(180),
              elapsedMillis: index * 1000,
              sport: descriptor.sport,
            ),
          ),
        );
        final postRecords = List<ExportRecord>.generate(
          countChunk,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index + countChunk + movingCount,
              activityId: activity.id,
              timeStamp: activity.start.add(Duration(seconds: index + countChunk + movingCount)),
              distance: movingRecords.last.record.distance,
              elapsed: index + countChunk + movingCount,
              calories: movingRecords.last.record.calories,
              power: 0,
              speed: 0.0,
              cadence: 0,
              heartRate: rnd.nextInt(180),
              elapsedMillis: (index + countChunk + movingCount) * 1000,
              sport: descriptor.sport,
            ),
          ),
        );
        final records = preRecords + movingRecords + postRecords;
        final exportModel = ExportModel(
          activity: activity,
          rawData: true,
          calculateGps: false,
          descriptor: descriptor,
          author: "Csaba Consulting",
          name: appName,
          swVersionMajor: "1",
          swVersionMinor: "0",
          buildVersionMajor: "1",
          buildVersionMinor: "0",
          langID: "en-US",
          partNumber: "0",
          altitude: rnd.nextDouble(),
          records: records,
        );

        final exporter = CsvExport();
        final csvInts = await exporter.getFileCore(exportModel);
        final csvString = utf8.decode(csvInts);

        final importer = CSVImporter(null);
        var importedActivity = await importer.import(csvString, (_) => {});

        expect(importedActivity, isNotNull);
        expect(importedActivity!.deviceId, activity.deviceId);
        expect(importedActivity.deviceName, activity.deviceName);
        expect(importedActivity.hrmId, activity.hrmId);
        expect(importedActivity.start.millisecondsSinceEpoch,
            closeTo(activity.start.millisecondsSinceEpoch, 1000));
        expect(importedActivity.fourCC, activity.fourCC);
        expect(importedActivity.sport, activity.sport);
        expect(importedActivity.powerFactor, activity.powerFactor);
        expect(importedActivity.calorieFactor, activity.calorieFactor);
        expect(importedActivity.hrCalorieFactor, activity.hrCalorieFactor);
        expect(importedActivity.hrmCalorieFactor, activity.hrmCalorieFactor);
        expect(importedActivity.hrBasedCalories, activity.hrBasedCalories);
        expect(importedActivity.timeZone, activity.timeZone);
        // expect(importedActivity.end?.millisecondsSinceEpoch ?? 0,
        //     closeTo(activity.end?.millisecondsSinceEpoch ?? 0, 1000));
        expect(importedActivity.distance, activity.distance);
        expect(importedActivity.elapsed, activity.elapsed);
        expect(importedActivity.calories, activity.calories);
        expect(importedActivity.uploaded, activity.uploaded);
        expect(importedActivity.suuntoUploaded, activity.suuntoUploaded);
        expect(importedActivity.suuntoBlobUrl, activity.suuntoBlobUrl);
        expect(importedActivity.underArmourUploaded, activity.underArmourUploaded);
        expect(importedActivity.trainingPeaksUploaded, activity.trainingPeaksUploaded);
        expect(importedActivity.stravaId, activity.stravaId);
        expect(importedActivity.uaWorkoutId, activity.uaWorkoutId);
        expect(importedActivity.suuntoUploadIdentifier, activity.suuntoUploadIdentifier);
        expect(importedActivity.suuntoWorkoutUrl, activity.suuntoWorkoutUrl);
        expect(
            importedActivity.trainingPeaksFileTrackingUuid, activity.trainingPeaksFileTrackingUuid);
        expect(importedActivity.trainingPeaksWorkoutId, activity.trainingPeaksWorkoutId);
        expect(importedActivity.movingTime, activity.movingTime);

        final importedRecords = await DbUtils().getRecords(importedActivity.id);
        expect(importedRecords.length, records.length);
        for (final pairs in IterableZip<Record>([importedRecords, records.map((e) => e.record)])) {
          expect(pairs[0].activityId, importedActivity.id);
          // expect(pairs[0].timeStamp?.millisecondsSinceEpoch ?? 0,
          //     closeTo(pairs[1].timeStamp?.millisecondsSinceEpoch ?? 0, 1000));
          expect(pairs[0].distance, closeTo(pairs[1].distance!, 1e-2));
          expect(pairs[0].elapsed, pairs[1].elapsed);
          expect(pairs[0].calories, pairs[1].calories);
          expect(pairs[0].power, pairs[1].power);
          expect(pairs[0].speed, closeTo(pairs[1].speed!, 1e-2));
          expect(pairs[0].cadence, pairs[1].cadence);
          expect(pairs[0].heartRate, pairs[1].heartRate);
          expect(pairs[0].sport, pairs[1].sport);
        }

        isar.records.clearSync();
        isar.activities.clearSync();
      });
    });
  });

  group('CSV export does not contain nulls but empty strings instead', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 300, rnd).forEach((recordCount) {
      recordCount += 3;
      test('$recordCount', () async {
        final isar = Get.find<Isar>() as InMemoryDatabase;
        isar.records.clearSync();
        isar.activities.clearSync();

        await initPrefServiceForTest();
        final packageInfo = PackageInfo(
          appName: "Track My Indoor Workout",
          packageName: "dev.csaba.track_my_indoor_exercise",
          buildNumber: "199",
          version: "1.0.199",
        );
        Get.put<PackageInfo>(packageInfo);
        final oneSecondAgo = DateTime.now().subtract(const Duration(seconds: 1));
        final descriptor = DeviceFactory.getSchwinnIcBike();
        final calories = rnd.nextInt(1000);
        final distance = rnd.nextDouble() * 10000;
        final activity = Activity(
          id: rnd.nextInt(100000),
          deviceName: descriptor.modelName,
          deviceId: mPowerImportDeviceId,
          hrmId: mockName(),
          start: oneSecondAgo,
          end: oneSecondAgo.add(Duration(seconds: recordCount)),
          distance: distance,
          elapsed: recordCount,
          movingTime: recordCount * 1000,
          calories: calories,
          uploaded: rnd.nextBool(),
          suuntoUploaded: rnd.nextBool(),
          suuntoBlobUrl: mockUrl("https", true),
          underArmourUploaded: rnd.nextBool(),
          trainingPeaksUploaded: rnd.nextBool(),
          stravaId: rnd.nextInt(1000000),
          uaWorkoutId: rnd.nextInt(1000000),
          suuntoUploadIdentifier: mockUUID(),
          suuntoWorkoutUrl: mockUrl("https", true),
          trainingPeaksFileTrackingUuid: mockUUID(),
          trainingPeaksWorkoutId: rnd.nextInt(1000000),
          fourCC: descriptor.fourCC,
          sport: descriptor.sport,
          powerFactor: rnd.nextDouble(),
          calorieFactor: rnd.nextDouble(),
          hrCalorieFactor: rnd.nextDouble(),
          hrmCalorieFactor: rnd.nextDouble(),
          hrBasedCalories: rnd.nextBool(),
          timeZone: "${mockName()}/${mockName()}",
        );

        final recordIdOffset = rnd.nextInt(1000);
        final records = List<ExportRecord>.generate(
          recordCount,
          (index) => ExportRecord(
            record: Record(
              id: recordIdOffset + index,
              activityId: activity.id,
              timeStamp: null,
              distance: null,
              elapsed: null,
              calories: null,
              power: null,
              speed: null,
              cadence: null,
              heartRate: null,
              elapsedMillis: null,
              sport: descriptor.sport,
            ),
          ),
        );
        final exportModel = ExportModel(
          activity: activity,
          rawData: true,
          calculateGps: false,
          descriptor: descriptor,
          author: "Csaba Consulting",
          name: appName,
          swVersionMajor: "1",
          swVersionMinor: "0",
          buildVersionMajor: "1",
          buildVersionMinor: "0",
          langID: "en-US",
          partNumber: "0",
          altitude: rnd.nextDouble(),
          records: records,
        );

        final exporter = CsvExport();
        final csvInts = await exporter.getFileCore(exportModel);
        final csvString = utf8.decode(csvInts);

        expect(csvString.contains("null"), false);

        final importer = CSVImporter(null);
        var importedActivity = await importer.import(csvString, (_) => {});

        expect(importedActivity, isNotNull);
        expect(importedActivity!.deviceId, activity.deviceId);
        expect(importedActivity.deviceName, activity.deviceName);
        expect(importedActivity.hrmId, activity.hrmId);
        expect(importedActivity.start.millisecondsSinceEpoch,
            closeTo(activity.start.millisecondsSinceEpoch, 1000));
        expect(importedActivity.fourCC, activity.fourCC);
        expect(importedActivity.sport, activity.sport);
        expect(importedActivity.powerFactor, activity.powerFactor);
        expect(importedActivity.calorieFactor, activity.calorieFactor);
        expect(importedActivity.hrCalorieFactor, activity.hrCalorieFactor);
        expect(importedActivity.hrmCalorieFactor, activity.hrmCalorieFactor);
        expect(importedActivity.hrBasedCalories, activity.hrBasedCalories);
        expect(importedActivity.timeZone, activity.timeZone);
        // expect(importedActivity.end?.millisecondsSinceEpoch ?? 0,
        //     closeTo(activity.end?.millisecondsSinceEpoch ?? 0, 1000));
        expect(importedActivity.distance, activity.distance);
        expect(importedActivity.elapsed, activity.elapsed);
        expect(importedActivity.calories, activity.calories);
        expect(importedActivity.uploaded, activity.uploaded);
        expect(importedActivity.suuntoUploaded, activity.suuntoUploaded);
        expect(importedActivity.suuntoBlobUrl, activity.suuntoBlobUrl);
        expect(importedActivity.underArmourUploaded, activity.underArmourUploaded);
        expect(importedActivity.trainingPeaksUploaded, activity.trainingPeaksUploaded);
        expect(importedActivity.stravaId, activity.stravaId);
        expect(importedActivity.uaWorkoutId, activity.uaWorkoutId);
        expect(importedActivity.suuntoUploadIdentifier, activity.suuntoUploadIdentifier);
        expect(importedActivity.suuntoWorkoutUrl, activity.suuntoWorkoutUrl);
        expect(
            importedActivity.trainingPeaksFileTrackingUuid, activity.trainingPeaksFileTrackingUuid);
        expect(importedActivity.trainingPeaksWorkoutId, activity.trainingPeaksWorkoutId);
        expect(importedActivity.movingTime, activity.movingTime);

        final importedRecords = await DbUtils().getRecords(importedActivity.id);
        expect(importedRecords.length, records.length);
        for (final pairs in IterableZip<Record>([importedRecords, records.map((e) => e.record)])) {
          expect(pairs[0].activityId, importedActivity.id);
          expect(pairs[0].timeStamp?.millisecondsSinceEpoch ?? 0,
              closeTo(pairs[1].timeStamp?.millisecondsSinceEpoch ?? 0, 1000));
          expect(pairs[0].distance, pairs[1].distance);
          expect(pairs[0].elapsed, pairs[1].elapsed);
          expect(pairs[0].calories, pairs[1].calories);
          expect(pairs[0].power, pairs[1].power);
          expect(pairs[0].speed, pairs[1].speed);
          expect(pairs[0].cadence, pairs[1].cadence);
          expect(pairs[0].heartRate, pairs[1].heartRate);
          expect(pairs[0].sport, pairs[1].sport);
        }

        isar.records.clearSync();
        isar.activities.clearSync();
      });
    });
  });
}
