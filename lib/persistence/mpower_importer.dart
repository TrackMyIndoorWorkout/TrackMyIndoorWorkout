import 'dart:convert';

import '../devices/devices.dart';
import '../devices/device_descriptor.dart';
import '../devices/gatt_standard_device_descriptor.dart';
import '../ui/import_form.dart';
import 'models/activity.dart';
import 'models/record.dart';
import 'database.dart';
import 'preferences.dart';

class WorkoutRow {
  int power;
  int rpm;
  int hr;
  double distance;

  WorkoutRow({this.power, this.rpm, this.hr, this.distance, String rowString}) {
    if (rowString != null) {
      final values = rowString.split(",");
      this.power = int.tryParse(values[0]);
      this.rpm = int.tryParse(values[1]);
      this.hr = int.tryParse(values[2]);
      this.distance = double.tryParse(values[3]);
    }
  }
}

class MPowerEchelon2Importer {
  static const ENERGY_2_SPEED_FACTOR = 1.0;
  static const ENERGY_2_SPEED = 5.28768241564455E-05 * ENERGY_2_SPEED_FACTOR;

  final DateTime start;
  String message;

  List<String> _lines;
  int _linePointer;

  MPowerEchelon2Importer({this.start});

  bool _findLine(String lead) {
    while (_linePointer < _lines.length &&
        !_lines[_linePointer].startsWith(lead)) {
      _linePointer++;
    }
    return _linePointer <= _lines.length;
  }

  Future<Activity> import(String csv, SetProgress setProgress) async {
    LineSplitter lineSplitter = new LineSplitter();
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

    GattStandardDeviceDescriptor device = deviceMap["SAP+"];
    var activity = Activity(
      deviceName: device.namePrefix,
      deviceId: "",
      start: start.millisecondsSinceEpoch,
      end: start.add(Duration(seconds: totalElapsed)).millisecondsSinceEpoch,
      distance: totalDistance,
      elapsed: totalElapsed,
      calories: 0,
      startDateTime: start,
      fourCC: device.fourCC,
    );

    AppDatabase db = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3]).build();
    final id = await db?.activityDao?.insertActivity(activity);
    activity.id = id;

    final numRow = _lines.length - _linePointer;
    _linePointer++;
    double secondsPerRow = totalElapsed / numRow;
    int secondsPerRowInt = secondsPerRow.round();
    double milliSecondsPerRecord = secondsPerRow / secondsPerRowInt * 1000;
    int milliSecondsPerRecordInt = milliSecondsPerRecord.round();

    int recordCount = numRow * secondsPerRowInt;
    int progress = 0;
    int recordCounter = 0;
    double energy = 0;
    double distance = 0;
    double elapsed = 0;
    WorkoutRow nextRow;
    int timeStamp = start.millisecondsSinceEpoch;
    while (_linePointer < _lines.length) {
      WorkoutRow row = nextRow;
      if (row == null) {
        row = WorkoutRow(rowString: _lines[_linePointer]);
      }
      if (_linePointer + 1 >= _lines.length) {
        nextRow = WorkoutRow(power: 0, rpm: 0, hr: 0, distance: 0.0);
      } else {
        nextRow = WorkoutRow(rowString: _lines[_linePointer + 1]);
      }

      double dPower = (nextRow.power - row.power) / secondsPerRowInt;
      double dCadence = (nextRow.rpm - row.rpm) / secondsPerRowInt;
      double dHr = (nextRow.hr - row.hr) / secondsPerRowInt;
      double power = row.power.toDouble();
      double rpm = row.rpm.toDouble();
      double hr = row.hr.toDouble();

      for (int i = 0; i < secondsPerRowInt; i++) {
        final dEnergy = power * milliSecondsPerRecord;
        final dDistance = dEnergy * ENERGY_2_SPEED;
        final speed = power * ENERGY_2_SPEED * 1000 * DeviceDescriptor.MS2KMH;

        final record = Record(
          activityId: activity.id,
          timeStamp: timeStamp,
          distance: distance,
          elapsed: elapsed ~/ 1000,
          calories: energy.round(),
          power: power.round(),
          speed: speed,
          cadence: rpm.round(),
          heartRate: hr.round(),
          elapsedMillis: elapsed.round(),
        );

        distance += dDistance;
        energy +=
            dEnergy * DeviceDescriptor.J2KCAL / 1000 * device.calorieFactor;
        await db?.recordDao?.insertRecord(record);

        timeStamp += milliSecondsPerRecordInt;
        elapsed += milliSecondsPerRecord;
        power += dPower;
        rpm += dCadence;
        hr += dHr;
        recordCounter++;
        final newProgress = recordCounter * 100 ~/ recordCount;
        if (newProgress > progress) {
          setProgress(recordCounter / recordCount);
          progress = newProgress;
        }
      }
      _linePointer++;
    }

    activity.distance = distance;
    activity.calories = energy.round();
    await db?.activityDao?.updateActivity(activity);

    return activity;
  }
}
