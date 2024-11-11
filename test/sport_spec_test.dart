import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/sport_spec.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class Sport2SportTestPair {
  final String sportFrom;
  final String sportTo;

  const Sport2SportTestPair({required this.sportFrom, required this.sportTo});
}

void main() {
  group('sport2Sport returns expected sport for sport', () {
    for (var sport2SportPair in [
      Sport2SportTestPair(sportFrom: ActivityType.ride, sportTo: ActivityType.ride),
      Sport2SportTestPair(sportFrom: ActivityType.run, sportTo: ActivityType.run),
      Sport2SportTestPair(sportFrom: ActivityType.elliptical, sportTo: ActivityType.elliptical),
      Sport2SportTestPair(sportFrom: ActivityType.rowing, sportTo: SportSpec.paddleSport),
      Sport2SportTestPair(sportFrom: ActivityType.kayaking, sportTo: SportSpec.paddleSport),
      Sport2SportTestPair(sportFrom: ActivityType.canoeing, sportTo: SportSpec.paddleSport),
      Sport2SportTestPair(sportFrom: ActivityType.swim, sportTo: ActivityType.swim),
      Sport2SportTestPair(sportFrom: ActivityType.rockClimbing, sportTo: ActivityType.swim),
      Sport2SportTestPair(sportFrom: ActivityType.stairStepper, sportTo: ActivityType.swim),
      Sport2SportTestPair(sportFrom: ActivityType.nordicSki, sportTo: SportSpec.paddleSport),
      Sport2SportTestPair(sportFrom: ActivityType.crossfit, sportTo: ActivityType.crossfit),
    ]) {
      test("sportFrom: ${sport2SportPair.sportFrom}, sportTo: ${sport2SportPair.sportTo}",
          () async {
        expect(SportSpec.sport2Sport(sport2SportPair.sportFrom), sport2SportPair.sportTo);
      });
    }
  });
}
