import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/graph_view_duration.dart';

void main() {
  group('Graph View Duration Constants', () {
    test('graphViewDurationDefault is within valid range', () {
      expect(graphViewDurationDefault, greaterThanOrEqualTo(graphViewDurationMin));
      expect(graphViewDurationDefault, lessThanOrEqualTo(graphViewDurationMax));
    });

    test('graphViewDurationMin is less than graphViewDurationMax', () {
      expect(graphViewDurationMin, lessThan(graphViewDurationMax));
    });

    test('graphViewDurationDivisions is positive', () {
      expect(graphViewDurationDivisions, greaterThan(0));
    });

    test('graphViewDurationTag is non-empty', () {
      expect(graphViewDurationTag, isNotEmpty);
    });
  });
}
