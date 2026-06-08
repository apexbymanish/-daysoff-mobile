import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

/// Stores the access + refresh tokens. Abstracted so tests can use an
/// in-memory implementation instead of the platform keychain.
abstract class TokenStore {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> write({required String access, required String refresh});
  Future<void> clear();
}

const _kAccess = 'daysoff_access_token';
const _kRefresh = 'daysoff_refresh_token';

/// Keychain-backed on iOS/Android (and signed macOS). When the keychain is
/// unavailable — e.g. an unsigned/sandboxed local macOS dev build, which lacks
/// the Keychain Sharing entitlement — it falls back to get_storage so tokens
/// still persist for local development.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;

  @override
  Future<String?> readAccess() => _read(_kAccess);

  @override
  Future<String?> readRefresh() => _read(_kRefresh);

  Future<String?> _read(String key) async {
    try {
      final v = await _s.read(key: key);
      if (v != null) return v;
    } catch (_) {/* keychain unavailable */}
    // Keychain returned null or threw — fall back to get_storage. On platforms
    // where the keychain works this never has a value, so keychain wins.
    return _fallbackRead(key);
  }

  @override
  Future<void> write({required String access, required String refresh}) async {
    var keychainOk = false;
    try {
      await _s.write(key: _kAccess, value: access);
      await _s.write(key: _kRefresh, value: refresh);
      // Verify the write actually persisted. On an unsigned/sandboxed macOS
      // build the keychain silently no-ops (no throw), so read-back is null.
      keychainOk = (await _s.read(key: _kAccess)) == access;
    } catch (_) {
      keychainOk = false;
    }
    if (!keychainOk) {
      _fallbackWrite(_kAccess, access);
      _fallbackWrite(_kRefresh, refresh);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _s.delete(key: _kAccess);
      await _s.delete(key: _kRefresh);
    } catch (_) {/* ignore */}
    _fallbackWrite(_kAccess, null);
    _fallbackWrite(_kRefresh, null);
  }

  // ── get_storage fallback (local dev only) ─────────────────────────────────
  String? _fallbackRead(String key) {
    try {
      if (!storageReady) return null;
      return GetStorage().read<String>(key);
    } catch (_) {
      return null;
    }
  }

  void _fallbackWrite(String key, String? value) {
    try {
      if (!storageReady) return;
      if (value == null) {
        GetStorage().remove(key);
      } else {
        GetStorage().write(key, value);
      }
    } catch (_) {/* ignore */}
  }
}

/// In-memory token store for tests.
class InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> write({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}
