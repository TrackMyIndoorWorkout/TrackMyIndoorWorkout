import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../utils/constants.dart';
import 'activity.dart';
import 'calorie_tune.dart';
import 'power_tune.dart';
import 'record.dart';
import 'workout_summary.dart';

class DbUtils {
  late final Isar database;

  DbUtils() {
    database = Get.find<Isar>();
  }

  bool hasLeaderboardData() {
    return database.workoutSummarys.countSync() > 0;
  }

  bool hasRecords(Id activityId) {
    return activityId != Isar.minId &&
        activityId != Isar.autoIncrement &&
        database.records.where().filter().activityIdEqualTo(activityId).countSync() > 0;
  }

  Future<List<Record>> getRecords(Id activityId) async {
    return await database.records.where().filter().activityIdEqualTo(activityId).findAll();
  }

  Future<Record?> getLastRecord(Id activityId) async {
    final records = await getRecords(activityId);
    return records.lastOrNull;
  }

  Future<bool> recalculateDistance(Activity activity, [force = false]) async {
    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    var previousRecord = records.first;
    for (final record in records.skip(1)) {
      final dTMillis = record.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
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

  Future<List<Activity>> unfinishedDeviceActivities(String mac) async {
    return database.activitys.where().filter().endIsNull().deviceIdEqualTo(mac).findAll();
  }

  Future<List<Activity>> unfinishedActivities() async {
    return database.activitys.where().filter().endIsNull().findAll();
  }

  Future<double> powerFactor(String deviceId) async {
    final powerTune =
        await database.powerTunes.where(sort: Sort.desc).filter().macEqualTo(deviceId).findFirst();
    return powerTune?.powerFactor ?? 1.0;
  }

  Future<CalorieTune?> findCalorieTuneByMac(String mac, bool hrBased) async {
    return await database.calorieTunes
        .where(sort: Sort.desc)
        .filter()
        .macEqualTo(mac)
        .hrBasedEqualTo(hrBased)
        .findFirst();
  }

  Future<double> calorieFactorValue(String deviceId, bool hrBased) async {
    final calorieTune = await findCalorieTuneByMac(deviceId, hrBased);
    return calorieTune?.calorieFactor ?? 1.0;
  }

  Future<Tuple3<double, double, double>> getFactors(String deviceId) async {
    return Tuple3(
      await powerFactor(deviceId),
      await calorieFactorValue(deviceId, false),
      await calorieFactorValue(deviceId, true),
    );
  }

  Future<bool> finalizeActivity(Activity activity) async {
    final lastRecord = await getLastRecord(activity.id);
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

    if (lastRecord.timeStamp != null && activity.end != null) {
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
