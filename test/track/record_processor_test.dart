import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/preferences/stage_mode.dart';
import 'package:track_my_indoor_exercise/preferences/time_display_mode.dart';
import 'package:track_my_indoor_exercise/track/record_processor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';

RecordTickResult _process({
  required RecordWithSport record,
  WorkoutState workoutState = WorkoutState.moving,
  bool displayLapCounter = false,
  double trackLength = 250.0,
  int currentLapCount = 0,
  String timeDisplayMode = timeDisplayModeElapsed,
  int markedTime = 0,
  int? currentHeartRate,
  bool onStage = false,
  String onStageStatisticsType = onStageStatisticsTypeNone,
  int onStageStatisticsAlternationDuration = 10,
  bool stationaryWorkout = false,
  bool showResistanceLevel = false,
  bool showInclination = false,
  bool si = true,
  String sport = ActivityType.ride,
  StatisticsAccumulator? workoutStats,
  List<String>? statistics,
  List<String>? optionalStatistics,
}) {
  return RecordProcessor.process(
    record: record,
    workoutState: workoutState,
    displayLapCounter: displayLapCounter,
    trackLength: trackLength,
    currentLapCount: currentLapCount,
    timeDisplayMode: timeDisplayMode,
    markedTime: markedTime,
    currentHeartRate: currentHeartRate,
    onStage: onStage,
    onStageStatisticsType: onStageStatisticsType,
    onStageStatisticsAlternationDuration: onStageStatisticsAlternationDuration,
    stationaryWorkout: stationaryWorkout,
    showResistanceLevel: showResistanceLevel,
    showInclination: showInclination,
    si: si,
    sport: sport,
    workoutStats: workoutStats ?? StatisticsAccumulator(si: si, sport: sport),
    statistics: statistics ?? List<String>.filled(6, emptyMeasurement, growable: true),
    optionalStatistics:
        optionalStatistics ?? List<String>.filled(3, emptyMeasurement, growable: true),
    power0Index: 1,
    speed0Index: 2,
    cadence0Index: 3,
    hr0Index: 4,
    resistanceIndex: 0,
    inclinationIndex: 2,
  );
}

