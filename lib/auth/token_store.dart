import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the access + refresh tokens. Abstracted so tests can use an
/// in-memory implementation instead of the platform keychain.
abstract class TokenStore {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> write({required String access, required String refresh});
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;
  static const _kAccess = 'daysoff_access_token';
  static const _kRefresh = 'daysoff_refresh_token';

  @override
  Future<String?> readAccess() => _s.read(key: _kAccess);

  @override
  Future<String?> readRefresh() => _s.read(key: _kRefresh);

  @override
  Future<void> write({required String access, required String refresh}) async {
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
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
