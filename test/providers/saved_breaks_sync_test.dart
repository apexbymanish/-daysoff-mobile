import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/auth_tokens.dart';
import 'package:daysoff_mobile/api/models/auth_user.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/auth/auth_controller.dart';
import 'package:daysoff_mobile/auth/token_store.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';

class _FakeApi extends ApiClient {
  _FakeApi() : super(dio: null);

  final user = const AuthUser(id: 'u1', email: 'a@b.com');
  final List<List<SavedBreak>> pushes = [];
  List<SavedBreak> serverSet = [];

  @override
  Future<AuthTokens> login(
          {required String email, required String password}) async =>
      AuthTokens(
          accessToken: 'a', refreshToken: 'r', expiresIn: 1800, user: user);

  @override
  Future<List<SavedBreak>> syncSavedBreaks(List<SavedBreak> breaks) async {
    pushes.add(breaks);
    return serverSet;
  }
}

SavedBreak _b(String id) => SavedBreak(
    id: id, label: 'L', start: DateTime(2026, 9, 22),
    end: DateTime(2026, 9, 28), ptoCost: 2, kind: 'buffet');

ProviderContainer _c(_FakeApi api, TokenStore store) {
  final c = ProviderContainer(overrides: [
    apiClientProvider.overrideWithValue(api),
    tokenStoreProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('add() while authenticated pushes the break with a timestamp', () async {
    final api = _FakeApi();
    final c = _c(api, InMemoryTokenStore());
    await c.read(authControllerProvider.future);
    await c.read(authControllerProvider.notifier)
        .login(email: 'a@b.com', password: 'hunter2pw'); // authenticate
    api.pushes.clear(); // ignore the onLogin sync

    c.read(savedBreaksProvider.notifier).add(_b('x1'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(api.pushes, isNotEmpty);
    final pushed = api.pushes.expand((e) => e).toList();
    expect(pushed.any((b) => b.id == 'x1' && b.updatedAt != null), isTrue);
  });

  test('add() while logged out does NOT push', () async {
    final api = _FakeApi();
    final c = _c(api, InMemoryTokenStore());
    await c.read(authControllerProvider.future); // unauthenticated

    c.read(savedBreaksProvider.notifier).add(_b('x1'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(api.pushes, isEmpty);
    expect(c.read(savedBreaksProvider).map((b) => b.id), contains('x1'));
  });

  test('onLogin adopts the server authoritative set', () async {
    final api = _FakeApi()..serverSet = [_b('server1'), _b('server2')];
    final c = _c(api, InMemoryTokenStore());
    await c.read(authControllerProvider.future);

    await c.read(authControllerProvider.notifier)
        .login(email: 'a@b.com', password: 'hunter2pw');

    final ids = c.read(savedBreaksProvider).map((b) => b.id).toList();
    expect(ids, containsAll(['server1', 'server2']));
  });
}
