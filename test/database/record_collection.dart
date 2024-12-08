import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';

import 'record_query.dart';

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
    return RecordQuery(this) as Query<R>;
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
