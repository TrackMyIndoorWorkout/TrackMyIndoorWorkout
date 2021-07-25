import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/ui/models/advertisement_digest.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/machine_type.dart';

class TestPair {
  final MachineType machineType;
  final String sport;

  TestPair({required this.machineType, required this.sport});
}

void main() {
  group('AdvertisementDigest infers sport as expected from MachineType', () {
    [
      TestPair(machineType: MachineType.IndoorBike, sport: ActivityType.Ride),
      TestPair(machineType: MachineType.Treadmill, sport: ActivityType.Run),
      TestPair(machineType: MachineType.Rower, sport: ActivityType.Kayaking),
      TestPair(machineType: MachineType.CrossTrainer, sport: ActivityType.Ride),
    ].forEach((testPair) {
      test("${testPair.machineType} -> ${testPair.sport}", () async {
        final advertisementDigest = AdvertisementDigest(
          id: "",
          serviceUuids: [],
          manufacturer: "",
          txPower: 0,
          machineType: testPair.machineType,
        );

        expect(advertisementDigest.fitnessMachineSport(), testPair.sport);
      });
    });
  });
}
