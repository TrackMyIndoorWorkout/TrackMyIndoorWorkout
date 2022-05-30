import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/devices/gatt_constants.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'infer_sport_from_characteristics_id_test.mocks.dart';

class TestPair {
  final String characteristicsId;
  final List<String> sports;

  const TestPair({required this.characteristicsId, required this.sports});
}

@GenerateMocks([BluetoothDevice])
void main() {
  group('DeviceBase infers sport as expected from characteristics ID', () {
    for (final testPair in [
      const TestPair(characteristicsId: treadmillUuid, sports: [ActivityType.run]),
      const TestPair(characteristicsId: precorMeasurementUuid, sports: [ActivityType.ride]),
      const TestPair(characteristicsId: indoorBikeUuid, sports: [ActivityType.ride]),
      const TestPair(characteristicsId: rowerDeviceUuid, sports: waterSports),
      const TestPair(characteristicsId: crossTrainerUuid, sports: [ActivityType.elliptical]),
      const TestPair(characteristicsId: heartRateMeasurementUuid, sports: [])
    ]) {
      test("${testPair.characteristicsId} -> ${testPair.sports}", () async {
        await initPrefServiceForTest();
        final hrm = HeartRateMonitor(MockBluetoothDevice());
        hrm.characteristicsId = testPair.characteristicsId;

        expect(hrm.inferSportsFromCharacteristicsIds(), testPair.sports);
      });
    }
  });
}
