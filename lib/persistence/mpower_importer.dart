import 'dart:convert';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../ui/import_form.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'models/activity.dart';
import 'models/record.dart';
import 'database.dart';
import 'preferences.dart';

class WorkoutRow {
  int power;
  int cadence;
  int heartRate;
  double distance;

  WorkoutRow({
    this.power = 0,
    this.cadence = 0,
    this.heartRate = 0,
    this.distance = 0.0,
    String rowString = "",
    int lastHeartRate = 0,
    required bool heartRateGapWorkaround,
    required int heartRateUpperLimit,
    required String heartRateLimitingMethod,
    required double tuneRatio,
    required bool extendTuning,
  }) {
    if (rowString.length > 0) {
      final values = rowString.split(",");
      this.power = (int.tryParse(values[0]) ?? 0 * tuneRatio).round();
      this.cadence = int.tryParse(values[1]) ?? 0;
      this.heartRate = int.tryParse(values[2]) ?? 0;
      if (this.heartRate == 0 && lastHeartRate > 0 && heartRateGapWorkaround) {
        this.heartRate = lastHeartRate;
      } else if (heartRateUpperLimit > 0 &&
          this.heartRate > heartRateUpperLimit &&
          heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
        if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
          this.heartRate = heartRateUpperLimit;
        } else {
          this.heartRate = 0;
        }
      }

      this.distance = (double.tryParse(values[3]) ?? 0.0) * (extendTuning ? tuneRatio : 1.0);
    }
  }
}

class MPowerEchelon2Importer {
  static const PROGRESS_STEPS = 400;
  static const ENERGY_2_SPEED = 5.28768241564455E-05;
  static const TIME_RESOLUTION_FACTOR = 2;
  static const EPSILON = 0.001;
  static const MAX_ITERATIONS = 100;
  static const DRIVE_TRAIN_LOSS = 0; // %
  static const G_CONST = 9.8067;
  static const BIKER_WEIGHT = 81; // kg
  static const BIKE_WEIGHT = 9; // kg
  static const ROLLING_RESISTANCE_COEFFICIENT = 0.005;
  static const DRAG_COEFFICIENT = 0.63;
  // Backup: 5.4788
  static const FRONTAL_AREA = 4 * FT_TO_M * FT_TO_M; // ft * ft_2_m^2
  static const AIR_DENSITY = 0.076537 * LB_TO_KG / (FT_TO_M * FT_TO_M * FT_TO_M);

  final DateTime start;
  late String message;

  late List<String> _lines;
  late int _linePointer;
  late Map<int, double> _velocityForPowerDict;

  MPowerEchelon2Importer({required this.start}) {
    _velocityForPowerDict = Map<int, double>();
  }

  bool _findLine(String lead) {
    while (_linePointer < _lines.length && !_lines[_linePointer].startsWith(lead)) {
      _linePointer++;
    }

    return _linePointer <= _lines.length;
  }

  double powerForVelocity(velocity) {
    final fRolling = G_CONST * (BIKER_WEIGHT + BIKE_WEIGHT) * ROLLING_RESISTANCE_COEFFICIENT;

    final fDrag = 0.5 * FRONTAL_AREA * DRAG_COEFFICIENT * AIR_DENSITY * velocity * velocity;

    final totalForce = fRolling + fDrag;
    final wheelPower = totalForce * velocity;
    final driveTrainFraction = 1.0 - (DRIVE_TRAIN_LOSS / 100.0);
    final legPower = wheelPower / driveTrainFraction;
    return legPower;
  }

