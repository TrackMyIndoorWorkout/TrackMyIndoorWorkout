import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/machine_type.dart';

class MachineSportTestPair {
  final MachineType machineType;
  final String sport;

  const MachineSportTestPair({required this.machineType, required this.sport});
}

class MachineSportIconPair {
  final MachineType machineType;
  final IconData icon;

  const MachineSportIconPair({required this.machineType, required this.icon});
}

class MachineFtmsTestPair {
  final MachineType machineType;
  final bool expected;

  const MachineFtmsTestPair({required this.machineType, required this.expected});
}

void main() {
  group('machineType infers sport as expected', () {
    for (final testPair in [
      const MachineSportTestPair(machineType: MachineType.indoorBike, sport: ActivityType.ride),
      const MachineSportTestPair(machineType: MachineType.treadmill, sport: ActivityType.run),
      const MachineSportTestPair(machineType: MachineType.rower, sport: ActivityType.kayaking),
      const MachineSportTestPair(
          machineType: MachineType.crossTrainer, sport: ActivityType.elliptical),
      const MachineSportTestPair(machineType: MachineType.stepClimber, sport: ActivityType.run),
      const MachineSportTestPair(machineType: MachineType.stairClimber, sport: ActivityType.run),
      const MachineSportTestPair(machineType: MachineType.heartRateMonitor, sport: ""),
      const MachineSportTestPair(machineType: MachineType.multiFtms, sport: ""),
    ]) {
      test("${testPair.machineType} -> ${testPair.sport}", () async {
        expect(testPair.machineType.sport, testPair.sport);
      });
    }
  });

  group('machineType infers icon as expected', () {
    for (final testPair in [
      const MachineSportIconPair(machineType: MachineType.indoorBike, icon: Icons.directions_bike),
      const MachineSportIconPair(machineType: MachineType.treadmill, icon: Icons.directions_run),
      const MachineSportIconPair(machineType: MachineType.rower, icon: Icons.kayaking),
      const MachineSportIconPair(
          machineType: MachineType.crossTrainer, icon: Icons.downhill_skiing),
      const MachineSportIconPair(machineType: MachineType.stepClimber, icon: Icons.stairs),
      const MachineSportIconPair(machineType: MachineType.stairClimber, icon: Icons.stairs),
      const MachineSportIconPair(machineType: MachineType.heartRateMonitor, icon: Icons.favorite),
      const MachineSportIconPair(machineType: MachineType.multiFtms, icon: Icons.help),
    ]) {
      test("${testPair.machineType} -> ${testPair.icon}", () async {
        expect(testPair.machineType.icon, testPair.icon);
      });
    }
  });

  group('machineType isFtms classifies as expected', () {
    for (final testPair in [
      const MachineFtmsTestPair(machineType: MachineType.notFitnessMachine, expected: false),
      const MachineFtmsTestPair(machineType: MachineType.indoorBike, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.treadmill, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.rower, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.crossTrainer, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.stepClimber, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.stairClimber, expected: true),
      const MachineFtmsTestPair(machineType: MachineType.heartRateMonitor, expected: false),
      const MachineFtmsTestPair(machineType: MachineType.multiFtms, expected: false),
    ]) {
      test("${testPair.machineType} -> ${testPair.expected}", () async {
        expect(testPair.machineType.isFtms, testPair.expected);
      });
    }
  });
}
