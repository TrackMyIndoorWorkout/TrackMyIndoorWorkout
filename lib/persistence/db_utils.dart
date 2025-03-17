import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';

import '../devices/device_descriptors/device_descriptor.dart';
import '../utils/address_names.dart';
import '../utils/constants.dart';
import '../utils/power_speed_mixin.dart';
import 'activity.dart';
import 'calorie_tune.dart';
import 'power_tune.dart';
import 'record.dart';
import 'workout_summary.dart';

class DbUtils with PowerSpeedMixin {
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

    if (recalculateMore) {
      initPower2SpeedConstants();
    }

    var previousRecord = records.first;
    double calories = 0.0;
    double strides = 0.0;
    double distance = 0.0;
    double movingTime = 0.0;
    for (final record in records.skip(1)) {
      final dTMillis = record.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
      final dTime = dTMillis / 1000.0;

      double speed = record.speed ?? 0.0;
      int power = record.power ?? 0;
      int cadence = record.cadence ?? 0;

      bool moving = (speed > 0.0 || power > 0 || cadence > 0);
      if (moving) {
        movingTime += dTMillis;
        if ((record.cadence ?? 0) <= 0 && (previousRecord.cadence ?? 0) > 0) {
          record.cadence = previousRecord.cadence;
        }

        if ((record.cadence ?? 0) > 0) {
          strides += (record.cadence ?? 0) * dTMillis / (60 * 1000);
        }

        if ((record.power ?? 0) <= 0 && (previousRecord.power ?? 0) > 0) {
          record.power = previousRecord.power;
        }

        if (record.power != null &&
            record.power! > 0.0 &&
            recalculateMore &&
            activity.sport == ActivityType.ride) {
          record.speed = velocityForPowerCardano(record.power!) * DeviceDescriptor.ms2kmh;
        }

        if ((record.speed ?? 0.0) <= eps && (previousRecord.speed ?? 0.0) > eps) {
          record.speed = previousRecord.speed;
        }
      }

      if ((record.heartRate ?? 0) <= 0 && (previousRecord.heartRate ?? 0) > 0) {
        record.heartRate = previousRecord.heartRate;
      }

      record.elapsed = movingTime ~/ 1000;

      // Recalculate distance
      double dDistance = speed * DeviceDescriptor.kmh2ms * dTime;
      distance += dDistance;
      record.distance = distance;

      // Recalculate calories
      double dCal =
          power *
          dTime *
          jToCal *
          activity.calorieFactor *
          DeviceDescriptor.powerCalorieFactorDefault;
      calories += dCal;
      record.calories = calories ~/ 1000;

      database.writeTxnSync(() {
        database.records.putSync(record);
      });

      previousRecord = record;
    }

    activity.distance = previousRecord.distance!;
    activity.calories = previousRecord.calories!;
    if (strides.toInt() > activity.strides) {
      activity.strides = strides.toInt();
    }

    if (activity.end == null || activity.end!.compareTo(previousRecord.timeStamp!) <= 0) {
      activity.end = previousRecord.timeStamp;
    }

    activity.elapsed = activity.end!.difference(activity.start).inSeconds;
    activity.movingTime = movingTime.toInt();

    updateActivity(activity);

