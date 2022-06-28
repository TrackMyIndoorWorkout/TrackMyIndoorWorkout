import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/metric_spec.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

void main() {
  group('getPreferencesSpecs finishes for various sports', () {
    for (final sport in allSports) {
      for (final si in [true, false]) {
        test('$sport SI $si', () async {
          await initPrefServiceForTest();

          final specList = MetricSpec.getPreferencesSpecs(si, sport);

          expect(specList.length, MetricSpec.preferencesSpecs.length);
        });
      }
    }
  });
}