  double velocityForPower(int power) {
    if (_velocityForPowerDict.containsKey(power)) {
      return _velocityForPowerDict[power] ?? 0.0;
    }

    var lowerVelocity = 0.0;
    var upperVelocity = 2000.0;
    var middleVelocity = power * ENERGY_2_SPEED * 1000;
    var middlePower = powerForVelocity(middleVelocity);

    var i = 0;
    do {
      if ((middlePower - power).abs() < EPSILON) break;

      if (middlePower > power)
        upperVelocity = middleVelocity;
      else
        lowerVelocity = middleVelocity;

      middleVelocity = (upperVelocity + lowerVelocity) / 2.0;
      middlePower = powerForVelocity(middleVelocity);
    } while (i++ < MAX_ITERATIONS);

    _velocityForPowerDict[power] = middleVelocity;
    return middleVelocity;
  }

  Future<Activity?> import(String csv, SetProgress setProgress) async {
    LineSplitter lineSplitter = LineSplitter();
    _lines = lineSplitter.convert(csv);
    if (_lines.length < 20) {
      message = "Content too short";
      return null;
    }

    _linePointer = 0;
    if (!_findLine("RIDE SUMMARY")) {
      message = "Cannot locate ride summary";
      return null;
    }

    // Total Time
    if (!_findLine("Total Time")) {
      message = "Couldn't find total time";
      return null;
    }

    final timeLine = _lines[_linePointer].split(",");
    final timeValue = double.tryParse(timeLine[1]);
    if (timeValue == null) {
      message = "Couldn't parse total time";
      return null;
    }

    int totalElapsed = 0;
    if (timeLine[2] == " Minutes") {
      totalElapsed = (timeValue * 60).round();
    } else if (timeLine[2] == " Hours") {
      totalElapsed = (timeValue * 3600).round();
    }

    // Total Distance
    if (!_findLine("Total Distance")) {
      message = "Couldn't find total distance";
      return null;
    }

    final distanceLine = _lines[_linePointer].split(",");
    final distanceValue = double.tryParse(distanceLine[1]);
    if (distanceValue == null) {
      message = "Couldn't parse total distance";
      return null;
    }

    double totalDistance = 0.0;
    if (distanceLine[2] == " MI") {
      totalDistance = distanceValue * 1000 * MI2KM;
    } else if (distanceLine[2] == " KM") {
      totalDistance = distanceValue * 1000;
    } else if (distanceLine[2] == " M") {
      totalDistance = distanceValue;
    }

    if (!_findLine("RIDE DATA")) {
      message = "Cannot locate ride data";
      return null;
    }

    _linePointer++;

    if (_lines[_linePointer] != "Power, RPM, HR, DISTANCE,") {
      message = "Unexpected detailed ride data format";
      return null;
    }

    DeviceDescriptor device = deviceMap[SCHWINN_AC_PERF_PLUS_FOURCC]!;
    device.refreshTuning(MPOWER_IMPORT_DEVICE_ID);
    var activity = Activity(
      deviceName: device.namePrefix,
      deviceId: MPOWER_IMPORT_DEVICE_ID,
      start: start.millisecondsSinceEpoch,
      end: start.add(Duration(seconds: totalElapsed)).millisecondsSinceEpoch,
      distance: totalDistance,
      elapsed: totalElapsed,
      calories: 0,
      startDateTime: start,
      fourCC: device.fourCC,
      sport: device.defaultSport,
      calorieFactor: device.calorieFactor,
      powerFactor: device.powerFactor,
    );
    final prefService = Get.find<PrefServiceShared>().sharedPreferences;
    final extendTuning = prefService.getBool(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
    final database = Get.find<AppDatabase>();
    final id = await database.activityDao.insertActivity(activity);
    activity.id = id;

    final numRow = _lines.length - _linePointer;
    _linePointer++;
    double secondsPerRow = totalElapsed / numRow;
    int secondsPerRowInt = secondsPerRow.round();
    int recordsPerRow = secondsPerRowInt * TIME_RESOLUTION_FACTOR;
    double milliSecondsPerRecord = secondsPerRow * 1000 / recordsPerRow;
    int milliSecondsPerRecordInt = milliSecondsPerRecord.round();

    int recordCount = numRow * recordsPerRow;
    int progressSteps = recordCount ~/ PROGRESS_STEPS;
    int progressCounter = 0;
    int recordCounter = 0;
    double energy = 0;
    double distance = 0;
    double elapsed = 0;
    WorkoutRow? nextRow;
    int lastHeartRate = 0;
    int timeStamp = start.millisecondsSinceEpoch;
    String heartRateGapWorkaroundSetting =
        prefService.getString(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    bool heartRateGapWorkaround =
        heartRateGapWorkaroundSetting == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE;
    int heartRateUpperLimit = getStringIntegerPreference(
      HEART_RATE_UPPER_LIMIT_TAG,
      HEART_RATE_UPPER_LIMIT_DEFAULT,
      HEART_RATE_UPPER_LIMIT_DEFAULT_INT,
      prefService,
    );
    String heartRateLimitingMethod =
        prefService.getString(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;

    while (_linePointer < _lines.length) {
      WorkoutRow row = nextRow ??
          WorkoutRow(
            rowString: _lines[_linePointer],
            lastHeartRate: lastHeartRate,
            heartRateGapWorkaround: heartRateGapWorkaround,
            heartRateUpperLimit: heartRateUpperLimit,
            heartRateLimitingMethod: heartRateLimitingMethod,
            tuneRatio: device.powerFactor,
            extendTuning: extendTuning,
          );

      if (_linePointer + 1 >= _lines.length) {
        nextRow = WorkoutRow(
          heartRateGapWorkaround: heartRateGapWorkaround,
          heartRateUpperLimit: heartRateUpperLimit,
          heartRateLimitingMethod: heartRateLimitingMethod,
          tuneRatio: 1.0,
          extendTuning: extendTuning,
        );
      } else {
        nextRow = WorkoutRow(
          rowString: _lines[_linePointer + 1],
          lastHeartRate: lastHeartRate,
          heartRateGapWorkaround: heartRateGapWorkaround,
          heartRateUpperLimit: heartRateUpperLimit,
          heartRateLimitingMethod: heartRateLimitingMethod,
          tuneRatio: device.powerFactor,
          extendTuning: extendTuning,
        );
      }

      double dPower = (nextRow.power - row.power) / recordsPerRow;
      double dCadence = (nextRow.cadence - row.cadence) / recordsPerRow;
      double dHeartRate = (nextRow.heartRate - row.heartRate) / recordsPerRow;
      double power = row.power.toDouble();
      double cadence = row.cadence.toDouble();
      double heartRate = row.heartRate.toDouble();
      lastHeartRate = row.heartRate;

      for (int i = 0; i < recordsPerRow; i++) {
        final powerInt = power.round();
        final speed = velocityForPower(powerInt);
        final dDistance = speed * milliSecondsPerRecord / 1000;

        final record = RecordWithSport(
          activityId: activity.id,
          timeStamp: timeStamp,
          distance: distance,
          elapsed: elapsed ~/ 1000,
          calories: energy.round(),
          power: powerInt,
          speed: speed * DeviceDescriptor.MS2KMH,
          cadence: cadence.round(),
          heartRate: heartRate.round(),
          elapsedMillis: elapsed.round(),
          sport: activity.sport,
        );

        distance += dDistance;
        final dEnergy =
            power * milliSecondsPerRecord / 1000 * DeviceDescriptor.J2KCAL * device.calorieFactor;
        energy += dEnergy;
        await database.recordDao.insertRecord(record);

        timeStamp += milliSecondsPerRecordInt;
        elapsed += milliSecondsPerRecord;
        power += dPower;
        cadence += dCadence;
        heartRate += dHeartRate;
        recordCounter++;
        progressCounter++;
        if (progressCounter == progressSteps) {
          progressCounter = 0;
          setProgress(recordCounter / recordCount);
        }
      }
      _linePointer++;
    }

    activity.distance = distance;
    activity.calories = energy.round();
    await database.activityDao.updateActivity(activity);

    return activity;
  }
}
