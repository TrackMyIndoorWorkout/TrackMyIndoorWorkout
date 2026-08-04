import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

/// Thin wrapper around [FlutterSecureStorage] used by the fitness portal
/// OAuth integrations (Strava, Suunto, Training Peaks, Under Armour) to
/// persist access/refresh tokens, expiry timestamps, and granted scopes.
///
/// These values used to be stored, unencrypted, in the `pref` package
/// (backed by `shared_preferences`). To avoid silently logging out
/// existing installs when this class is introduced, [read] transparently
/// migrates a value still sitting in that legacy store the first time it
/// is looked up: if nothing has been written to secure storage yet for a
/// given key, but the old key still holds a value, that value is copied
/// into secure storage and removed from the legacy store before being
/// returned to the caller. Callers do not need to know this is happening.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  /// Read the value stored under [key].
  ///
  /// Checks secure storage first. If it is empty, falls back to the
  /// legacy `pref`/`shared_preferences` value (if any), migrating it into
  /// secure storage and deleting the legacy entry. Returns `null` if no
  /// value is found in either store.
  Future<String?> read(String key) async {
    final secureValue = await _secureStorage.read(key: key);
    if (secureValue != null && secureValue.isNotEmpty) {
      return secureValue;
    }

    final prefService = Get.find<BasePrefService>();
    final legacyValue = prefService.get<dynamic>(key);
    if (legacyValue != null && legacyValue.toString().isNotEmpty) {
      final migratedValue = legacyValue.toString();
      await _secureStorage.write(key: key, value: migratedValue);
      await prefService.remove(key);
      return migratedValue;
    }

    return null;
  }

  /// Write [value] for [key] into secure storage.
  Future<void> write(String key, String value) => _secureStorage.write(key: key, value: value);

  /// Delete the value for [key] from secure storage.
  Future<void> delete(String key) => _secureStorage.delete(key: key);
}
