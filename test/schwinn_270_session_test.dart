import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/schwinn_x70.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('Schwinn 270 recording session evaluation', () {
    SchwinnX70 bike = SchwinnX70();
    bike.stopWorkout();

    final dir = Directory.current;
    final fixtureFile = File("${dir.path}/test/fixtures/schwinn_270_session.yaml");
    final yamlContent = fixtureFile.readAsStringSync();
    final fixture = loadYaml(yamlContent);

    bool first = true;
    for (final element in fixture["session"].nodes) {
      final List<int> data = element["data"]
          .nodes
          .toList()
          .map((scalar) => scalar.value as int)
          .toList(growable: false)
          .cast<int>();

      expect(bike.isDataProcessable(data), true);

      final record = bike.wrappedStubRecord(data)!;

      final expected = RecordWithSport(
        distance: first ? 0.0 : null,
        elapsed: element["elapsed"],
        calories: element["calories"],
        power: element["power"],
        speed: element["speed"],
        cadence: element["cadence"],
        heartRate: 0,
        sport: ActivityType.ride,
        elapsedMillis: element["elapsedMillis"],
      );
      expect(record.id, null);
      expect(record.id, expected.id);
      expect(record.activityId, null);
      expect(record.activityId, expected.activityId);
      expect(record.distance, expected.distance);
      expect(record.elapsed, expected.elapsed);
      expect(record.calories, expected.calories);
      expect(record.power, expected.power);
      if (record.speed == null) {
        expect(expected.speed, null);
      } else {
        expect(record.speed!, closeTo(expected.speed!, displayEps));
      }
      expect(record.cadence, expected.cadence);
      expect(record.heartRate, expected.heartRate);
      expect(record.elapsedMillis, expected.elapsedMillis);
      expect(record.pace, expected.pace);
      expect(record.strokeCount, expected.strokeCount);
      expect(record.sport, expected.sport);
      expect(record.caloriesPerHour, expected.caloriesPerHour);
      expect(record.caloriesPerMinute, expected.caloriesPerMinute);
      expect(record.elapsedMillis, expected.elapsedMillis);

      first = false;
    }
  });
}
