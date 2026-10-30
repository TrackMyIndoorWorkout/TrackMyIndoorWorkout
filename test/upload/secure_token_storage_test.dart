import 'package:flutter/services.dart';
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

  test('resolve returns registered SecureTokenStorage or registers one permanently', () {
    Get.put<SecureTokenStorage>(secureTokenStorage, permanent: true);
    expect(SecureTokenStorage.resolve(), same(secureTokenStorage));

    Get.reset();
    final created = SecureTokenStorage.resolve();
    expect(Get.isRegistered<SecureTokenStorage>(), isTrue);
    expect(SecureTokenStorage.resolve(), same(created));
  });

  test('read migrates a legacy value into secure storage and deletes the legacy key '
      'when secure storage is empty', () async {
    when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => null);
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn('legacy-access-token');
    when(() => mockSecureStorage.write(key: testKey, value: 'legacy-access-token'))
        .thenAnswer((_) async {});
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

  test('read cleans up an empty legacy string and returns null', () async {
    when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => null);
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn('');
    when(() => mockPrefService.remove(testKey)).thenAnswer((_) async => true);

    final result = await secureTokenStorage.read(testKey);

    expect(result, isNull);
    verifyNever(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    );
    verify(() => mockPrefService.remove(testKey)).called(1);
  });

  test('read returns null safely when BasePrefService is not registered', () async {
    await Get.delete<BasePrefService>(force: true);
    when(() => mockSecureStorage.read(key: testKey)).thenAnswer((_) async => null);

    final result = await secureTokenStorage.read(testKey);

    expect(result, isNull);
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

  test(
    'read recovers from PlatformException by deleting corrupted key and returning null',
    () async {
      when(
        () => mockSecureStorage.read(key: testKey),
      ).thenThrow(PlatformException(code: 'InvalidKeyException', message: 'Failed to unwrap key'));
      when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {});
      when(() => mockPrefService.get<dynamic>(testKey)).thenReturn(null);

      final result = await secureTokenStorage.read(testKey);

      expect(result, isNull);
      verify(() => mockSecureStorage.delete(key: testKey)).called(1);
    },
  );

  test('write stores the value in secure storage and skips legacy remove when absent', () async {
    when(() => mockSecureStorage.write(key: testKey, value: 'new-value')).thenAnswer((_) async {});
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn(null);

    await secureTokenStorage.write(testKey, 'new-value');

    verify(() => mockSecureStorage.write(key: testKey, value: 'new-value')).called(1);
    verify(() => mockPrefService.get<dynamic>(testKey)).called(1);
    verifyNever(() => mockPrefService.remove(any()));
  });

  test('write eagerly purges any leftover legacy plaintext entry for the same key', () async {
    when(() => mockSecureStorage.write(key: testKey, value: 'new-value')).thenAnswer((_) async {});
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn('stale-legacy-token');
    when(() => mockPrefService.remove(testKey)).thenAnswer((_) async => true);

    await secureTokenStorage.write(testKey, 'new-value');

    verify(() => mockSecureStorage.write(key: testKey, value: 'new-value')).called(1);
    verify(() => mockPrefService.remove(testKey)).called(1);
  });

  test('write resets corrupted key and retries on PlatformException', () async {
    var attempts = 0;
    when(() => mockSecureStorage.write(key: testKey, value: 'new-value')).thenAnswer((_) async {
      attempts++;
      if (attempts == 1) {
        throw PlatformException(code: 'KeyStoreException', message: 'Key invalidated');
      }
    });
    when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {});
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn(null);

    await secureTokenStorage.write(testKey, 'new-value');

    expect(attempts, 2);
    verify(() => mockSecureStorage.delete(key: testKey)).called(1);
  });

  test('delete removes the value from secure storage and purges any legacy entry', () async {
    when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {});
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn('stale-legacy-token');
    when(() => mockPrefService.remove(testKey)).thenAnswer((_) async => true);

    await secureTokenStorage.delete(testKey);

    verify(() => mockSecureStorage.delete(key: testKey)).called(1);
    verify(() => mockPrefService.remove(testKey)).called(1);
  });

  test('writeOrDelete writes non-empty values and deletes null or empty values', () async {
    when(() => mockSecureStorage.write(key: testKey, value: 'token-123')).thenAnswer((_) async {});
    when(() => mockSecureStorage.delete(key: testKey)).thenAnswer((_) async {});
    when(() => mockPrefService.get<dynamic>(testKey)).thenReturn(null);

    await secureTokenStorage.writeOrDelete(testKey, 'token-123');
    verify(() => mockSecureStorage.write(key: testKey, value: 'token-123')).called(1);

    await secureTokenStorage.writeOrDelete(testKey, '');
    await secureTokenStorage.writeOrDelete(testKey, null);
    verify(() => mockSecureStorage.delete(key: testKey)).called(2);
  });
}
