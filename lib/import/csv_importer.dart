import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../ui/import_form.dart';
import '../utils/constants.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import 'constants.dart';

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

class CSVImporter {
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

  DateTime? start;
  final bool migration;
  String message = "";

  List<String> _lines = [];
  int _linePointer = 0;
  Map<int, double> _velocityForPowerDict = Map<int, double>();

  CSVImporter(this.migration, this.start);

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
    if (!_findLine(RIDE_SUMMARY)) {
      message = "Cannot locate $RIDE_SUMMARY";
      return null;
    }

    // Total Time
    if (!_findLine(TOTAL_TIME)) {
      message = "Couldn't find $TOTAL_TIME";
      return null;
    }

    final timeLine = _lines[_linePointer].split(",");
    final timeValue = double.tryParse(timeLine[1]);
    if (timeValue == null) {
      message = "Couldn't parse $TOTAL_TIME";
      return null;
    }

    int totalElapsed = timeValue.round(); // Seconds by default
    if (timeLine[2].trim() == MINUTES_UNIT) {
      totalElapsed = (timeValue * 60).round();
    } else if (timeLine[2].trim() == HOURS_UNIT) {
      totalElapsed = (timeValue * 3600).round();
    }

    // Total Distance
    if (!_findLine(TOTAL_DISTANCE)) {
      message = "Couldn't find $TOTAL_DISTANCE";
      return null;
    }

    final distanceLine = _lines[_linePointer].split(",");
    final distanceValue = double.tryParse(distanceLine[1]);
    if (distanceValue == null) {
      message = "Couldn't parse $TOTAL_DISTANCE";
      return null;
    }

    double totalDistance = 0.0;
    if (distanceLine[2].trim() == MILE_UNIT) {
      totalDistance = distanceValue * 1000 * MI2KM;
    } else if (distanceLine[2].trim() == KM_UNIT) {
      totalDistance = distanceValue * 1000;
    } else if (distanceLine[2].trim() == METER_UNIT) {
      totalDistance = distanceValue;
    }

    var deviceName = "";
    var deviceId = MPOWER_IMPORT_DEVICE_ID;
    var startTime = 0;
    var endTime = 0;
    var calories = 0;
    var uploaded = false;
    var stravaId = 0;
    var fourCC = "SAP+";
    var sport = ActivityType.Ride;
    var calorieFactor = 1.0;
    var powerFactor = 1.0;
    if (migration) {
      _linePointer++;
      final deviceNameLine = _lines[_linePointer].split(",");
      if (deviceNameLine[0].trim() != DEVICE_NAME) {
        message = "Couldn't parse $DEVICE_NAME";
        return null;
      }

      deviceName = deviceNameLine[1].trim();

      _linePointer++;

      final deviceIdLine = _lines[_linePointer].split(",");
      if (deviceIdLine[0].trim() != DEVICE_ID) {
        message = "Couldn't parse $DEVICE_ID";
        return null;
      }

      deviceId = deviceIdLine[1].trim();

      _linePointer++;

      final startTimeLine = _lines[_linePointer].split(",");
      if (startTimeLine[0].trim() != START_TIME) {
        message = "Couldn't parse $START_TIME";
        return null;
      }

      startTime = int.tryParse(startTimeLine[1]) ?? 0;
      if (startTime == 0) {
        message = "Couldn't parse $START_TIME";
        return null;
      }

      start = DateTime.fromMillisecondsSinceEpoch(startTime);

      _linePointer++;

      final endTimeLine = _lines[_linePointer].split(",");
      if (endTimeLine[0].trim() != END_TIME) {
        message = "Couldn't parse $END_TIME";
        return null;
      }

      endTime = int.tryParse(endTimeLine[1]) ?? 0;
      if (endTime == 0) {
        message = "Couldn't parse $END_TIME";
        return null;
      }

      _linePointer++;

      final calorieLine = _lines[_linePointer].split(",");
      if (calorieLine[0].trim() != CALORIES) {
        message = "Couldn't parse $CALORIES";
        return null;
      }

      calories = int.tryParse(calorieLine[1]) ?? 0;

      _linePointer++;

      final uploadedLine = _lines[_linePointer].split(",");
      if (uploadedLine[0].trim() != UPLOADED_TAG) {
        message = "Couldn't parse $UPLOADED_TAG";
        return null;
      }

      uploaded = uploadedLine[1].trim().toLowerCase() == "true";

      _linePointer++;

      final stravaIdLine = _lines[_linePointer].split(",");
      if (stravaIdLine[0].trim() != STRAVA_ID) {
        message = "Couldn't parse $STRAVA_ID";
        return null;
      }

      stravaId = int.tryParse(stravaIdLine[1]) ?? 0;

      _linePointer++;

      final fourCcLine = _lines[_linePointer].split(",");
      if (fourCcLine[0].trim() != FOUR_CC) {
        message = "Couldn't parse $FOUR_CC";
        return null;
      }

      fourCC = fourCcLine[1].trim();

      _linePointer++;

      final sportLine = _lines[_linePointer].split(",");
      if (sportLine[0].trim() != SPORT_TAG) {
        message = "Couldn't parse $SPORT_TAG";
        return null;
      }

      sport = sportLine[1].trim();

      _linePointer++;

      final powerFactorLine = _lines[_linePointer].split(",");
      if (powerFactorLine[0].trim() != POWER_FACTOR) {
        message = "Couldn't parse $POWER_FACTOR";
        return null;
      }

      powerFactor = double.tryParse(powerFactorLine[1]) ?? 1.0;

      _linePointer++;

      final calorieFactorLine = _lines[_linePointer].split(",");
      if (calorieFactorLine[0].trim() != CALORIE_FACTOR) {
        message = "Couldn't parse $CALORIE_FACTOR";
        return null;
      }

      calorieFactor = double.tryParse(calorieFactorLine[1]) ?? 1.0;
    } else {
      DeviceDescriptor device = deviceMap[SCHWINN_AC_PERF_PLUS_FOURCC]!;
      device.refreshTuning(deviceId);
      deviceName = device.namePrefixes[0];
      fourCC = device.fourCC;
      sport = device.defaultSport;
      calorieFactor = device.calorieFactor;
      powerFactor = device.powerFactor;
      startTime = start!.millisecondsSinceEpoch;
      endTime = start!.add(Duration(seconds: totalElapsed)).millisecondsSinceEpoch;
    }

