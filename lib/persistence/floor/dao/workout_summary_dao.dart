import 'package:floor/floor.dart';
import '../models/workout_summary.dart';

@dao
abstract class WorkoutSummaryDao {
  @Query('SELECT * FROM `$workoutSummariesTableName`')
  Future<List<WorkoutSummary>> findAllWorkoutSummaries();

  @Query('SELECT COUNT(`id`) FROM `$workoutSummariesTableName`')
  Future<int?> getWorkoutSummaryCount();

  @update
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary);
}
