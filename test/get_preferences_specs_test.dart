import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/preferences_spec.dart';
import 'utils.dart';

void main() {
  group('getPreferencesSpecs finishes for various sports', () {
    for (final sport in sports) {
      for (final si in [true, false]) {
        test('$sport SI $si', () async {
          await initPrefServiceForTest();

          final specList = PreferencesSpec.getPreferencesSpecs(si, sport);

          expect(specList.length, PreferencesSpec.preferencesSpecs.length);
        });
      }
    }
  });
}
