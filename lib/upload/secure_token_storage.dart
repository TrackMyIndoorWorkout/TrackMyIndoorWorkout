import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

/// Thin wrapper around [FlutterSecureStorage] used by the fitness portal
/// OAuth integrations (Strava, Suunto, Training Peaks, Under Armour) to
/// persist access/refresh tokens, expiry timestamps, and granted scopes.
///
/// These values used to be stored, unencrypted, in the `pref` package
/// (backed by `shared_preferences`), which also caused them to be included
/// in plaintext `preferences.json` inside Data Export archives. To avoid
/// silently logging out existing installs, [read] transparently migrates a
/// value still sitting in that legacy store the first time it is looked up,
/// and [write]/[delete] eagerly purge any remaining legacy entry for the
/// same key.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
          );

  final FlutterSecureStorage _secureStorage;

  /// Resolves the shared [SecureTokenStorage] instance from GetX DI,
  /// registering a default permanent instance if one is not registered yet.
  static SecureTokenStorage resolve() {
    return Get.isRegistered<SecureTokenStorage>()
        ? Get.find<SecureTokenStorage>()
        : Get.put<SecureTokenStorage>(SecureTokenStorage(), permanent: true);
  }

  /// Read the value stored under [key].
  ///
  /// Checks secure storage first. If a platform decryption error occurs
  /// (for example after a device transfer or Keystore invalidation), the
  /// unreadable entry is deleted so the user can cleanly re-authenticate
  /// instead of hitting unhandled [PlatformException]s.
  ///
  /// When nothing is stored in secure storage for [key], falls back to the
  /// legacy `pref`/`shared_preferences` value (if any), migrating it into
  /// secure storage and removing the legacy entry.
  Future<String?> read(String key) async {
    String? secureValue;
    try {
      secureValue = await _secureStorage.read(key: key);
    } on PlatformException catch (e) {
      debugPrint('SecureTokenStorage.read($key) failed, clearing corrupted key: $e');
      await _tryDeleteSecureKey(key);
    } catch (e) {
      debugPrint('SecureTokenStorage.read($key) unexpected error: $e');
    }

    if (secureValue != null) {
      return secureValue;
    }

    if (!Get.isRegistered<BasePrefService>()) {
      return null;
    }

    final prefService = Get.find<BasePrefService>();
    final legacyValue = prefService.get<dynamic>(key);
    if (legacyValue != null) {
      final legacyString = legacyValue.toString();
      if (legacyString.isEmpty) {
        await prefService.remove(key);
        return null;
      }

      try {
        await _secureStorage.write(key: key, value: legacyString);
        await prefService.remove(key);
      } catch (e) {
        debugPrint('SecureTokenStorage.read($key) migration write failed: $e');
      }
      return legacyString;
    }

    return null;
  }

  /// Write [value] for [key] into secure storage and purge any leftover
  /// legacy plaintext entry for [key].
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on PlatformException catch (e) {
      debugPrint('SecureTokenStorage.write($key) failed, resetting key and retrying: $e');
      await _tryDeleteSecureKey(key);
      try {
        await _secureStorage.write(key: key, value: value);
      } catch (retryError) {
        debugPrint('SecureTokenStorage.write($key) retry failed: $retryError');
      }
    }
    await _purgeLegacyKey(key);
  }

  /// Delete the value for [key] from both secure storage and any legacy
  /// plaintext preference entry.
  Future<void> delete(String key) async {
    await _tryDeleteSecureKey(key);
    await _purgeLegacyKey(key);
  }

  /// Writes [value] under [key] when non-null and non-empty; otherwise
  /// deletes [key] from secure storage and legacy preferences.
  Future<void> writeOrDelete(String key, String? value) {
    if (value == null || value.isEmpty) {
      return delete(key);
    }
    return write(key, value);
  }

  Future<void> _tryDeleteSecureKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('SecureTokenStorage.delete($key) failed: $e');
    }
  }

  Future<void> _purgeLegacyKey(String key) async {
    if (!Get.isRegistered<BasePrefService>()) {
      return;
    }

    final prefService = Get.find<BasePrefService>();
    if (prefService.get<dynamic>(key) != null) {
      await prefService.remove(key);
    }
  }
}
