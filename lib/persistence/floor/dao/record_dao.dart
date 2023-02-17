import 'package:floor/floor.dart';
import '../models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM `$recordsTableName` ORDER BY `time_stamp`')
  Future<List<Record>> findAllRecords();
}
