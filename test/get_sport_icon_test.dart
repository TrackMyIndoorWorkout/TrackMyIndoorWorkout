import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

class SportIconTestPair {
  final String sport;
  final IconData icon;

  const SportIconTestPair({required this.sport, required this.icon});
}

void main() {
  group('getSportIcon returns expected icon for sport', () {
    for (var sportIconPair in [
      SportIconTestPair(sport: ActivityType.ride, icon: Icons.directions_bike),
      SportIconTestPair(sport: ActivityType.run, icon: Icons.directions_run),
      SportIconTestPair(sport: ActivityType.elliptical, icon: Icons.downhill_skiing),
      SportIconTestPair(sport: ActivityType.rowing, icon: Icons.rowing),
      SportIconTestPair(sport: ActivityType.kayaking, icon: Icons.kayaking),
      SportIconTestPair(sport: ActivityType.canoeing, icon: Icons.rowing),
      SportIconTestPair(sport: ActivityType.swim, icon: Icons.waves),
      SportIconTestPair(sport: ActivityType.rockClimbing, icon: Icons.stairs),
      SportIconTestPair(sport: ActivityType.stairStepper, icon: Icons.stairs),
      SportIconTestPair(sport: ActivityType.nordicSki, icon: Icons.downhill_skiing),
      SportIconTestPair(sport: ActivityType.crossfit, icon: Icons.help),
    ]) {
      test("sport: ${sportIconPair.sport}, icon: ${sportIconPair.icon}", () async {
        expect(getSportIcon(sportIconPair.sport), sportIconPair.icon);
      });
    }
  });
}
