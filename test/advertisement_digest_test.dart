import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/company_registry.dart';
import 'package:track_my_indoor_exercise/ui/models/advertisement_digest.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/machine_type.dart';

class MachineTestPair {
  final MachineType machineType;
  final String sport;

  const MachineTestPair({required this.machineType, required this.sport});
}

class CompanyTestPair {
  final int companyId;
  final bool expected;

  const CompanyTestPair({required this.companyId, required this.expected});
}

void main() {
  group('AdvertisementDigest infers sport as expected from MachineType', () {
    for (final testPair in [
      const MachineTestPair(machineType: MachineType.indoorBike, sport: ActivityType.ride),
      const MachineTestPair(machineType: MachineType.treadmill, sport: ActivityType.run),
      const MachineTestPair(machineType: MachineType.rower, sport: ActivityType.kayaking),
      const MachineTestPair(machineType: MachineType.crossTrainer, sport: ActivityType.elliptical),
      const MachineTestPair(machineType: MachineType.stepClimber, sport: ActivityType.ride),
    ]) {
      test("${testPair.machineType} -> ${testPair.sport}", () async {
        final advertisementDigest = AdvertisementDigest(
          id: "",
          serviceUuids: [],
          companyIds: [],
          manufacturer: "",
          txPower: 0,
          machineType: testPair.machineType,
        );

        expect(advertisementDigest.fitnessMachineSport(), testPair.sport);
      });
    }
  });

  group('needsMatrixSpecialTreatment works as expected', () {
    for (final testPair in [
      const CompanyTestPair(companyId: CompanyRegistry.matrixIncKey, expected: true),
      const CompanyTestPair(companyId: CompanyRegistry.johnsonHealthTechKey, expected: true),
      const CompanyTestPair(companyId: 0, expected: false),
    ]) {
      test("${testPair.companyId} -> ${testPair.expected}", () async {
        final advertisementDigest = AdvertisementDigest(
          id: "",
          serviceUuids: [],
          companyIds: [testPair.companyId],
          manufacturer: "",
          txPower: 0,
          machineType: MachineType.treadmill,
        );

        expect(advertisementDigest.needsMatrixSpecialTreatment(), testPair.expected);
      });
    }
  });
}
