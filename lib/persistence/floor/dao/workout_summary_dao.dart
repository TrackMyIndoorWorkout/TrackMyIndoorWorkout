import 'package:floor/floor.dart';
import '../models/workout_summary.dart';

@dao
abstract class WorkoutSummaryDao {
  @Query('SELECT * FROM `$workoutSummariesTableName` ORDER BY `speed` DESC')
  Future<List<WorkoutSummary>> findAllWorkoutSummaries();

  @Query('SELECT * FROM `$workoutSummariesTableName` WHERE `id` = :id')
  Stream<WorkoutSummary?> findWorkoutSummaryById(int id);

  @Query(
      'SELECT * FROM `$workoutSummariesTableName` WHERE `device_id` = :deviceId ORDER BY `speed` DESC')
  Future<List<WorkoutSummary>> findAllWorkoutSummariesByDevice(String deviceId);

  @Query(
      'SELECT * FROM `$workoutSummariesTableName` WHERE `device_id` = :deviceId ORDER BY `speed` DESC LIMIT :limit OFFSET :offset')
  Future<List<WorkoutSummary>> findWorkoutSummaryByDevice(String deviceId, int limit, int offset);

  @Query('SELECT * FROM `$workoutSummariesTableName` WHERE `sport` = :sport ORDER BY `speed` DESC')
  Future<List<WorkoutSummary>> findAllWorkoutSummariesBySport(String sport);

  @Query(
      'SELECT * FROM `$workoutSummariesTableName` WHERE `sport` = :sport ORDER BY `speed` DESC LIMIT :limit OFFSET :offset')
  Future<List<WorkoutSummary>> findWorkoutSummaryBySport(String sport, int limit, int offset);

  @insert
  Future<int> insertWorkoutSummary(WorkoutSummary workoutSummary);

  @update
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary);

  @delete
  Future<int> deleteWorkoutSummary(WorkoutSummary workoutSummary);
}
