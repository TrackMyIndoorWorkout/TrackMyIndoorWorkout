import 'dart:typed_data';
import 'package:isar/isar.dart';

import 'package:track_my_indoor_exercise/persistence/isar/record.dart';

import 'record_collection.dart';

class RecordQuery implements Query<Record> {
  RecordCollection collection;

  RecordQuery(this.collection);

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
