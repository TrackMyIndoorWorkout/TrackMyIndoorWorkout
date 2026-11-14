import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_sport.dart';
import 'package:track_my_indoor_exercise/export/virtual_sport.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  group('VirtualSport mapping and helper tests', () {
    test('hasVirtualCounterpart returns true only for supported sports', () {
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.ride), isTrue);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.run), isTrue);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.rowing), isTrue);

      expect(VirtualSport.hasVirtualCounterpart(ActivityType.swim), isFalse);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.elliptical), isFalse);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.nordicSki), isFalse);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.canoeing), isFalse);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.kayaking), isFalse);
      expect(VirtualSport.hasVirtualCounterpart(ActivityType.workout), isFalse);
    });

    test('getVirtualSport returns correct virtual sport type', () {
      expect(VirtualSport.getVirtualSport(ActivityType.ride), ActivityType.virtualRide);
      expect(VirtualSport.getVirtualSport(ActivityType.run), ActivityType.virtualRun);
      expect(VirtualSport.getVirtualSport(ActivityType.rowing), ActivityType.virtualRow);
      expect(VirtualSport.getVirtualSport(ActivityType.swim), ActivityType.swim);
    });

    test(
      'resolveSport resolves to virtual sport only when flag is true and counterpart exists',
      () {
        expect(VirtualSport.resolveSport(ActivityType.ride, true), ActivityType.virtualRide);
        expect(VirtualSport.resolveSport(ActivityType.run, true), ActivityType.virtualRun);
        expect(VirtualSport.resolveSport(ActivityType.rowing, true), ActivityType.virtualRow);

        expect(VirtualSport.resolveSport(ActivityType.ride, false), ActivityType.ride);
        expect(VirtualSport.resolveSport(ActivityType.run, false), ActivityType.run);
        expect(VirtualSport.resolveSport(ActivityType.rowing, false), ActivityType.rowing);

        expect(VirtualSport.resolveSport(ActivityType.swim, true), ActivityType.swim);
        expect(VirtualSport.resolveSport(ActivityType.elliptical, true), ActivityType.elliptical);
      },
    );

    test('FIT sub_sport 58 (virtual_activity) is encoded for virtual sports', () {
      final virtualRideFit = toFitSport(ActivityType.virtualRide);
      expect(virtualRideFit.item1, 2); // cycling
      expect(virtualRideFit.item2, 58); // virtual_activity

      final virtualRunFit = toFitSport(ActivityType.virtualRun);
      expect(virtualRunFit.item1, 1); // running
      expect(virtualRunFit.item2, 58); // virtual_activity

      final virtualRowFit = toFitSport(ActivityType.virtualRow);
      expect(virtualRowFit.item1, 15); // rowing
      expect(virtualRowFit.item2, 58); // virtual_activity
    });
  });
}
