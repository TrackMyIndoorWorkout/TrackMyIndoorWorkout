import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/upload/secure_token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockBasePrefService mockPrefService;
  late SecureTokenStorage secureTokenStorage;

  const testKey = 'testTokenTag';

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockPrefService = MockBasePrefService();
    Get.put<BasePrefService>(mockPrefService, permanent: true);
    secureTokenStorage = SecureTokenStorage(secureStorage: mockSecureStorage);
  });

  tearDown(() {
    Get.reset();
  });

  test('read migrates a legacy value into secure storage and deletes the legacy key '
      'when secure storage is empty', () async {
    when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => null);
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn('legacy-access-token');
    when(
      () => mockSecureStorage.write(key: testKey, value: 'legacy-access-token'),
    ).thenAnswer((_) async {});
    when(() => mockPrefService.remove(testKey)).thenAnswer((_) async => true);

    final result = await secureTokenStorage.read(testKey);

    expect(result, 'legacy-access-token');
    verify(() => mockSecureStorage.write(key: testKey, value: 'legacy-access-token')).called(1);
    verify(() => mockPrefService.remove(testKey)).called(1);
  });

  test('read returns null when neither secure storage nor the legacy store has a value', () async {
    when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => null);
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn(null);

    final result = await secureTokenStorage.read(testKey);

    expect(result, isNull);
    verifyNever(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    );
    verifyNever(() => mockPrefService.remove(any()));
  });

  test(
    'read returns the secure storage value directly without touching the legacy store',
    () async {
      when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => 'secure-value');

      final result = await secureTokenStorage.read(testKey);

      expect(result, 'secure-value');
      verifyNever(() => mockPrefService.get<dynamic>(any()));
      verifyNever(() => mockPrefService.remove(any()));
    },
  );

  test('write stores the value in secure storage only', () async {
    when(() => mockSecureStorage.write(key: testKey, value: 'new-value')).thenAnswer((_) async {});

    await secureTokenStorage.write(testKey, 'new-value');

    verify(() => mockSecureStorage.write(key: testKey, value: 'new-value')).called(1);
    verifyNever(() => mockPrefService.get<dynamic>(any()));
    verifyZeroInteractions(mockPrefService);
  });

  test('delete removes the value from secure storage', () async {
    when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {});

    await secureTokenStorage.delete(testKey);

    verify(() => mockSecureStorage.delete(key: testKey)).called(1);
  });
}
