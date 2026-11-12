import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/upload/secure_token_storage.dart';
import 'package:track_my_indoor_exercise/upload/strava/constants.dart';
import 'package:track_my_indoor_exercise/upload/strava/strava.dart';
import 'package:track_my_indoor_exercise/upload/suunto/constants.dart';
import 'package:track_my_indoor_exercise/upload/suunto/suunto.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/constants.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/constants.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/under_armour.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late SecureTokenStorage tokenStorage;
  late Map<String, String> storageMap;

  setUp(() {
    Get.reset();
    mockSecureStorage = MockFlutterSecureStorage();
    storageMap = {};

    when(() => mockSecureStorage.read(key: any(named: 'key'))).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return storageMap[key];
    });

    when(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String?;
      if (value != null) {
        storageMap[key] = value;
      } else {
        storageMap.remove(key);
      }
    });

    when(() => mockSecureStorage.delete(key: any(named: 'key'))).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      storageMap.remove(key);
    });

    tokenStorage = SecureTokenStorage(secureStorage: mockSecureStorage);
    Get.put<SecureTokenStorage>(tokenStorage, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  group('OAuth hasValidToken tests across portals', () {
    test('Strava hasValidToken returns false when no token stored', () async {
      final strava = Strava("client_id", "secret");
      expect(await strava.hasValidToken(), isFalse);
    });

    test('Strava hasValidToken returns true when token is unexpired', () async {
      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await tokenStorage.write(stravaAccessTokenTag, "valid_access_token");
      await tokenStorage.write(stravaExpiresAtTag, futureEpoch.toString());

      final strava = Strava("client_id", "secret");
      expect(await strava.hasValidToken(), isTrue);
    });

    test('Strava hasValidToken returns false when expired and no refresh token', () async {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
      await tokenStorage.write(stravaAccessTokenTag, "expired_access_token");
      await tokenStorage.write(stravaExpiresAtTag, pastEpoch.toString());

      final strava = Strava("client_id", "secret");
      expect(await strava.hasValidToken(), isFalse);
    });

    test('Strava hasValidToken considers token within 60s clock skew expired', () async {
      // 30 seconds left before expiration (within 60s skew window)
      final nearEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 30;
      await tokenStorage.write(stravaAccessTokenTag, "near_expiry_token");
      await tokenStorage.write(stravaExpiresAtTag, nearEpoch.toString());

      final strava = Strava("client_id", "secret");
      // Since no refresh token is provided, it attempts refresh and fails -> false
      expect(await strava.hasValidToken(), isFalse);
    });

    test('Suunto hasValidToken returns false when empty and true when valid', () async {
      final suunto = Suunto("client_id", "secret", "sub_key");
      expect(await suunto.hasValidToken(), isFalse);

      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await tokenStorage.write(suuntoAccessTokenTag, "valid_suunto_token");
      await tokenStorage.write(suuntoExpiresAtTag, futureEpoch.toString());

      expect(await suunto.hasValidToken(), isTrue);
    });

    test('UnderArmour hasValidToken returns false when empty and true when valid', () async {
      final ua = UnderArmour("client_id", "secret");
      expect(await ua.hasValidToken(), isFalse);

      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await tokenStorage.write(underArmourAccessTokenTag, "valid_ua_token");
      await tokenStorage.write(underArmourExpiresAtTag, futureEpoch.toString());

      expect(await ua.hasValidToken(), isTrue);
    });

    test('TrainingPeaks hasValidToken returns false when empty and true when valid', () async {
      final tp = TrainingPeaks("client_id", "secret");
      expect(await tp.hasValidToken(), isFalse);

      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await tokenStorage.write(trainingPeaksAccessTokenTag, "valid_tp_token");
      await tokenStorage.write(trainingPeaksExpiresAtTag, futureEpoch.toString());

      expect(await tp.hasValidToken(), isTrue);
    });
  });
}