void main() {
  group('RecordProcessor distance and lap counter', () {
    test('passes distance through unchanged', () {
      final record = RecordWithSport(distance: 123.4, sport: ActivityType.ride);
      final result = _process(record: record);
      expect(result.distance, 123.4);
    });

    test('defaults distance to 0.0 when record has none', () {
      final record = RecordWithSport(sport: ActivityType.ride);
      final result = _process(record: record);
      expect(result.distance, 0.0);
    });

    test('computes lap count from distance / track length when enabled', () {
      final record = RecordWithSport(distance: 625.0, sport: ActivityType.ride);
      final result = _process(record: record, displayLapCounter: true, trackLength: 250.0);
      expect(result.lapCount, 2);
    });

    test('leaves lap count unchanged when the counter is disabled', () {
      final record = RecordWithSport(distance: 625.0, sport: ActivityType.ride);
      final result = _process(
        record: record,
        displayLapCounter: false,
        trackLength: 250.0,
        currentLapCount: 7,
      );
      expect(result.lapCount, 7);
    });

    test('leaves lap count unchanged when the counter is enabled but track length is 0', () {
      final record = RecordWithSport(distance: 625.0, sport: ActivityType.ride);
      final result = _process(
        record: record,
        displayLapCounter: true,
        trackLength: 0,
        currentLapCount: 7,
      );
      expect(result.lapCount, 7);
    });
  });

  group('RecordProcessor elapsed/moving time', () {
    test('passes elapsed through unmodified outside HIIT moving-time mode', () {
      final record = RecordWithSport(elapsed: 100, sport: ActivityType.ride);
      final result = _process(
        record: record,
        timeDisplayMode: timeDisplayModeElapsed,
        workoutState: WorkoutState.justPaused,
        markedTime: 5,
      );
      expect(result.elapsed, 100);
      expect(result.markedTime, 5);
    });

    test('marks the reference time on pause/resume in HIIT moving-time mode', () {
      final record = RecordWithSport(elapsed: 100, sport: ActivityType.ride);
      final result = _process(
        record: record,
        timeDisplayMode: timeDisplayModeHIITMoving,
        workoutState: WorkoutState.startedMoving,
        markedTime: 40,
      );
      // markedTime is refreshed to the current elapsed, then subtracted right away.
      expect(result.markedTime, 100);
      expect(result.elapsed, 0);
    });

    test('subtracts the previously marked time while moving in HIIT mode', () {
      final record = RecordWithSport(elapsed: 130, sport: ActivityType.ride);
      final result = _process(
        record: record,
        timeDisplayMode: timeDisplayModeHIITMoving,
        workoutState: WorkoutState.moving,
        markedTime: 30,
      );
      expect(result.markedTime, 30);
      expect(result.elapsed, 100);
    });

    test('does not subtract marked time while waiting for the first move', () {
      final record = RecordWithSport(elapsed: 5, sport: ActivityType.ride);
      final result = _process(
        record: record,
        timeDisplayMode: timeDisplayModeHIITMoving,
        workoutState: WorkoutState.waitingForFirstMove,
        markedTime: 0,
      );
      expect(result.elapsed, 5);
      expect(result.markedTime, 0);
    });

    test('rounds the moving time from the record', () {
      final record = RecordWithSport(sport: ActivityType.ride);
      record.movingTime = 1234;
      final result = _process(record: record);
      expect(result.movingTime, 1234);
    });
  });

  group('RecordProcessor heart rate merge', () {
    test('adopts the incoming heart rate when there is no current value', () {
      final record = RecordWithSport(heartRate: 88, sport: ActivityType.ride);
      final result = _process(record: record, currentHeartRate: null);
      expect(result.heartRate, 88);
    });

    test('adopts the incoming heart rate when the current value is zero', () {
      final record = RecordWithSport(heartRate: 77, sport: ActivityType.ride);
      final result = _process(record: record, currentHeartRate: 0);
      expect(result.heartRate, 77);
    });

    test('adopts a fresh positive heart rate over an existing positive one', () {
      final record = RecordWithSport(heartRate: 150, sport: ActivityType.ride);
      final result = _process(record: record, currentHeartRate: 120);
      expect(result.heartRate, 150);
    });

    test('keeps the existing heart rate when the incoming reading is zero', () {
      final record = RecordWithSport(heartRate: 0, sport: ActivityType.ride);
      final result = _process(record: record, currentHeartRate: 120);
      expect(result.heartRate, 120);
    });

    test('keeps the existing heart rate when the incoming reading is missing', () {
      final record = RecordWithSport(sport: ActivityType.ride);
      final result = _process(record: record, currentHeartRate: 120);
      expect(result.heartRate, 120);
    });
  });

  group('RecordProcessor on-stage statistics', () {
    test('leaves statistics untouched when on-stage display is off', () {
      final record = RecordWithSport(power: 200, speed: 30.0, sport: ActivityType.ride);
      final statistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: false,
        onStageStatisticsType: onStageStatisticsTypeAverage,
        statistics: statistics,
      );
      expect(statistics.every((value) => value == emptyMeasurement), true);
    });

    test('leaves statistics untouched when the statistics type is none', () {
      final record = RecordWithSport(power: 200, speed: 30.0, sport: ActivityType.ride);
      final statistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeNone,
        statistics: statistics,
      );
      expect(statistics.every((value) => value == emptyMeasurement), true);
    });

    test('writes average power/speed/cadence/hr in average mode', () {
      final record = RecordWithSport(
        power: 200,
        speed: 30.0,
        cadence: 90,
        heartRate: 140,
        sport: ActivityType.ride,
      );
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgPower: true,
        calculateAvgSpeed: true,
        calculateAvgCadence: true,
        calculateAvgHeartRate: true,
      );
      final statistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAverage,
        workoutStats: workoutStats,
        statistics: statistics,
      );
      expect(statistics[1], '200');
      expect(statistics[3], '90');
      expect(statistics[4], '140');
    });

    test('writes maximum values in maximum mode', () {
      final record = RecordWithSport(
        power: 200,
        cadence: 90,
        heartRate: 140,
        sport: ActivityType.ride,
      );
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateMaxPower: true,
        calculateMaxCadence: true,
        calculateMaxHeartRate: true,
      );
      final statistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeMaximum,
        workoutStats: workoutStats,
        statistics: statistics,
      );
      expect(statistics[1], '200');
      expect(statistics[3], '90');
      expect(statistics[4], '140');
    });

    test('skips power/speed statistics for a stationary workout', () {
      final record = RecordWithSport(
        power: 200,
        speed: 30.0,
        cadence: 90,
        heartRate: 140,
        sport: ActivityType.ride,
      );
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgPower: true,
        calculateAvgSpeed: true,
        calculateAvgCadence: true,
        calculateAvgHeartRate: true,
      );
      final statistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAverage,
        stationaryWorkout: true,
        workoutStats: workoutStats,
        statistics: statistics,
      );
      expect(statistics[1], emptyMeasurement);
      expect(statistics[2], emptyMeasurement);
      expect(statistics[3], '90');
      expect(statistics[4], '140');
    });

    test('fills in optional resistance/inclination statistics when requested', () {
      final record = RecordWithSport(resistance: 42, inclination: 3.4, sport: ActivityType.ride);
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgResistance: true,
        calculateAvgInclination: true,
      );
      final optionalStatistics = List<String>.filled(3, emptyMeasurement, growable: true);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAverage,
        showResistanceLevel: true,
        showInclination: true,
        workoutStats: workoutStats,
        optionalStatistics: optionalStatistics,
      );
      expect(optionalStatistics[0], '42');
      expect(optionalStatistics[2], '3.4');
    });

    test('alternates between average and maximum based on elapsed time', () {
      final avgRecord = RecordWithSport(elapsed: 5, power: 200, sport: ActivityType.ride);
      final maxRecord = RecordWithSport(elapsed: 15, power: 200, sport: ActivityType.ride);
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgPower: true,
        calculateMaxPower: true,
      );

      final avgStatistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: avgRecord,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAlternating,
        onStageStatisticsAlternationDuration: 10,
        workoutStats: workoutStats,
        statistics: avgStatistics,
      );
      expect(avgStatistics[1], workoutStats.avgPower.toInt().toString());

      final maxStatistics = List<String>.filled(6, emptyMeasurement, growable: true);
      _process(
        record: maxRecord,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAlternating,
        onStageStatisticsAlternationDuration: 10,
        workoutStats: workoutStats,
        statistics: maxStatistics,
      );
      expect(maxStatistics[1], workoutStats.maxPowerDisplay.toString());
    });

    test('accumulates the record into the shared workout stats accumulator', () {
      final record = RecordWithSport(power: 200, sport: ActivityType.ride);
      final workoutStats = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgPower: true,
      );
      expect(workoutStats.powerCount, 0);
      _process(
        record: record,
        onStage: true,
        onStageStatisticsType: onStageStatisticsTypeAverage,
        workoutStats: workoutStats,
      );
      expect(workoutStats.powerCount, 1);
      expect(workoutStats.powerSum, 200);
    });
  });
}
