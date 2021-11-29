import 'dart:convert';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../ui/import_form.dart';
import '../utils/constants.dart';
import '../utils/hr_based_calories.dart';
import '../utils/time_zone.dart';
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
    if (rowString.isNotEmpty) {
      final values = rowString.split(",");
      power = (int.tryParse(values[0]) ?? 0 * tuneRatio).round();
      cadence = int.tryParse(values[1]) ?? 0;
      heartRate = int.tryParse(values[2]) ?? 0;
      if (heartRate == 0 && lastHeartRate > 0 && heartRateGapWorkaround) {
        heartRate = lastHeartRate;
      } else if (heartRateUpperLimit > 0 &&
          heartRate > heartRateUpperLimit &&
          heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
        if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
          heartRate = heartRateUpperLimit;
        } else {
          heartRate = 0;
        }
      }

      distance = (double.tryParse(values[3]) ?? 0.0) * (extendTuning ? tuneRatio : 1.0);
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
  String message = "";

  List<String> _lines = [];
  int _linePointer = 0;
  bool _migration = false;
  int _version = CSV_VERSION;
  final Map<int, double> _velocityForPowerDict = <int, double>{};

  CSVImporter(this.start);

  bool _findLine(String lead) {
    while (_linePointer < _lines.length && !_lines[_linePointer].startsWith(lead)) {
      _linePointer++;
    }

    return _linePointer <= _lines.length;
  }

  double powerForVelocity(velocity) {
    const fRolling = G_CONST * (BIKER_WEIGHT + BIKE_WEIGHT) * ROLLING_RESISTANCE_COEFFICIENT;

    final fDrag = 0.5 * FRONTAL_AREA * DRAG_COEFFICIENT * AIR_DENSITY * velocity * velocity;

    final totalForce = fRolling + fDrag;
    final wheelPower = totalForce * velocity;
    const driveTrainFraction = 1.0 - (DRIVE_TRAIN_LOSS / 100.0);
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

      if (middlePower > power) {
        upperVelocity = middleVelocity;
      } else {
        lowerVelocity = middleVelocity;
      }

      middleVelocity = (upperVelocity + lowerVelocity) / 2.0;
      middlePower = powerForVelocity(middleVelocity);
    } while (i++ < MAX_ITERATIONS);

    _velocityForPowerDict[power] = middleVelocity;
    return middleVelocity;
  }

  Future<Activity?> import(String csv, SetProgress setProgress) async {
    LineSplitter lineSplitter = const LineSplitter();
    _lines = lineSplitter.convert(csv);
    if (_lines.length < 20) {
      message = "Content too short";
      return null;
    }

    _linePointer = 0;
    final firstLine = _lines[0].split(",");
    if (firstLine.length > 1) {
      if (firstLine[0] != CSV_MAGIC) {
        message = "Cannot recognize migration CSV magic";
        return null;
      }

      if (!firstLine[1].isNumericOnly) {
        message = "CSV version number is not an integer";
        return null;
      }

      _migration = true;
      _version = int.parse(firstLine[1]);
    }

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

    final prefService = Get.find<BasePrefService>();

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
    var hrCalorieFactor = 1.0;
    var hrBasedCalories = false;
    var powerFactor = 1.0;
    var timeZone = await getTimeZone();
    var suuntoUploaded = false;
    var suuntoBlobUrl = "";
    var suuntoWorkoutUrl = "";
    var suuntoUploadIdentifier = "";
    var underArmourUploaded = false;
    var uaWorkoutId = 0;
    var trainingPeaksUploaded = false;
    var trainingPeaksAthleteId = 0;
    var trainingPeaksWorkoutId = 0;

    if (_migration) {
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

      _linePointer++;

      if (_version > 1) {
        final hrCalorieFactorLine = _lines[_linePointer].split(",");
        if (hrCalorieFactorLine[0].trim() != HR_CALORIE_FACTOR) {
          message = "Couldn't parse $HR_CALORIE_FACTOR";
          return null;
        }

        hrCalorieFactor = double.tryParse(hrCalorieFactorLine[1]) ?? 1.0;

        _linePointer++;

        final hrBasedCaloriesLine = _lines[_linePointer].split(",");
        if (hrBasedCaloriesLine[0].trim() != HR_BASED_CALORIES) {
          message = "Couldn't parse $HR_BASED_CALORIES";
          return null;
        }

        hrBasedCalories = hrBasedCaloriesLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final timeZoneLine = _lines[_linePointer].split(",");
        if (timeZoneLine[0].trim() != TIME_ZONE) {
          message = "Couldn't parse $TIME_ZONE";
          return null;
        }

        timeZone = timeZoneLine[1].trim();

        _linePointer++;

        final suuntoUploadedLine = _lines[_linePointer].split(",");
        if (suuntoUploadedLine[0].trim() != SUUNTO_UPLOADED) {
          message = "Couldn't parse $SUUNTO_UPLOADED";
          return null;
        }

        suuntoUploaded = suuntoUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final suuntoBlobUrlLine = _lines[_linePointer].split(",");
        if (suuntoBlobUrlLine[0].trim() != SUUNTO_BLOB_URL) {
          message = "Couldn't parse $SUUNTO_BLOB_URL";
          return null;
        }

        suuntoBlobUrl = suuntoBlobUrlLine[1].trim();

        _linePointer++;

        final suuntoWorkoutUrlLine = _lines[_linePointer].split(",");
        if (suuntoWorkoutUrlLine[0].trim() != SUUNTO_WORKOUT_URL) {
          message = "Couldn't parse $SUUNTO_WORKOUT_URL";
          return null;
        }

        suuntoWorkoutUrl = suuntoWorkoutUrlLine[1].trim();

        _linePointer++;

        final suuntoUploadIdLine = _lines[_linePointer].split(",");
        if (suuntoUploadIdLine[0].trim() != SUUNTO_UPLOAD_ID) {
          message = "Couldn't parse $SUUNTO_UPLOAD_ID";
          return null;
        }

        suuntoUploadIdentifier = suuntoUploadIdLine[1].trim();

        _linePointer++;

        final auUploadedLine = _lines[_linePointer].split(",");
        if (auUploadedLine[0].trim() != UNDER_ARMOUR_UPLOADED) {
          message = "Couldn't parse $UNDER_ARMOUR_UPLOADED";
          return null;
        }

        underArmourUploaded = auUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final auWorkoutIdLine = _lines[_linePointer].split(",");
        if (auWorkoutIdLine[0].trim() != UA_WORKOUT_ID) {
          message = "Couldn't parse $UA_WORKOUT_ID";
          return null;
        }

        uaWorkoutId = int.tryParse(auWorkoutIdLine[1]) ?? 0;

        _linePointer++;

        final tpUploadedLine = _lines[_linePointer].split(",");
        if (tpUploadedLine[0].trim() != TRAINING_PEAKS_UPLOADED) {
          message = "Couldn't parse $TRAINING_PEAKS_UPLOADED";
          return null;
        }

        trainingPeaksUploaded = tpUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final tpAthleteIdLine = _lines[_linePointer].split(",");
        if (tpAthleteIdLine[0].trim() != TRAINING_PEAKS_ATHLETE_ID) {
          message = "Couldn't parse $TRAINING_PEAKS_ATHLETE_ID";
          return null;
        }

        trainingPeaksAthleteId = int.tryParse(tpAthleteIdLine[1]) ?? 0;

        _linePointer++;

        final tpWorkoutIdLine = _lines[_linePointer].split(",");
        if (tpWorkoutIdLine[0].trim() != TRAINING_PEAKS_WORKOUT_ID) {
          message = "Couldn't parse $TRAINING_PEAKS_WORKOUT_ID";
          return null;
        }

        trainingPeaksWorkoutId = int.tryParse(tpWorkoutIdLine[1]) ?? 0;

        _linePointer++;
      }
    } else {
      DeviceDescriptor device = deviceMap[SCHWINN_AC_PERF_PLUS_FOURCC]!;
      device.refreshTuning(deviceId);
      deviceName = device.namePrefixes[0];
      fourCC = device.fourCC;
      sport = device.defaultSport;
      calorieFactor = device.calorieFactor;
      hrCalorieFactor = device.hrCalorieFactor;
      hrBasedCalories = prefService.get<bool>(USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG) ??
          USE_HEART_RATE_BASED_CALORIE_COUNTING_DEFAULT;
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
    if (_migration &&
        (rideDataHeader[4].trim() != TIME_STAMP ||
            rideDataHeader[5].trim() != ELAPSED ||
            rideDataHeader[6].trim() != SPEED ||
            rideDataHeader[7].trim() != CALORIES)) {
      message = "Unexpected detailed ride data format";
      return null;
    }

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
      hrCalorieFactor: hrCalorieFactor,
      hrBasedCalories: hrBasedCalories,
      powerFactor: powerFactor,
      timeZone: timeZone,
      suuntoUploaded: suuntoUploaded,
      suuntoBlobUrl: suuntoBlobUrl,
      suuntoWorkoutUrl: suuntoWorkoutUrl,
      suuntoUploadIdentifier: suuntoUploadIdentifier,
      underArmourUploaded: underArmourUploaded,
      uaWorkoutId: uaWorkoutId,
      trainingPeaksUploaded: trainingPeaksUploaded,
      trainingPeaksAthleteId: trainingPeaksAthleteId,
      trainingPeaksWorkoutId: trainingPeaksWorkoutId,
    );

    final extendTuning = prefService.get<bool>(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
    final database = Get.find<AppDatabase>();
    final id = await database.activityDao.insertActivity(activity);
    activity.id = id;

    final numRow = _lines.length - _linePointer;
    _linePointer++;

    if (_migration) {
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

      bool useHrBasedCalorieCounting = hrBasedCalories;
      int weight = prefService.get<int>(ATHLETE_BODY_WEIGHT_INT_TAG) ?? ATHLETE_BODY_WEIGHT_DEFAULT;
      int age = prefService.get<int>(ATHLETE_AGE_TAG) ?? ATHLETE_AGE_DEFAULT;
      bool isMale = (prefService.get<String>(ATHLETE_GENDER_TAG) ?? ATHLETE_GENDER_DEFAULT) ==
          ATHLETE_GENDER_MALE;
      int vo2Max = prefService.get<int>(ATHLETE_VO2MAX_TAG) ?? ATHLETE_VO2MAX_DEFAULT;
      useHrBasedCalorieCounting &= (weight > ATHLETE_BODY_WEIGHT_MIN && age > ATHLETE_AGE_MIN);

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
          double dEnergy = 0.0;
          if (useHrBasedCalorieCounting && row.heartRate > 0) {
            dEnergy = hrBasedCaloriesPerMinute(row.heartRate, weight, age, isMale, vo2Max) *
                milliSecondsPerRecord /
                (1000 * 60) *
                hrCalorieFactor;
          } else {
            dEnergy = power * milliSecondsPerRecord / 1000 * J_TO_KCAL * calorieFactor;
          }
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