    return true;
  }

  Future<bool> bridgeDataGaps(Activity activity) async {
    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    var previousRecord = records.first;
    for (final record in records.skip(1)) {
      bool modified = false;
      if ((record.cadence ?? 0) <= 0 && (previousRecord.cadence ?? 0) > 0) {
        record.cadence = previousRecord.cadence;
        modified = true;
      }

      if ((record.power ?? 0) <= 0 && (previousRecord.power ?? 0) > 0) {
        record.power = previousRecord.power;
        modified = true;
      }

      if ((record.speed ?? 0.0) <= eps && (previousRecord.speed ?? 0.0) > eps) {
        record.speed = previousRecord.speed;
        modified = true;
      }

      if ((record.heartRate ?? 0) <= 0 && (previousRecord.heartRate ?? 0) > 0) {
        record.heartRate = previousRecord.heartRate;
        modified = true;
      }

      if (modified) {
        database.writeTxnSync(() {
          database.records.putSync(record);
        });
      }

      previousRecord = record;
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
    final powerTune =
        await database.powerTunes
            .where()
            .filter()
            .macEqualTo(deviceId)
            .sortByTimeDesc()
            .findFirst();
    return powerTune?.powerFactor ?? 1.0;
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

    if (lastRecord.timeStamp != null && activity.end != null) {
      activity.end = lastRecord.timeStamp!;
      updated++;
    }

    if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
      activity.elapsed = lastRecord.elapsed!;
      updated++;
    }

    if (activity.elapsed == 0 && activity.end != null) {
      final elapsedMillis = activity.end!.difference(activity.start).inMilliseconds;
      if (elapsedMillis >= 1000) {
        activity.elapsed = elapsedMillis ~/ 1000;
        updated++;
      }
    }

    if (activity.movingTime == 0 || activity.strides == 0) {
      final records = await getRecords(activity.id);
      if (records.isEmpty) {
        return false;
      }

      double movingMillis = 0;
      double strides = 0;
      var previousRecord = records.first;
      for (final record in records.skip(1)) {
        final dTMillis = record.timeStamp!.difference(previousRecord.timeStamp!).inMilliseconds;
        if (!record.isNotMoving()) {
          movingMillis += dTMillis;
        }

        double strokeCount = record.strokeCount ?? 0.0;
        if (strokeCount > eps) {
          strides += strokeCount * dTMillis / (1000 * 60);
        }

        previousRecord = record;
      }

      if (movingMillis > eps || strides > eps) {
        if (movingMillis > eps) {
          activity.movingTime = movingMillis.toInt();
        }

        if (strides > eps) {
          activity.strides = strides.toInt();
        }

        updated++;
      }
    }

    if (updated > 0) {
      updateActivity(activity);
    }

    return updated > 0;
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
    final offset = Duration(minutes: minutes);
    activity.start = activity.start.add(offset);
    if (activity.end != null) {
      activity.end = activity.end!.add(offset);
    }

    updateActivity(activity);

    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    database.writeTxnSync(() {
      for (final record in records) {
        if (record.timeStamp != null) {
          record.timeStamp = record.timeStamp!.add(offset);
          database.records.putSync(record);
        }
      }
    });

    return true;
  }

  Future<bool> splitActivity(Activity activity, int minutesSplitPoint, int targetId) async {
    // Assumes empty target activity
    final targetRecords = await getRecords(targetId);
    if (targetRecords.isNotEmpty) {
      return false;
    }

    final target = database.activitys.getSync(targetId);
    if (target == null) {
      return false;
      // Establish new Activity instead of exiting
    }

    final splitPoint = Duration(minutes: minutesSplitPoint);

    final records = await getRecords(activity.id);
    if (records.isEmpty) {
      return false;
    }

    final watermark = activity.start.add(splitPoint);
    database.writeTxnSync(() {
      for (final record in records) {
        if (record.timeStamp != null && record.timeStamp!.compareTo(watermark) > 0) {
          record.activityId = target.id;
          database.records.putSync(record);
        }
      }
    });

    if (activity.end != null) {
      activity.end = activity.end!.add(-splitPoint);
    }

    updateActivity(activity);

    recalculateCumulative(activity, true);

    recalculateCumulative(target, true);

    return true;
  }

  Future<int> deleteRecords(Activity activity, int minRecordId, int maxRecordId) async {
    var numDeleted = 0;
    database.writeTxn(() async {
      numDeleted =
          await database.records
              .where()
              .filter()
              .activityIdEqualTo(activity.id)
              .and()
              .idBetween(minRecordId, maxRecordId)
              .deleteAll();
    });

    return numDeleted;
  }
}
