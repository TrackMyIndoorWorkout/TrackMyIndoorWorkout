import 'dart:convert';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_descriptors/schwinn_ac_performance_plus.dart';
import '../devices/device_map.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/database.dart';
import '../preferences/athlete_age.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/athlete_gender.dart';
import '../preferences/athlete_vo2max.dart';
import '../preferences/extend_tuning.dart';
import '../preferences/heart_rate_gap_workaround.dart';
import '../preferences/heart_rate_limiting.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
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
          heartRateLimitingMethod != heartRateLimitingNoLimit) {
        if (heartRateLimitingMethod == heartRateLimitingCapAtLimit) {
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
  static const maxProgressSteps = 400;
  static const energy2speed = 5.28768241564455E-05;
  static const timeResolutionFactor = 2;
  static const epsilon = 0.001;
  static const maxIterations = 100;
  static const driveTrainLoss = 0; // %
  static const gConst = 9.8067;
  static const bikerWeight = 81; // kg
  static const bikeWeight = 9; // kg
  static const rollingResistanceCoefficient = 0.005;
  static const dragCoefficient = 0.63;
  // Backup: 5.4788
  static const frontalArea = 4 * ftToM * ftToM; // ft * ft_2_m^2
  static const airDensity = 0.076537 * lbToKg / (ftToM * ftToM * ftToM);

  DateTime? start;
  String message = "";

  List<String> _lines = [];
  int _linePointer = 0;
  bool _migration = false;
  int _version = csvVersion;
  final Map<int, double> _velocityForPowerDict = <int, double>{};

  CSVImporter(this.start);

  bool _findLine(String lead) {
    while (_linePointer < _lines.length && !_lines[_linePointer].startsWith(lead)) {
      _linePointer++;
    }

    return _linePointer <= _lines.length;
  }

  double powerForVelocity(velocity) {
    const fRolling = gConst * (bikerWeight + bikeWeight) * rollingResistanceCoefficient;

    final fDrag = 0.5 * frontalArea * dragCoefficient * airDensity * velocity * velocity;

    final totalForce = fRolling + fDrag;
    final wheelPower = totalForce * velocity;
    const driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
    final legPower = wheelPower / driveTrainFraction;
    return legPower;
  }

  double velocityForPower(int power) {
    if (_velocityForPowerDict.containsKey(power)) {
      return _velocityForPowerDict[power] ?? 0.0;
    }

    var lowerVelocity = 0.0;
    var upperVelocity = 2000.0;
    var middleVelocity = power * energy2speed * 1000;
    var middlePower = powerForVelocity(middleVelocity);

    var i = 0;
    do {
      if ((middlePower - power).abs() < epsilon) break;

      if (middlePower > power) {
        upperVelocity = middleVelocity;
      } else {
        lowerVelocity = middleVelocity;
      }

      middleVelocity = (upperVelocity + lowerVelocity) / 2.0;
      middlePower = powerForVelocity(middleVelocity);
    } while (i++ < maxIterations);

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
      if (firstLine[0] != csvMagic) {
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

    if (!_findLine(rideSummaryTag)) {
      message = "Cannot locate $rideSummaryTag";
      return null;
    }

    // Total Time
    if (!_findLine(totalTimeTag)) {
      message = "Couldn't find $totalTimeTag";
      return null;
    }

    final timeLine = _lines[_linePointer].split(",");
    final timeValue = double.tryParse(timeLine[1]);
    if (timeValue == null) {
      message = "Couldn't parse $totalTimeTag";
      return null;
    }

    int totalElapsed = timeValue.round(); // Seconds by default
    if (timeLine[2].trim() == minutesUnitTag) {
      totalElapsed = (timeValue * 60).round();
    } else if (timeLine[2].trim() == hoursUnitTag) {
      totalElapsed = (timeValue * 3600).round();
    }

    // Total Distance
    if (!_findLine(totalDistanceTag)) {
      message = "Couldn't find $totalDistanceTag";
      return null;
    }

    final distanceLine = _lines[_linePointer].split(",");
    final distanceValue = double.tryParse(distanceLine[1]);
    if (distanceValue == null) {
      message = "Couldn't parse $totalDistanceTag";
      return null;
    }

    double totalDistance = 0.0;
    if (distanceLine[2].trim() == mileUnitTag) {
      totalDistance = distanceValue * 1000 * mi2km;
    } else if (distanceLine[2].trim() == kmUnitTag) {
      totalDistance = distanceValue * 1000;
    } else if (distanceLine[2].trim() == meterUnitTag) {
      totalDistance = distanceValue;
    }

    final prefService = Get.find<BasePrefService>();
    final database = Get.find<AppDatabase>();

    var deviceName = "";
    var deviceId = mPowerImportDeviceId;
    var hrmId = "";
    var startTime = 0;
    var endTime = 0;
    var calories = 0;
    var uploaded = false;
    var stravaId = 0;
    var fourCC = schwinnACPerfPlusFourCC;
    var sport = ActivityType.ride;
    var calorieFactor = 1.0;
    var hrCalorieFactor = 1.0;
    var hrmCalorieFactor = 1.0;
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
      if (deviceNameLine[0].trim() != deviceName) {
        message = "Couldn't parse $deviceName";
        return null;
      }

      deviceName = deviceNameLine[1].trim();

      _linePointer++;

      final deviceIdLine = _lines[_linePointer].split(",");
      if (deviceIdLine[0].trim() != deviceId) {
        message = "Couldn't parse $deviceId";
        return null;
      }

      deviceId = deviceIdLine[1].trim();

      _linePointer++;

      final startTimeLine = _lines[_linePointer].split(",");
      if (startTimeLine[0].trim() != startTimeTag) {
        message = "Couldn't parse $startTimeTag";
        return null;
      }

      startTime = int.tryParse(startTimeLine[1]) ?? 0;
      if (startTime == 0) {
        message = "Couldn't parse $startTimeTag";
        return null;
      }

      start = DateTime.fromMillisecondsSinceEpoch(startTime);

      _linePointer++;

      final endTimeLine = _lines[_linePointer].split(",");
      if (endTimeLine[0].trim() != endTimeTag) {
        message = "Couldn't parse $endTimeTag";
        return null;
      }

      endTime = int.tryParse(endTimeLine[1]) ?? 0;
      if (endTime == 0) {
        message = "Couldn't parse $endTimeTag";
        return null;
      }

      _linePointer++;

      final calorieLine = _lines[_linePointer].split(",");
      if (calorieLine[0].trim() != caloriesTag) {
        message = "Couldn't parse $caloriesTag";
        return null;
      }

      calories = int.tryParse(calorieLine[1]) ?? 0;

      _linePointer++;

      final uploadedLine = _lines[_linePointer].split(",");
      if (uploadedLine[0].trim() != uploadedTag) {
        message = "Couldn't parse $uploadedTag";
        return null;
      }

      uploaded = uploadedLine[1].trim().toLowerCase() == "true";

      _linePointer++;

      final stravaIdLine = _lines[_linePointer].split(",");
      if (stravaIdLine[0].trim() != stravaIdTag) {
        message = "Couldn't parse $stravaIdTag";
        return null;
      }

      stravaId = int.tryParse(stravaIdLine[1]) ?? 0;

      _linePointer++;

      final fourCcLine = _lines[_linePointer].split(",");
      if (fourCcLine[0].trim() != fourCCTag) {
        message = "Couldn't parse $fourCCTag";
        return null;
      }

      fourCC = fourCcLine[1].trim();

      _linePointer++;

      final sportLine = _lines[_linePointer].split(",");
      if (sportLine[0].trim() != sportTag) {
        message = "Couldn't parse $sportTag";
        return null;
      }

      sport = sportLine[1].trim();

      _linePointer++;

      final powerFactorLine = _lines[_linePointer].split(",");
      if (powerFactorLine[0].trim() != powerFactorTag) {
        message = "Couldn't parse $powerFactorTag";
        return null;
      }

      powerFactor = double.tryParse(powerFactorLine[1]) ?? 1.0;

      _linePointer++;

      final calorieFactorLine = _lines[_linePointer].split(",");
      if (calorieFactorLine[0].trim() != calorieFactorTag) {
        message = "Couldn't parse $calorieFactorTag";
        return null;
      }

      calorieFactor = double.tryParse(calorieFactorLine[1]) ?? 1.0;

      _linePointer++;

      if (_version > 1) {
        final hrCalorieFactorLine = _lines[_linePointer].split(",");
        if (hrCalorieFactorLine[0].trim() != hrCalorieFactorTag) {
          message = "Couldn't parse $hrCalorieFactorTag";
          return null;
        }

        hrCalorieFactor = double.tryParse(hrCalorieFactorLine[1]) ?? 1.0;

        _linePointer++;

        final hrmCalorieFactorLine = _lines[_linePointer].split(",");
        if (hrmCalorieFactorLine[0].trim() != hrmCalorieFactorTag) {
          message = "Couldn't parse $hrmCalorieFactorTag";
          return null;
        }

        hrmCalorieFactor = double.tryParse(hrmCalorieFactorLine[1]) ?? 1.0;

        _linePointer++;

        final hrmIdLine = _lines[_linePointer].split(",");
        if (hrmIdLine[0].trim() != hrmIdTag) {
          message = "Couldn't parse $hrmIdTag";
          return null;
        }

        hrmId = hrmIdLine[1].trim();

        _linePointer++;

        final hrBasedCaloriesLine = _lines[_linePointer].split(",");
        if (hrBasedCaloriesLine[0].trim() != hrBasedCaloriesTag) {
          message = "Couldn't parse $hrBasedCaloriesTag";
          return null;
        }

        hrBasedCalories = hrBasedCaloriesLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final timeZoneLine = _lines[_linePointer].split(",");
        if (timeZoneLine[0].trim() != timeZoneTag) {
          message = "Couldn't parse $timeZoneTag";
          return null;
        }

        timeZone = timeZoneLine[1].trim();

        _linePointer++;

        final suuntoUploadedLine = _lines[_linePointer].split(",");
        if (suuntoUploadedLine[0].trim() != suuntoUploadedTag) {
          message = "Couldn't parse $suuntoUploadedTag";
          return null;
        }

        suuntoUploaded = suuntoUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final suuntoBlobUrlLine = _lines[_linePointer].split(",");
        if (suuntoBlobUrlLine[0].trim() != suuntoBlobUrlTag) {
          message = "Couldn't parse $suuntoBlobUrlTag";
          return null;
        }

        suuntoBlobUrl = suuntoBlobUrlLine[1].trim();

        _linePointer++;

        final suuntoWorkoutUrlLine = _lines[_linePointer].split(",");
        if (suuntoWorkoutUrlLine[0].trim() != suuntoWorkoutUrlTag) {
          message = "Couldn't parse $suuntoWorkoutUrlTag";
          return null;
        }

        suuntoWorkoutUrl = suuntoWorkoutUrlLine[1].trim();

        _linePointer++;

        final suuntoUploadIdLine = _lines[_linePointer].split(",");
        if (suuntoUploadIdLine[0].trim() != suuntoUploadIdTag) {
          message = "Couldn't parse $suuntoUploadIdTag";
          return null;
        }

        suuntoUploadIdentifier = suuntoUploadIdLine[1].trim();

        _linePointer++;

        final auUploadedLine = _lines[_linePointer].split(",");
        if (auUploadedLine[0].trim() != underArmourUploadedTag) {
          message = "Couldn't parse $underArmourUploadedTag";
          return null;
        }

        underArmourUploaded = auUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final auWorkoutIdLine = _lines[_linePointer].split(",");
        if (auWorkoutIdLine[0].trim() != uaWorkoutIdTag) {
          message = "Couldn't parse $uaWorkoutIdTag";
          return null;
        }

        uaWorkoutId = int.tryParse(auWorkoutIdLine[1]) ?? 0;

        _linePointer++;

        final tpUploadedLine = _lines[_linePointer].split(",");
        if (tpUploadedLine[0].trim() != trainingPeaksUploadedTag) {
          message = "Couldn't parse $trainingPeaksUploadedTag";
          return null;
        }

        trainingPeaksUploaded = tpUploadedLine[1].trim().toLowerCase() == "true";

        _linePointer++;

        final tpAthleteIdLine = _lines[_linePointer].split(",");
        if (tpAthleteIdLine[0].trim() != trainingPeaksAthleteIdTag) {
          message = "Couldn't parse $trainingPeaksAthleteIdTag";
          return null;
        }

        trainingPeaksAthleteId = int.tryParse(tpAthleteIdLine[1]) ?? 0;

        _linePointer++;

        final tpWorkoutIdLine = _lines[_linePointer].split(",");
        if (tpWorkoutIdLine[0].trim() != trainingPeaksWorkoutIdTag) {
          message = "Couldn't parse $trainingPeaksWorkoutIdTag";
          return null;
        }

        trainingPeaksWorkoutId = int.tryParse(tpWorkoutIdLine[1]) ?? 0;

        _linePointer++;
      }
    } else {
      DeviceDescriptor device = deviceMap[schwinnACPerfPlusFourCC]!;
      final factors = await database.getFactors(deviceId);
      deviceName = device.namePrefixes[0];
      fourCC = device.fourCC;
      sport = device.defaultSport;
      calorieFactor = factors.item2 *
          (device.canMeasureCalories ? 1.0 : DeviceDescriptor.powerCalorieFactorDefault);
      hrCalorieFactor = factors.item3;
      hrBasedCalories = prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
          useHeartRateBasedCalorieCountingDefault;
      powerFactor = factors.item1;
      startTime = start!.millisecondsSinceEpoch;
      endTime = start!.add(Duration(seconds: totalElapsed)).millisecondsSinceEpoch;
    }

    if (!_findLine(rideDataTag)) {
      message = "Cannot locate $rideDataTag";
      return null;
    }

    _linePointer++;

    final rideDataHeader = _lines[_linePointer].split(",");
    if (rideDataHeader[0].trim() != powerHeaderTag ||
        rideDataHeader[1].trim() != rpmHeaderTag ||
        rideDataHeader[2].trim() != hrHeaderTag ||
        rideDataHeader[3].trim() != distanceHeaderTag) {
      message = "Unexpected detailed ride data format";
      return null;
    }
    if (_migration &&
        (rideDataHeader[4].trim() != timeStampTag ||
            rideDataHeader[5].trim() != elapsedTag ||
            rideDataHeader[6].trim() != speedTag ||
            rideDataHeader[7].trim() != caloriesTag)) {
      message = "Unexpected detailed ride data format";
      return null;
    }

    var activity = Activity(
      deviceName: deviceName,
      deviceId: deviceId,
      hrmId: hrmId,
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
      hrmCalorieFactor: hrmCalorieFactor,
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

    final extendTuning = prefService.get<bool>(extendTuningTag) ?? extendTuningDefault;
    final id = await database.activityDao.insertActivity(activity);
    activity.id = id;

    final numRow = _lines.length - _linePointer;
    _linePointer++;

    if (_migration) {
      int progressSteps = numRow ~/ maxProgressSteps;
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
      int recordsPerRow = secondsPerRowInt * timeResolutionFactor;
      double milliSecondsPerRecord = secondsPerRow * 1000 / recordsPerRow;
      int milliSecondsPerRecordInt = milliSecondsPerRecord.round();

      int recordCount = numRow * recordsPerRow;
      int progressSteps = recordCount ~/ maxProgressSteps;
      int progressCounter = 0;
      int recordCounter = 0;
      double energy = 0;
      double distance = 0;
      double elapsed = 0;
      WorkoutRow? nextRow;
      int lastHeartRate = 0;
      int timeStamp = start!.millisecondsSinceEpoch;
      String heartRateGapWorkaroundSetting =
          prefService.get<String>(heartRateGapWorkaroundTag) ?? heartRateGapWorkaroundDefault;
      bool heartRateGapWorkaround =
          heartRateGapWorkaroundSetting == dataGapWorkaroundLastPositiveValue;
      int heartRateUpperLimit =
          prefService.get<int>(heartRateUpperLimitIntTag) ?? heartRateUpperLimitDefault;
      String heartRateLimitingMethod =
          prefService.get<String>(heartRateLimitingMethodTag) ?? heartRateLimitingMethodDefault;

      bool useHrBasedCalorieCounting = hrBasedCalories;
      int weight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
      int age = prefService.get<int>(athleteAgeTag) ?? athleteAgeDefault;
      bool isMale =
          (prefService.get<String>(athleteGenderTag) ?? athleteGenderDefault) == athleteGenderMale;
      int vo2Max = prefService.get<int>(athleteVO2MaxTag) ?? athleteVO2MaxDefault;
      useHrBasedCalorieCounting &= (weight > athleteBodyWeightMin && age > athleteAgeMin);

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
            dEnergy = power *
                milliSecondsPerRecord /
                1000 *
                jToKCal *
                calorieFactor *
                SchwinnACPerformancePlus.extraCalorieFactor;
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
