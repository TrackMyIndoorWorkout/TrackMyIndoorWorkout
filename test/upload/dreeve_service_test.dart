import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/dreeve/constants.dart';
import 'package:track_my_indoor_exercise/upload/dreeve/dreeve_service.dart';
import 'package:track_my_indoor_exercise/upload/secure_token_storage.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

Activity createTestActivity({bool dreeveUploaded = false, String dreeveUploadIdentifier = ""}) {
  return Activity(
    deviceName: "Test Bike",
    deviceId: "00:11:22:33:44:55",
    hrmId: "",
    start: DateTime(2026, 11, 10, 10, 0, 0),
    fourCC: "IC4_",
    sport: "Ride",
    powerFactor: 1.0,
    calorieFactor: 1.0,
    hrCalorieFactor: 1.0,
    hrmCalorieFactor: 1.0,
    hrBasedCalories: false,
    timeZone: "America/Los_Angeles",
    dreeveUploaded: dreeveUploaded,
    dreeveUploadIdentifier: dreeveUploadIdentifier,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse("https://app.dreeve.org"));
    registerFallbackValue(FakeBaseRequest());
  });

  group('DreeveService URL normalization', () {
    test('normalizeUrl handles protocol prefixes and trailing slashes', () {
      expect(DreeveService.normalizeUrl("http://localhost:8080/"), equals("http://localhost:8080"));
      expect(
        DreeveService.normalizeUrl("https://app.dreeve.org///"),
        equals("https://app.dreeve.org"),
      );
      expect(
        DreeveService.normalizeUrl("dreeve.example.com"),
        equals("https://dreeve.example.com"),
      );
      expect(
        DreeveService.normalizeUrl("  https://my-dreeve.local:8443/  "),
        equals("https://my-dreeve.local:8443"),
      );
    });
  });

  group('DreeveService testConnection', () {
    late MockHttpClient mockClient;
    late DreeveService dreeveService;

    setUp(() {
      mockClient = MockHttpClient();
      dreeveService = DreeveService(client: mockClient);
    });

    test('returns true on HTTP 200 with canUpload=true', () async {
      when(
        () => mockClient.get(
          Uri.parse("https://app.dreeve.org/api/v1/status"),
          headers: any(named: "headers"),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({"app": "dreeve", "version": "v5.2.3", "canUpload": true}),
          200,
        ),
      );

      final result = await dreeveService.testConnection("https://app.dreeve.org", "drv_valid_key");
      expect(result, isTrue);
    });

    test('returns false on HTTP 200 with canUpload=false', () async {
      when(
        () => mockClient.get(
          Uri.parse("https://app.dreeve.org/api/v1/status"),
          headers: any(named: "headers"),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({"app": "dreeve", "version": "v5.2.3", "canUpload": false}),
          200,
        ),
      );

      final result = await dreeveService.testConnection(
        "https://app.dreeve.org",
        "drv_read_only_key",
      );
      expect(result, isFalse);
    });

    test('returns false on HTTP 401 unauthorized', () async {
      when(
        () => mockClient.get(
          Uri.parse("https://app.dreeve.org/api/v1/status"),
          headers: any(named: "headers"),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({"error": "invalid_token", "message": "Invalid key"}), 401),
      );

      final result = await dreeveService.testConnection("https://app.dreeve.org", "drv_bad_key");
      expect(result, isFalse);
    });

    test('returns false on network exception', () async {
      when(
        () => mockClient.get(
          Uri.parse("https://app.dreeve.org/api/v1/status"),
          headers: any(named: "headers"),
        ),
      ).thenThrow(http.ClientException("Connection refused"));

      final result = await dreeveService.testConnection("https://app.dreeve.org", "drv_key");
      expect(result, isFalse);
    });

    test('returns false if apiKey is empty', () async {
      final result = await dreeveService.testConnection("https://app.dreeve.org", "   ");
      expect(result, isFalse);
      verifyZeroInteractions(mockClient);
    });
  });

  group('Dreeve Activity and Model tests', () {
    test('Activity reflects Dreeve uploaded state', () {
      final activity = createTestActivity();
      expect(activity.isUploaded(dreeveChoice), isFalse);
      expect(activity.isUploaded(anyChoice), isFalse);

      activity.markDreeveUploaded("act_123");
      expect(activity.isUploaded(dreeveChoice), isTrue);
      expect(activity.isUploaded(anyChoice), isTrue);
      expect(activity.dreeveUploadIdentifier, equals("act_123"));
      expect(activity.isSpecificWorkoutUrl(dreeveChoice), isTrue);
      expect(activity.workoutUrl(dreeveChoice), equals("https://app.dreeve.org/activity/act_123"));
    });

    test('Activity workoutUrl falls back to server URL when upload identifier is empty', () {
      final activity = createTestActivity(dreeveUploaded: true, dreeveUploadIdentifier: "");
      expect(activity.isSpecificWorkoutUrl(dreeveChoice), isFalse);
      expect(activity.workoutUrl(dreeveChoice), equals("https://app.dreeve.org"));
    });
  });

  group('DreeveService authentication and token storage', () {
    late MockSecureTokenStorage mockStorage;
    late DreeveService dreeveService;

    setUp(() {
      mockStorage = MockSecureTokenStorage();
      Get.reset();
      Get.put<SecureTokenStorage>(mockStorage, permanent: true);
      dreeveService = DreeveService();
    });

    tearDown(() {
      Get.reset();
    });

    test('hasValidToken returns true when API key is non-empty', () async {
      when(() => mockStorage.read(dreeveApiKeyTag)).thenAnswer((_) async => "drv_secret123");
      expect(await dreeveService.hasValidToken(), isTrue);
    });

    test('hasValidToken returns false when API key is null or empty', () async {
      when(() => mockStorage.read(dreeveApiKeyTag)).thenAnswer((_) async => null);
      expect(await dreeveService.hasValidToken(), isFalse);

      when(() => mockStorage.read(dreeveApiKeyTag)).thenAnswer((_) async => "");
      expect(await dreeveService.hasValidToken(), isFalse);
    });

    test('logout deletes API key from SecureTokenStorage', () async {
      when(() => mockStorage.delete(dreeveApiKeyTag)).thenAnswer((_) async {});
      final code = await dreeveService.logout();
      expect(code, equals(200));
      verify(() => mockStorage.delete(dreeveApiKeyTag)).called(1);
    });
  });
}
