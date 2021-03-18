import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:preferences/preference_service.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'utils.dart';
import 'fitness_equipment_process_record_test.mocks.dart';

@GenerateMocks([BluetoothDevice])
void main() {
  group('processRecord recognizes total calorie counting capability', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 500, rnd).forEach((calorie) {
      test('$calorie', () async {
        await PrefService.init(prefix: 'pref_');
        final equipment =
            FitnessEquipment(descriptor: deviceMap["SIC4"], device: MockBluetoothDevice());
        final stub = Record(calories: calorie);

        equipment.processRecord(stub);

        expect(equipment.hasTotalCalorieCounting, true);
      });
    });
  });
}
