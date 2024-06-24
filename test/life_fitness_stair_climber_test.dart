import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/life_fitness_stair_climber_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Life Fitness Stair CLimber Device constructor tests', () async {
    final sClimber = LifeFitnessStairClimberDescriptor();

    expect(sClimber.sport, ActivityType.rockClimbing);
    expect(sClimber.fourCC, genericFTMSStairClimberFourCC);
    expect(sClimber.isMultiSport, false);
  });

  test('Stair Climber Device interprets Life Fitness Stair Climber flags properly 1', () async {
    final sClimber = LifeFitnessStairClimberDescriptor();
    const lsb = 0x3e;
    const msb = 0x01;
    const flag = maxUint8 * msb + lsb;
    sClimber.initFlag();
    sClimber.stopWorkout();
    sClimber.processFlag(flag, 19);

    expect(sClimber.speedMetric, null);
    expect(sClimber.cadenceMetric, isNotNull);
    expect(sClimber.distanceMetric, isNotNull);
    expect(sClimber.powerMetric, null);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.timeMetric, isNotNull);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.caloriesPerHourMetric, isNotNull);
    expect(sClimber.caloriesPerMinuteMetric, isNotNull);
    expect(sClimber.heartRateByteIndex, null);
    expect(sClimber.strokeCountMetric, isNotNull);
  });

  test('Stair Climber Device interprets Life Fitness Stair Climber flags properly 2', () async {
    final sClimber = LifeFitnessStairClimberDescriptor();
    const lsb = 0x7e;
    const msb = 0x01;
    const flag = maxUint8 * msb + lsb;
    sClimber.initFlag();
    sClimber.stopWorkout();
    sClimber.processFlag(flag, 20);

    expect(sClimber.speedMetric, null);
    expect(sClimber.cadenceMetric, isNotNull);
    expect(sClimber.distanceMetric, isNotNull);
    expect(sClimber.powerMetric, null);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.timeMetric, isNotNull);
    expect(sClimber.caloriesMetric, isNotNull);
    expect(sClimber.caloriesPerHourMetric, isNotNull);
    expect(sClimber.caloriesPerMinuteMetric, isNotNull);
    expect(sClimber.heartRateByteIndex, isNotNull);
    expect(sClimber.strokeCountMetric, isNotNull);
  });

  group('Stair Climber Device interprets Life Fitness Stair Climber data properly', () {
    for (final testPair in [
      TestPair(
        data: [62, 1, 1, 0, 60, 0, 35, 0, 4, 0, 22, 0, 5, 0, 255, 255, 255, 41, 0],
        record: RecordWithSport(
          distance: 4.0,
          elapsed: 41,
          calories: 5,
          power: null,
          speed: null,
          cadence: 60,
          heartRate: null,
          sport: ActivityType.rockClimbing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 35,
        ),
      ),
      TestPair(
        data: [126, 1, 3, 0, 36, 0, 44, 0, 11, 0, 54, 0, 12, 0, 255, 255, 255, 91, 74, 0],
        record: RecordWithSport(
          distance: 11.0,
          elapsed: 74,
          calories: 12,
          power: null,
          speed: null,
          cadence: 36,
          heartRate: 91,
          sport: ActivityType.rockClimbing,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          strokeCount: 44,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<int>(0, (a, b) => a + b);
      test("$sum ${testPair.data.length}", () async {
        final sClimber = LifeFitnessStairClimberDescriptor();
        sClimber.initFlag();
        expect(sClimber.isDataProcessable(testPair.data), true);
        sClimber.stopWorkout();

        final record = sClimber.wrappedStubRecord(testPair.data)!;

        expect(record.id, Isar.autoIncrement);
        expect(record.id, testPair.record.id);
        expect(record.activityId, Isar.minId);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.sport, testPair.record.sport);
      });
    }
  });
}
