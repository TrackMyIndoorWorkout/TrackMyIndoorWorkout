import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/schwinn_x70.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'package:yaml/yaml.dart';

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  test('Schwinn 270 recording session evaluation', () {
    SchwinnX70 bike = SchwinnX70();
    bike.stopWorkout();

    final dir = Directory.current;
    final fixtureFile = File("${dir.path}/test/fixtures/schwinn_270_session.yaml");
    final yamlContent = fixtureFile.readAsStringSync();
    final fixture = loadYaml(yamlContent);
    // String content = "session:\n";

    for (final element in fixture["session"].nodes) {
      final List<int> data = element["data"]
          .nodes
          .toList()
          .map((scalar) => scalar.value as int)
          .toList(growable: false)
          .cast<int>();

      expect(bike.isDataProcessable(data), true);

      final record = bike.wrappedStubRecord(data)!;
      // content += "  - element:\n";
      // content += '    timeStamp: "${element["timeStamp"]}"\n';
      // content += "    data: ${data.toString()}\n";
      // content += "    elapsed: ${record.elapsed}\n";
      // content += "    calories: ${record.calories}\n";
      // content += "    power: ${record.power}\n";
      // content += "    speed: ${record.speed?.toStringAsFixed(4)}\n";
      // content += "    cadence: ${record.cadence}\n";
      // content += "    elapsedMillis: ${record.elapsedMillis}\n";

      final expected = RecordWithSport(
        distance: null,
        elapsed: element["elapsed"],
        calories: element["calories"],
        power: element["power"],
        speed: element["speed"],
        cadence: element["cadence"],
        heartRate: null,
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
    }

    // File f = File('results.yaml');
    // f.writeAsStringSync(content);
  });
}
