import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../providers/api_provider.dart';
import '../providers/saved_breaks_provider.dart';
import 'auth_state.dart';
import 'token_store.dart';

/// The token store. Overridden in tests with an in-memory implementation.
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

/// Holds the current auth state. Hydrates from stored tokens on startup;
/// exposes login / register / logout / deleteAccount.
class AuthController extends AsyncNotifier<AuthState> {
  ApiClient get _api => ref.read(apiClientProvider);
  TokenStore get _store => ref.read(tokenStoreProvider);

  @override
  Future<AuthState> build() async {
    String? access;
    try {
      access = await _store.readAccess();
    } catch (_) {
      // Secure storage unavailable (e.g. unit tests / no keychain) → treat as
      // logged out rather than surfacing an error.
      return const AuthState.unauthenticated();
    }
    if (access == null) return const AuthState.unauthenticated();
    try {
      // /me transparently refreshes once on a 401 via the Dio interceptor.
      final user = await _api.me();
      return AuthState.authenticated(user);
    } catch (_) {
      try {
        await _store.clear();
      } catch (_) {/* ignore */}
      return const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final tokens = await _api.login(email: email, password: password);
    await _store.write(
        access: tokens.accessToken, refresh: tokens.refreshToken);
    await ref.read(savedBreaksProvider.notifier).onLogin();
    state = AsyncData(AuthState.authenticated(tokens.user));
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final tokens = await _api.register(
        email: email, password: password, displayName: displayName);
    await _store.write(
        access: tokens.accessToken, refresh: tokens.refreshToken);
    await ref.read(savedBreaksProvider.notifier).onLogin();
    state = AsyncData(AuthState.authenticated(tokens.user));
  }

  Future<void> logout() async {
    final refresh = await _store.readRefresh();
    if (refresh != null) {
      try {
        await _api.logout(refresh);
      } catch (_) {/* best-effort */}
    }
    await _store.clear();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<void> deleteAccount() async {
    try {
      await _api.deleteAccount();
    } catch (_) {/* best-effort; tokens cleared regardless */}
    await _store.clear();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
