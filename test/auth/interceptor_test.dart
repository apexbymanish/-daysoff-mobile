import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/auth/token_store.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: ['application/json'],
};

/// Fake transport: /me returns 401 until the request carries the retry marker,
/// /auth/refresh issues fresh tokens.
class _FakeAdapter implements HttpClientAdapter {
  int refreshCalls = 0;
  int meCalls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.contains('/v1/auth/refresh')) {
      refreshCalls++;
      return ResponseBody.fromString(
        jsonEncode({
          'access_token': 'newacc',
          'refresh_token': 'newref',
          'token_type': 'bearer',
          'expires_in': 1800,
          'user': {'id': 'u1', 'email': 'a@b.com'},
        }),
        200,
        headers: _jsonHeaders,
      );
    }
    if (options.path.contains('/v1/me')) {
      meCalls++;
      if (options.extra['__retried'] == true) {
        return ResponseBody.fromString(
          jsonEncode({'id': 'u1', 'email': 'a@b.com'}),
          200,
          headers: _jsonHeaders,
        );
      }
      return ResponseBody.fromString(
          jsonEncode({'detail': 'expired'}), 401, headers: _jsonHeaders);
    }
    return ResponseBody.fromString('{}', 200, headers: _jsonHeaders);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('401 triggers a single refresh + retry, persists new tokens', () async {
    final adapter = _FakeAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final store = InMemoryTokenStore();
    await store.write(access: 'oldacc', refresh: 'oldref');

    final api = ApiClient(dio: dio, tokenStore: store);
    final user = await api.me(); // first 401 → refresh → retry → 200

    expect(user.email, 'a@b.com');
    expect(adapter.refreshCalls, 1);
    expect(adapter.meCalls, 2); // original + one retry
    expect(await store.readAccess(), 'newacc');
    expect(await store.readRefresh(), 'newref');
  });
}
