import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/dreeve/dreeve_service.dart';
import 'package:track_my_indoor_exercise/upload/strava/strava_service.dart';
import 'package:track_my_indoor_exercise/upload/suunto/suunto_service.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks_service.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/under_armour_service.dart';
import 'package:track_my_indoor_exercise/upload/upload_service.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('UploadService.getInstance resolution tests', () {
    test('resolves StravaService for stravaChoice and default fallback', () {
      final strava = UploadService.getInstance(stravaChoice);
      expect(strava, isA<StravaService>());

      final fallback = UploadService.getInstance("unknown_portal");
      expect(fallback, isA<StravaService>());
    });

    test('resolves SuuntoService for suuntoChoice', () {
      final suunto = UploadService.getInstance(suuntoChoice);
      expect(suunto, isA<SuuntoService>());
    });

    test('resolves UnderArmourService for underArmourChoice', () {
      final ua = UploadService.getInstance(underArmourChoice);
      expect(ua, isA<UnderArmourService>());
    });

    test('resolves TrainingPeaksService for trainingPeaksChoice', () {
      final tp = UploadService.getInstance(trainingPeaksChoice);
      expect(tp, isA<TrainingPeaksService>());
    });

    test('resolves DreeveService for dreeveChoice', () {
      final dreeve = UploadService.getInstance(dreeveChoice);
      expect(dreeve, isA<DreeveService>());
    });

    test('reuses registered instance when already put in Get', () {
      final existingDreeve = DreeveService();
      Get.put<DreeveService>(existingDreeve, permanent: true);

      final resolved = UploadService.getInstance(dreeveChoice);
      expect(identical(resolved, existingDreeve), isTrue);
    });
  });
}
