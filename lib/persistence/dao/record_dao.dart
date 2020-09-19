import 'package:floor/floor.dart';
import '../models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM $RECORDS_TABLE_NAME')
  Future<List<Record>> findAllRecords();

  @Query('SELECT * FROM $RECORDS_TABLE_NAME WHERE id = :id')
  Stream<Record> findRecordById(int id);

  @insert
  Future<void> insertRecord(Record record);

  @update
  Future<void> updateRecord(Record record);
}
