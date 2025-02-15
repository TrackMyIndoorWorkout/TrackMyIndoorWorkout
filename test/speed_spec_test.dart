import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/speed_spec.dart';
import 'package:track_my_indoor_exercise/preferences/sport_spec.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

final slowSpeedDefaults = {
  ActivityType.ride: 1.0,
  ActivityType.run: 0.5,
  SportSpec.paddleSport: 0.2,
  ActivityType.swim: 0.1,
  ActivityType.elliptical: 0.2,
  ActivityType.stairStepper: 0.1,
  ActivityType.rockClimbing: 0.1,
};

final pacerSpeedDefaults = {
  ActivityType.ride: 40.0,
  ActivityType.run: 14.85,
  SportSpec.paddleSport: 10.65,
  ActivityType.swim: 3.43,
  ActivityType.elliptical: 10.65,
  ActivityType.stairStepper: 3.43,
  ActivityType.rockClimbing: 3.43,
};

final speedSport2Sport = {
  ActivityType.ride: ActivityType.ride,
  ActivityType.run: ActivityType.run,
  SportSpec.paddleSport: SportSpec.paddleSport,
  ActivityType.swim: ActivityType.swim,
  ActivityType.elliptical: ActivityType.elliptical,
  ActivityType.stairStepper: ActivityType.swim,
  ActivityType.rockClimbing: ActivityType.swim,
};

void main() {
  group('slowSpeedDefaults returns expected slow speed', () {
    for (var speedEntry in SpeedSpec.slowSpeedDefaults.entries) {
      test("sport: ${speedEntry.key}, slow speed: ${speedEntry.value}", () async {
        expect(SpeedSpec.slowSpeedDefaults[speedEntry.key], slowSpeedDefaults[speedEntry.key]);
      });
    }
  });

  group('pacerSpeedDefaults returns expected pacer speed', () {
    for (var speedEntry in SpeedSpec.pacerSpeedDefaults.entries) {
      test("sport: ${speedEntry.key}, pacer speed: ${speedEntry.value}", () async {
        expect(SpeedSpec.pacerSpeedDefaults[speedEntry.key], pacerSpeedDefaults[speedEntry.key]);
      });
    }
  });

  group('slowSpeeds and pacerSpeeds returns expected speed for sport', () {
    for (var sportEntry in speedSport2Sport.entries) {
      final sportTo = speedSport2Sport[sportEntry.value];
      test(
        "sportFrom: ${sportEntry.key}, sportTo1: ${sportEntry.value}, sportTo2 $sportTo",
        () async {
          expect(SpeedSpec.slowSpeeds[sportEntry.key], slowSpeedDefaults[sportTo]);
          expect(SpeedSpec.pacerSpeeds[sportEntry.key], pacerSpeedDefaults[sportTo]);
        },
      );
    }
  });
}
