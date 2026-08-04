import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:tuple/tuple.dart';

import '../track/activity_calculator.dart';
import '../utils/address_names.dart';
import '../utils/constants.dart';
import 'activity.dart';
import 'calorie_tune.dart';
import 'power_tune.dart';
import 'record.dart';
import 'workout_summary.dart';
import 'device_usage.dart';

class DbUtils {
  late final Isar database;
  final ActivityCalculator _calculator = ActivityCalculator();

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
    return await database.records
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .sortByTimeStamp()
        .findAll();
  }

  Future<Record?> getLastRecord(Id activityId) async {
    final records = await getRecords(activityId);
    return records.lastOrNull;
  }

  Future<bool> recalculateCumulative(Activity activity, bool recalculateMore) async {
    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    await _calculator.recalculateRecords(activity, records, recalculateMore);

    database.writeTxnSync(() {
      for (final record in records.skip(1)) {
        database.records.putSync(record);
      }
    });

    updateActivity(activity);

    return true;
  }

  Future<bool> bridgeDataGaps(Activity activity) async {
    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    final modifiedRecords = _calculator.bridgeDataGaps(records);
    if (modifiedRecords.isNotEmpty) {
      database.writeTxnSync(() {
        for (final record in modifiedRecords) {
          database.records.putSync(record);
        }
      });
    }

    return true;
  }

  Future<List<Activity>> unfinishedDeviceActivities(String mac) async {
    return database.activitys
        .where()
        .filter()
        .endIsNull()
        .deviceIdEqualTo(mac)
        .sortByStartDesc()
        .findAll();
  }

  Future<List<Activity>> unfinishedActivities() async {
    return database.activitys.where().filter().endIsNull().sortByStartDesc().findAll();
  }

  Future<double> powerFactor(String deviceId) async {
    final powerTune = await database.powerTunes
        .where()
        .filter()
        .macEqualTo(deviceId)
        .sortByTimeDesc()
        .findFirst();
    return _calculator.powerFactorFromTune(powerTune);
  }

  Future<CalorieTune?> findCalorieTuneByMac(String mac, bool hrBased) async {
    return await database.calorieTunes
        .where()
        .filter()
        .macEqualTo(mac)
        .hrBasedEqualTo(hrBased)
        .sortByTimeDesc()
        .findFirst();
  }

  Future<double> calorieFactorValue(String deviceId, bool hrBased) async {
    final calorieTune = await findCalorieTuneByMac(deviceId, hrBased);
    return _calculator.calorieFactorFromTune(calorieTune);
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

    bool updated = _calculator.applyFinalization(activity, lastRecord);

    if (activity.movingTime == 0 || activity.strides == 0) {
      final records = await getRecords(activity.id);
      if (records.isEmpty) {
        return false;
      }

      updated = _calculator.applyMovingTimeAndStrides(activity, records) || updated;
    }

    if (updated) {
      updateActivity(activity);
    }

    return updated;
  }

  Future<void> getAddressNameDictionary(AddressNames addressNames) async {
    for (var activity
        in await database.activitys
            .where()
            .filter()
            .deviceNameIsNotEmpty()
            .and()
            .deviceIdIsNotEmpty()
            .and()
            .not()
            .deviceNameEqualTo(unnamedDevice)
            .findAll()) {
      addressNames.addAddressName(activity.deviceId, activity.deviceName);
    }
  }

  Future<bool> appendActivities(int earlierId, int laterId) async {
    final earlierRecords = await getRecords(earlierId);
    final laterRecords = await getRecords(laterId);
    if (earlierRecords.isEmpty || laterRecords.isEmpty) {
      return false;
    }

    final earlier = database.activitys.getSync(earlierId);
    if (earlier == null) {
      return false;
    }

    final later = database.activitys.getSync(laterId);
    if (later == null) {
      return false;
    }

    final earlierWatermark = earlier.end ?? earlierRecords.last.timeStamp;
    if (earlierWatermark == null || earlierWatermark.compareTo(later.start) > 0) {
      return false;
    }

    database.writeTxnSync(() {
      for (var laterRecord in laterRecords) {
        laterRecord.activityId = earlier.id;
        database.records.putSync(laterRecord);
      }
    });

    recalculateCumulative(earlier, false);

    return true;
  }

  void updateActivity(Activity activity) {
    database.writeTxnSync(() {
      database.activitys.putSync(activity);
    });
  }

  Future<bool> offsetActivity(Activity activity, int minutes) async {
    _calculator.applyTimeOffset(activity, minutes);

    updateActivity(activity);

    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    _calculator.applyRecordTimeOffset(records, minutes);

    database.writeTxnSync(() {
      for (final record in records) {
        if (record.timeStamp != null) {
          database.records.putSync(record);
        }
      }
    });

    return true;
  }

  Future<bool> splitActivity(Activity activity, int minutesSplitPoint, int targetId) async {
    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    var target = database.activitys.getSync(targetId);
    if (target == null) {
      target = Activity(
        deviceName: activity.deviceName,
        deviceId: activity.deviceId,
        hrmId: activity.hrmId,
        fourCC: activity.fourCC,
        sport: activity.sport,
        powerFactor: activity.powerFactor,
        calorieFactor: activity.calorieFactor,
        hrCalorieFactor: activity.hrCalorieFactor,
        hrmCalorieFactor: activity.hrmCalorieFactor,
        hrBasedCalories: activity.hrBasedCalories,
        timeZone: activity.timeZone,
        start: activity.start,
        end: activity.end,
      );
      database.writeTxnSync(() {
        database.activitys.putSync(target!); // Keep ! here just in case closure loses promotion
      });
    } else {
      // Assumes empty target activity
      final targetRecords = await getRecords(targetId);
      if (targetRecords.isNotEmpty) {
        return false;
      }
    }

    activity.start = records.first.timeStamp!;
    final plan = _calculator.computeSplitPlan(records, minutesSplitPoint);

    database.writeTxnSync(() {
      for (final record in plan.secondPartRecords) {
        record.activityId = target!.id;
        database.records.putSync(record);
      }
    });

    if (plan.firstPartEnd != null) {
      activity.end = plan.firstPartEnd;
    }
    if (plan.secondPartStart != null) {
      target.start = plan.secondPartStart!;
    }
    target.end = plan.secondPartEnd;
    // if (activity.end != null) {
    //   activity.end = activity.end!.add(-splitPoint);
    // }

    updateActivity(activity);

    recalculateCumulative(activity, true);

    recalculateCumulative(target, true);

    return true;
  }

  Future<int> deleteRecords(Activity activity, int minRecordId, int maxRecordId) async {
    var numDeleted = 0;
    database.writeTxn(() async {
      numDeleted = await database.records
          .where()
          .filter()
          .activityIdEqualTo(activity.id)
          .and()
          .idBetween(minRecordId, maxRecordId)
          .deleteAll();
    });

    return numDeleted;
  }

  Future<Map<String, String>> getDeviceSportDictionary() async {
    final deviceSport = <String, String>{};
    for (final deviceUsage in await database.deviceUsages.where().findAll()) {
      deviceSport[deviceUsage.mac] = deviceUsage.sport;
    }
    return deviceSport;
  }

  Future<DeviceUsage?> getDeviceUsage(String mac) async {
    return await database.deviceUsages
        .where()
        .filter()
        .macEqualTo(mac)
        .sortByTimeDesc()
        .findFirst();
  }

  Future<void> saveDeviceUsage(DeviceUsage deviceUsage) async {
    database.writeTxnSync(() {
      database.deviceUsages.putSync(deviceUsage);
    });
  }
}
