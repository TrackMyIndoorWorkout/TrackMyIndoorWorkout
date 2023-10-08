import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/company_registry.dart';
import 'package:track_my_indoor_exercise/ui/models/advertisement_digest.dart';
import 'package:track_my_indoor_exercise/utils/machine_type.dart';

class FtmsTestPair {
  final List<MachineType> machineTypes;
  final bool expected;

  const FtmsTestPair({required this.machineTypes, required this.expected});
}

class CompanyTestPair {
  final int companyId;
  final bool expected;

  const CompanyTestPair({required this.companyId, required this.expected});
}

void main() {
  group('isMultiFtms works as expected', () {
    for (final testPair in [
      const FtmsTestPair(machineTypes: [MachineType.notFitnessMachine], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.indoorBike], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.treadmill], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.rower], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.crossTrainer], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.stepClimber], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.stairClimber], expected: false),
      const FtmsTestPair(machineTypes: [MachineType.multiFtms], expected: false),
      const FtmsTestPair(
          machineTypes: [MachineType.indoorBike, MachineType.treadmill, MachineType.crossTrainer],
          expected: true),
      const FtmsTestPair(
          machineTypes: [MachineType.stepClimber, MachineType.stairClimber], expected: true),
      const FtmsTestPair(machineTypes: [MachineType.rower, MachineType.treadmill], expected: true),
      const FtmsTestPair(
          machineTypes: [MachineType.notFitnessMachine, MachineType.treadmill], expected: false),
      const FtmsTestPair(
          machineTypes: [MachineType.multiFtms, MachineType.treadmill], expected: false),
    ]) {
      test("${testPair.machineTypes} -> ${testPair.expected}", () async {
        final advertisementDigest = AdvertisementDigest(
          id: "",
          serviceUuids: [],
          companyIds: [],
          manufacturers: "",
          txPower: 0,
          machineTypesByte: testPair.machineTypes.first.bit,
          machineType: testPair.machineTypes.first,
          machineTypes: testPair.machineTypes,
        );

        expect(advertisementDigest.isMultiFtms(), testPair.expected);
      });
    }
  });

  group('needsMatrixSpecialTreatment works as expected', () {
    for (final testPair in [
      const CompanyTestPair(companyId: CompanyRegistry.matrixIncKey, expected: false),
      const CompanyTestPair(companyId: CompanyRegistry.johnsonHealthTechKey, expected: true),
      const CompanyTestPair(companyId: 0, expected: false),
    ]) {
      test("${testPair.companyId} -> ${testPair.expected}", () async {
        final advertisementDigest = AdvertisementDigest(
          id: "",
          serviceUuids: [],
          companyIds: [testPair.companyId],
          manufacturers: "",
          txPower: 0,
          machineTypesByte: MachineType.treadmill.bit,
          machineType: MachineType.treadmill,
          machineTypes: [MachineType.treadmill],
        );

        expect(advertisementDigest.needsMatrixSpecialTreatment(), testPair.expected);
      });
    }
  });
}
