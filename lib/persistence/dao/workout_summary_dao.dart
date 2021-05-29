import 'package:floor/floor.dart';
import '../models/workout_summary.dart';

@dao
abstract class WorkoutSummaryDao {
  @Query('SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME ORDER BY speed DESC')
  Future<List<WorkoutSummary>> findAllWorkoutSummaries();

  @Query('SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME WHERE id = :id')
  Stream<WorkoutSummary> findWorkoutSummaryById(int id);

  @Query('SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME WHERE device_id = :deviceId ORDER BY speed')
  Future<List<WorkoutSummary>> findAllWorkoutSummariesByDevice(String deviceId);

  @Query(
      'SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME WHERE device_id = :deviceId ORDER BY speed DESC LIMIT :limit OFFSET :offset')
  Future<List<WorkoutSummary>> findWorkoutSummaryByDevice(String deviceId, int limit, int offset);

  @Query('SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME WHERE sport = :sport ORDER BY speed')
  Future<List<WorkoutSummary>> findAllWorkoutSummariesBySport(String sport);

  @Query(
      'SELECT * FROM $WORKOUT_SUMMARIES_TABLE_NAME WHERE sport = :sport ORDER BY speed DESC LIMIT :limit OFFSET :offset')
  Future<List<WorkoutSummary>> findWorkoutSummaryBySport(String sport, int limit, int offset);

  @insert
  Future<int> insertWorkoutSummary(WorkoutSummary workoutSummary);

  @update
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary);

  @delete
  Future<int> deleteWorkoutSummary(WorkoutSummary workoutSummary);
}
