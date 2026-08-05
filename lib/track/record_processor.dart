import '../devices/gadgets/fitness_equipment.dart';
import '../persistence/record.dart';
import '../preferences/stage_mode.dart';
import '../preferences/time_display_mode.dart';
import '../utils/display.dart';
import '../utils/statistics_accumulator.dart';

/// The per-tick outcome of [RecordProcessor.process]: the widget applies
/// these values to its own state via `setState`.
class RecordTickResult {
  final double distance;
  final int lapCount;
  final int elapsed;
  final int markedTime;
  final int movingTime;
  final int? heartRate;

  const RecordTickResult({
    required this.distance,
    required this.lapCount,
    required this.elapsed,
    required this.markedTime,
    required this.movingTime,
    required this.heartRate,
  });
}

/// Pure, UI-independent computation of the per-record statistics, lap
/// counter, and elapsed/moving time logic that used to be inlined in
/// `RecordingState._recordHandlerFunction`.
///
/// This class never touches the database, Bluetooth devices, or chart/graph
/// data - it only derives values from the incoming [RecordWithSport] plus
/// whatever accumulator/timing state the caller already holds, so it is
/// trivially unit-testable and safe to call outside of a widget tree.
class RecordProcessor {
  /// Computes the distance, lap counter, elapsed/moving time, and merged
  /// heart rate for [record], and - when on-stage statistics are enabled -
  /// accumulates them into [workoutStats] and writes the resulting average
  /// or maximum display strings into [statistics] and [optionalStatistics]
  /// (mutated in place, mirroring the previous inline behavior).
  static RecordTickResult process({
    required RecordWithSport record,
    required WorkoutState workoutState,
    required bool displayLapCounter,
    required double trackLength,
    required int currentLapCount,
    required String timeDisplayMode,
    required int markedTime,
    required int? currentHeartRate,
    required bool onStage,
    required String onStageStatisticsType,
    required int onStageStatisticsAlternationDuration,
    required bool stationaryWorkout,
    required bool showResistanceLevel,
    required bool showInclination,
    required bool si,
    required String sport,
    required StatisticsAccumulator workoutStats,
    required List<String> statistics,
    required List<String> optionalStatistics,
    required int power0Index,
    required int speed0Index,
    required int cadence0Index,
    required int hr0Index,
    required int resistanceIndex,
    required int inclinationIndex,
  }) {
    final distance = record.distance ?? 0.0;
    final lapCount = displayLapCounter && trackLength > 0
        ? (distance / trackLength).floor()
        : currentLapCount;

    var elapsed = record.elapsed ?? 0;
    var newMarkedTime = markedTime;
    if (timeDisplayMode == timeDisplayModeHIITMoving) {
      if (workoutState == WorkoutState.justPaused || workoutState == WorkoutState.startedMoving) {
        newMarkedTime = elapsed;
      }

      if (workoutState != WorkoutState.waitingForFirstMove) {
        elapsed -= newMarkedTime;
      }
    }

    final movingTime = record.movingTime.round();

    var heartRate = currentHeartRate;
    if (record.heartRate != null &&
        (record.heartRate! > 0 || heartRate == null || heartRate == 0)) {
      heartRate = record.heartRate;
    }

    if (onStage && onStageStatisticsType != onStageStatisticsTypeNone) {
      workoutStats.processRecord(record);

      if (onStageStatisticsType == onStageStatisticsTypeAverage ||
          onStageStatisticsType == onStageStatisticsTypeAlternating &&
              elapsed % (onStageStatisticsAlternationDuration * 2) <
                  onStageStatisticsAlternationDuration) {
        if (!stationaryWorkout) {
          statistics[power0Index] = workoutStats.avgPower.toInt().toString();
          statistics[speed0Index] = speedOrPaceString(
            workoutStats.avgSpeed,
            si,
            sport,
            limitSlowSpeed: true,
          );
        }

        statistics[cadence0Index] = workoutStats.avgCadence.toInt().toString();
        statistics[hr0Index] = workoutStats.avgHeartRate.toInt().toString();

        if (showResistanceLevel) {
          optionalStatistics[resistanceIndex] = workoutStats.avgResistance.toInt().toString();
        }
        if (showInclination) {
          optionalStatistics[inclinationIndex] = workoutStats.avgInclination.toStringAsFixed(1);
        }
      } else {
        if (!stationaryWorkout) {
          statistics[power0Index] = workoutStats.maxPowerDisplay.toString();
          statistics[speed0Index] = speedOrPaceString(
            workoutStats.maxSpeedDisplay,
            si,
            sport,
            limitSlowSpeed: true,
          );
        }

        statistics[cadence0Index] = workoutStats.maxCadenceDisplay.toString();
        statistics[hr0Index] = workoutStats.maxHeartRateDisplay.toString();

        if (showResistanceLevel) {
          optionalStatistics[resistanceIndex] = workoutStats.maxResistanceDisplay.toString();
        }
        if (showInclination) {
          optionalStatistics[inclinationIndex] = workoutStats.maxInclinationDisplay.toStringAsFixed(
            1,
          );
        }
      }
    }

    return RecordTickResult(
      distance: distance,
      lapCount: lapCount,
      elapsed: elapsed,
      markedTime: newMarkedTime,
      movingTime: movingTime,
      heartRate: heartRate,
    );
  }
}
