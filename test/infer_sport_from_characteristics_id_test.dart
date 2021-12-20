import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/devices/gatt_constants.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'infer_sport_from_characteristics_id_test.mocks.dart';

import 'utils.dart';

class TestPair {
  final String characteristicsId;
  final String? sport;

  const TestPair({required this.characteristicsId, required this.sport});
}

@GenerateMocks([BluetoothDevice])
void main() {
  group('DeviceBase infers sport as expected from characteristics ID', () {
    for (final testPair in [
      const TestPair(characteristicsId: treadmillUuid, sport: ActivityType.Run),
      const TestPair(characteristicsId: precorMeasurementUuid, sport: ActivityType.Ride),
      const TestPair(characteristicsId: indoorBikeUuid, sport: ActivityType.Ride),
      const TestPair(characteristicsId: rowerDeviceUuid, sport: ActivityType.Rowing),
      const TestPair(characteristicsId: crossTrainerUuid, sport: ActivityType.Elliptical),
      const TestPair(characteristicsId: heartRateMeasurementUuid, sport: null)
    ]) {
      test("${testPair.characteristicsId} -> ${testPair.sport}", () async {
        await initPrefServiceForTest();
        final hrm = HeartRateMonitor(MockBluetoothDevice());
        hrm.characteristicsId = testPair.characteristicsId;

        expect(hrm.inferSportFromCharacteristicsId(), testPair.sport);
      });
    }
  });
}
