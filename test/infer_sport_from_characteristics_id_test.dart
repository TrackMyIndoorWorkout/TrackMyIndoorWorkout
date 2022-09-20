import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/devices/gatt_constants.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'infer_sport_from_characteristics_id_test.mocks.dart';

class TestPair {
  final String characteristicId;
  final List<String> sports;

  const TestPair({required this.characteristicId, required this.sports});
}

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
void main() {
  group('DeviceBase infers sport as expected from characteristics ID', () {
    for (final testPair in [
      const TestPair(characteristicId: treadmillUuid, sports: [ActivityType.run]),
      const TestPair(characteristicId: precorMeasurementUuid, sports: [ActivityType.ride]),
      const TestPair(characteristicId: indoorBikeUuid, sports: [ActivityType.ride]),
      const TestPair(characteristicId: rowerDeviceUuid, sports: waterSports),
      const TestPair(characteristicId: crossTrainerUuid, sports: [ActivityType.elliptical]),
      const TestPair(characteristicId: heartRateMeasurementUuid, sports: [])
    ]) {
      test("${testPair.characteristicId} -> ${testPair.sports}", () async {
        await initPrefServiceForTest();
        final hrm = HeartRateMonitor(MockBluetoothDevice());
        hrm.characteristicId = testPair.characteristicId;

        expect(hrm.inferSportsFromCharacteristicIds(), testPair.sports);
      });
    }
  });
}
