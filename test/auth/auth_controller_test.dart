import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/auth_tokens.dart';
import 'package:daysoff_mobile/api/models/auth_user.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/auth/auth_controller.dart';
import 'package:daysoff_mobile/auth/auth_state.dart';
import 'package:daysoff_mobile/auth/token_store.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';

class _FakeApi extends ApiClient {
  _FakeApi() : super(dio: null);

  final user = const AuthUser(id: 'u1', email: 'a@b.com', displayName: 'A');
  bool meThrows = false;
  int syncCalls = 0;

  AuthTokens _tokens() => AuthTokens(
      accessToken: 'acc', refreshToken: 'ref', expiresIn: 1800, user: user);

  @override
  Future<AuthTokens> login(
          {required String email, required String password}) async =>
      _tokens();

  @override
  Future<AuthTokens> register(
          {required String email,
          required String password,
          String? displayName}) async =>
      _tokens();

  @override
  Future<AuthUser> me() async {
    if (meThrows) throw Exception('401');
    return user;
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<List<SavedBreak>> syncSavedBreaks(List<SavedBreak> breaks) async {
    syncCalls++;
    return [];
  }
}

ProviderContainer _container(_FakeApi api, TokenStore store) {
  final c = ProviderContainer(overrides: [
    apiClientProvider.overrideWithValue(api),
    tokenStoreProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('no stored token → unauthenticated', () async {
    final c = _container(_FakeApi(), InMemoryTokenStore());
    final state = await c.read(authControllerProvider.future);
    expect(state.status, AuthStatus.unauthenticated);
  });

  test('login stores tokens, authenticates, and syncs saved breaks', () async {
    final api = _FakeApi();
    final store = InMemoryTokenStore();
    final c = _container(api, store);
    await c.read(authControllerProvider.future);

    await c.read(authControllerProvider.notifier)
        .login(email: 'a@b.com', password: 'hunter2pw');

    final state = c.read(authControllerProvider).requireValue;
    expect(state.isAuthenticated, isTrue);
    expect(state.user!.email, 'a@b.com');
    expect(await store.readAccess(), 'acc');
    expect(await store.readRefresh(), 'ref');
    expect(api.syncCalls, greaterThanOrEqualTo(1)); // onLogin merge
  });

  test('logout clears tokens and unauthenticates', () async {
    final store = InMemoryTokenStore();
    final c = _container(_FakeApi(), store);
    await c.read(authControllerProvider.future);
    await c.read(authControllerProvider.notifier)
        .login(email: 'a@b.com', password: 'hunter2pw');

    await c.read(authControllerProvider.notifier).logout();

    expect(c.read(authControllerProvider).requireValue.isAuthenticated, isFalse);
    expect(await store.readAccess(), isNull);
  });

  test('stored token → /me hydrates authenticated on startup', () async {
    final store = InMemoryTokenStore();
    await store.write(access: 'acc', refresh: 'ref');
    final c = _container(_FakeApi(), store);
    final state = await c.read(authControllerProvider.future);
    expect(state.isAuthenticated, isTrue);
  });

  test('stored token but /me fails → unauthenticated + cleared', () async {
    final api = _FakeApi()..meThrows = true;
    final store = InMemoryTokenStore();
    await store.write(access: 'bad', refresh: 'ref');
    final c = _container(api, store);
    final state = await c.read(authControllerProvider.future);
    expect(state.status, AuthStatus.unauthenticated);
    expect(await store.readAccess(), isNull);
  });
}
