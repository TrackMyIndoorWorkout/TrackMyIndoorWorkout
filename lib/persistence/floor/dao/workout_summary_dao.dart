import 'package:floor/floor.dart';
import '../models/workout_summary.dart';

@dao
abstract class WorkoutSummaryDao {
  @Query('SELECT * FROM `$workoutSummariesTableName`')
  Future<List<WorkoutSummary>> findAllWorkoutSummaries();

  @update
  Future<int> updateWorkoutSummary(WorkoutSummary workoutSummary);
}
