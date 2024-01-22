import 'package:floor/floor.dart';
import '../models/device_usage.dart';

@dao
abstract class DeviceUsageDao {
  @Query('SELECT * FROM `$deviceUsageTableName` ORDER BY `id`')
  Future<List<DeviceUsage>> findAllDeviceUsages();
}
