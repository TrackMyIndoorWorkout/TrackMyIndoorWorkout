import 'package:floor/floor.dart';
import '../models/device_usage.dart';

@dao
abstract class DeviceUsageDao {
  @Query('SELECT * FROM `$deviceUsageTableName` ORDER BY `time` DESC')
  Future<List<DeviceUsage>> findAllDeviceUsages();
}
