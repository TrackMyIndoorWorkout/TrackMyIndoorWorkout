import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/track/constants.dart';
import 'package:track_my_indoor_exercise/track/track_kind.dart';
import 'package:track_my_indoor_exercise/track/track_manager.dart';

void main() {
  group("track length factors are nominal", () {
    final trackManager = TrackManager();
    for (final timeZoneTracks in trackManager.trackMaps.entries) {
      final timeZone = timeZoneTracks.key;
      for (final track in timeZoneTracks.value.values) {
        test("$timeZone ${track.kind} ${track.lengthFactor}", () async {
          final expectedLengthFactor = track.kind == TrackKind.forWater
              ? fiveHundredMTrackLengthFactor
              : fourHundredMTrackLengthFactor;
          expect(track.lengthFactor, expectedLengthFactor);
        });
      }
    }
  });
}
