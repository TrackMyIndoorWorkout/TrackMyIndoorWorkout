import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../utils/constants.dart';
import 'activity.dart';
import 'calorie_tune.dart';
import 'power_tune.dart';
import 'workout_summary.dart';

class DbUtils {
  static bool hasLeaderboardData() {
    final database = Get.find<Isar>();
    return database.workoutSummarys.count() > 0;
  }

  static Future<bool> recalculateDistance(Activity activity, [force = false]) async {
    if (activity.records.findAll().length <= 1) {
      return false;
    }

    final database = Get.find<Isar>();
    var previousRecord = activity.records.findAll().first;
    for (final record in activity.records.findAll().skip(1)) {
      final dTMillis = record.timeStamp! - previousRecord.timeStamp!;
      final dT = dTMillis / 1000.0;
      if ((record.distance ?? 0.0) < eps || force) {
        record.distance = (previousRecord.distance ?? 0.0);
        if ((record.speed ?? 0.0) > 0 && dT > eps) {
          // Speed already should have powerFactor effect
          double dD = (record.speed ?? 0.0) * DeviceDescriptor.kmh2ms * dT;
          record.distance = record.distance! + dD;
          database.writeTxnSync(() {
            database.records.putSync(record);
          });
        }
      }

      previousRecord = record;
    }

    if ((previousRecord.distance ?? 0.0) > eps && (activity.distance < eps || force)) {
      database.writeTxnSync(() {
        activity.distance = previousRecord.distance!;
        database.activitys.putSync(activity);
      });
    }

    return true;
  }

  static Future<List<Activity>> unfinishedDeviceActivities(String mac) async {
    final database = Get.find<Isar>();
    return database.activitys.where().filter().endEqualTo(0).deviceIdEqualTo(mac).findAll();
  }

  static Future<List<Activity>> unfinishedActivities() async {
    final database = Get.find<Isar>();
    return database.activitys.where().filter().endEqualTo(0).findAll();
  }

  static Future<double> powerFactor(String deviceId) async {
    final database = Get.find<Isar>();
    final powerTune = await database.powerTunes
        .buildQuery(sortBy: [
          const SortProperty(
            property: 'time',
            sort: Sort.desc,
          )
        ])
        .where()
        .filter()
        .macEqualTo(deviceId)
        .findFirst();
    return powerTune?.powerFactor ?? 1.0;
  }

  static Future<CalorieTune?> findCalorieTuneByMac(String mac, bool hrBased) async {
    final database = Get.find<Isar>();
    return await database.calorieTunes
        .buildQuery(sortBy: [
          const SortProperty(
            property: 'time',
            sort: Sort.desc,
          )
        ])
        .where()
        .filter()
        .macEqualTo(mac)
        .hrBasedEqualTo(hrBased)
        .findFirst();
  }

  static Future<double> calorieFactorValue(String deviceId, bool hrBased) async {
    final calorieTune = await findCalorieTuneByMac(deviceId, hrBased);
    return calorieTune?.calorieFactor ?? 1.0;
  }

  static Future<Tuple3<double, double, double>> getFactors(String deviceId) async {
    return Tuple3(
      await powerFactor(deviceId),
      await calorieFactorValue(deviceId, false),
      await calorieFactorValue(deviceId, true),
    );
  }

  static Future<bool> finalizeActivity(Activity activity) async {
    final database = Get.find<Isar>();
    final lastRecord = await recordDao.findLastRecordOfActivity(activity.id);
    if (lastRecord == null) {
      return false;
    }

    int updated = 0;
    if (lastRecord.calories != null && lastRecord.calories! > 0 && activity.calories == 0) {
      activity.calories = lastRecord.calories!;
      updated++;
    }

    if (lastRecord.distance != null && lastRecord.distance! > 0 && activity.distance == 0) {
      activity.distance = lastRecord.distance!;
      updated++;
    }

    if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
      activity.elapsed = lastRecord.elapsed!;
      updated++;
    }

    if (lastRecord.timeStamp != null && lastRecord.timeStamp! > 0 && activity.end == 0) {
      activity.end = lastRecord.timeStamp!;
      updated++;
    }

    if (updated > 0) {
      database.writeTxnSync(() {
        database.activitys.putSync(activity);
      });
    }

    return updated > 0;
  }
}