    if (!_findLine(RIDE_DATA)) {
      message = "Cannot locate $RIDE_DATA";
      return null;
    }

    _linePointer++;

    final rideDataHeader = _lines[_linePointer].split(",");
    if (rideDataHeader[0].trim() != POWER_HEADER ||
        rideDataHeader[1].trim() != RPM_HEADER ||
        rideDataHeader[2].trim() != HR_HEADER ||
        rideDataHeader[3].trim() != DISTANCE_HEADER) {
      message = "Unexpected detailed ride data format";
      return null;
    }
    if (migration &&
        (rideDataHeader[4].trim() != TIME_STAMP ||
            rideDataHeader[5].trim() != ELAPSED ||
            rideDataHeader[6].trim() != SPEED ||
            rideDataHeader[7].trim() != CALORIES)) {
      message = "Unexpected detailed ride data format";
      return null;
    }

    final timeZone = await FlutterNativeTimezone.getLocalTimezone();
    var activity = Activity(
      deviceName: deviceName,
      deviceId: deviceId,
      start: startTime,
      end: endTime,
      distance: totalDistance,
      elapsed: totalElapsed,
      calories: calories,
      startDateTime: start,
      uploaded: uploaded,
      stravaId: stravaId,
      fourCC: fourCC,
      sport: sport,
      calorieFactor: calorieFactor,
      powerFactor: powerFactor,
      timeZone: timeZone,
    );

    final prefService = Get.find<BasePrefService>();
    final extendTuning = prefService.get<bool>(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
    final database = Get.find<AppDatabase>();
    final id = await database.activityDao.insertActivity(activity);
    activity.id = id;

    final numRow = _lines.length - _linePointer;
    _linePointer++;

    if (migration) {
      int progressSteps = numRow ~/ PROGRESS_STEPS;
      int progressCounter = 0;
      int recordCounter = 0;

      while (_linePointer < _lines.length) {
        final values = _lines[_linePointer].split(",");
        final record = Record(
          activityId: activity.id,
          timeStamp: int.tryParse(values[4]),
          distance: double.tryParse(values[3]),
          elapsed: int.tryParse(values[5]),
          calories: int.tryParse(values[7]),
          power: int.tryParse(values[0]),
          speed: double.tryParse(values[6]),
          cadence: int.tryParse(values[1]),
          heartRate: int.tryParse(values[2]),
        );
        await database.recordDao.insertRecord(record);

        _linePointer++;
        recordCounter++;
        progressCounter++;
        if (progressCounter == progressSteps) {
          progressCounter = 0;
          setProgress(recordCounter / numRow);
        }
      }
    } else {
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
      int timeStamp = start!.millisecondsSinceEpoch;
      String heartRateGapWorkaroundSetting =
          prefService.get<String>(HEART_RATE_GAP_WORKAROUND_TAG) ??
              HEART_RATE_GAP_WORKAROUND_DEFAULT;
      bool heartRateGapWorkaround =
          heartRateGapWorkaroundSetting == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE;
      int heartRateUpperLimit =
          prefService.get<int>(HEART_RATE_UPPER_LIMIT_INT_TAG) ?? HEART_RATE_UPPER_LIMIT_DEFAULT;
      String heartRateLimitingMethod =
          prefService.get<String>(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;

      while (_linePointer < _lines.length) {
        WorkoutRow row = nextRow ??
            WorkoutRow(
              rowString: _lines[_linePointer],
              lastHeartRate: lastHeartRate,
              heartRateGapWorkaround: heartRateGapWorkaround,
              heartRateUpperLimit: heartRateUpperLimit,
              heartRateLimitingMethod: heartRateLimitingMethod,
              tuneRatio: powerFactor,
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
            tuneRatio: powerFactor,
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
            speed: speed * DeviceDescriptor.ms2kmh,
            cadence: cadence.round(),
            heartRate: heartRate.round(),
            elapsedMillis: elapsed.round(),
            sport: activity.sport,
          );

          distance += dDistance;
          final dEnergy = power * milliSecondsPerRecord / 1000 * J_TO_KCAL * calorieFactor;
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
    }

    await database.activityDao.updateActivity(activity);

    return activity;
  }
}
