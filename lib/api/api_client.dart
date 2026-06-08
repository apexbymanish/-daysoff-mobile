import 'package:dio/dio.dart';

import '../auth/token_store.dart';
import 'endpoints.dart';
import 'models/auth_tokens.dart';
import 'models/auth_user.dart';
import 'models/countries_response.dart';
import 'models/holidays_response.dart';
import 'models/plan_response.dart';
import 'models/saved_break.dart';
import 'models/sandwiches_response.dart';

/// Thin dio wrapper for the daysoff-api.
///
/// Base URL comes from --dart-define=API_BASE_URL=http://host:port
/// and defaults to localhost:8080 when not provided.
///
/// When a [TokenStore] is supplied, an interceptor attaches the access token
/// to every request and transparently refreshes it once on a 401.
class ApiClient {
  ApiClient({Dio? dio, TokenStore? tokenStore})
      : _tokenStore = tokenStore,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://127.0.0.1:8080',
                ),
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            ) {
    final store = _tokenStore;
    if (store != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await store.readAccess();
          if (access != null && options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final req = e.requestOptions;
          final is401 = e.response?.statusCode == 401;
          final isAuthCall = req.path.startsWith('/v1/auth/');
          final alreadyRetried = req.extra['__retried'] == true;
          if (!is401 || isAuthCall || alreadyRetried) {
            return handler.next(e);
          }
          final refreshed = await _tryRefresh();
          if (!refreshed) {
            await store.clear();
            return handler.next(e);
          }
          // Retry the original request once with the new access token.
          final access = await store.readAccess();
          req.extra['__retried'] = true;
          req.headers['Authorization'] = 'Bearer $access';
          try {
            final resp = await _dio.fetch<dynamic>(req);
            return handler.resolve(resp);
          } on DioException catch (err) {
            return handler.next(err);
          }
        },
      ));
    }
  }

  final Dio _dio;
  final TokenStore? _tokenStore;

  /// Refresh the access token using a bare Dio (no interceptor) to avoid
  /// recursion. Returns true on success (tokens persisted).
  Future<bool> _tryRefresh() async {
    final store = _tokenStore;
    final refresh = await store?.readRefresh();
    if (store == null || refresh == null) return false;
    try {
      final bare = Dio(BaseOptions(baseUrl: _dio.options.baseUrl))
        ..httpClientAdapter = _dio.httpClientAdapter;
      final r = await bare.post<Map<String, dynamic>>(
        Endpoints.authRefresh,
        data: {'refresh_token': refresh},
      );
      final tokens = AuthTokens.fromJson(r.data!);
      await store.write(
          access: tokens.accessToken, refresh: tokens.refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.holidays,
      queryParameters: {
        'country': country,
        'year': year,
        if (fromToday) 'from_today': true,
      },
    );
    return HolidaysResponse.fromJson(response.data!);
  }

  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    int? month,
    List<String>? workweek,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.plan,
      queryParameters: {
        'country': country,
        'year': year,
        'budget': budget,
        'min_length': minLength,
        'max_length': maxLength,
        'month': ?month,
        if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(','),
      },
    );
    return PlanResponse.fromJson(response.data!);
  }

  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
    int? budget,
    int? minLength,
    int? maxLength,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.sandwiches,
      queryParameters: {
        'country': country,
        'year': year,
        if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(','),
        'budget': ?budget,
        'min_length': ?minLength,
        'max_length': ?maxLength,
      },
    );
    return SandwichesResponse.fromJson(response.data!);
  }

  Future<CountriesResponse> getCountries() async {
    final response = await _dio.get<Map<String, dynamic>>(Endpoints.countries);
    return CountriesResponse.fromJson(response.data!);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthTokens> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      Endpoints.authRegister,
      data: {
        'email': email,
        'password': password,
        'display_name': ?displayName,
      },
    );
    return AuthTokens.fromJson(r.data!);
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      Endpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(r.data!);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(Endpoints.authLogout,
        data: {'refresh_token': refreshToken});
  }

  Future<AuthUser> me() async {
    final r = await _dio.get<Map<String, dynamic>>(Endpoints.me);
    return AuthUser.fromJson(r.data!);
  }

  Future<void> deleteAccount() async {
    await _dio.delete<void>(Endpoints.me);
  }

  // ── Saved-breaks sync ───────────────────────────────────────────────────────

  Future<List<SavedBreak>> getSavedBreaks() async {
    final r = await _dio.get<Map<String, dynamic>>(Endpoints.savedBreaks);
    return _parseBreaks(r.data!);
  }

  /// Push the local set; server merges (last-write-wins) and returns the
  /// authoritative non-deleted set.
  Future<List<SavedBreak>> syncSavedBreaks(List<SavedBreak> breaks) async {
    final r = await _dio.post<Map<String, dynamic>>(
      Endpoints.savedBreaksSync,
      data: {'breaks': breaks.map(savedBreakToApi).toList()},
    );
    return _parseBreaks(r.data!);
  }

  List<SavedBreak> _parseBreaks(Map<String, dynamic> data) =>
      (data['breaks'] as List)
          .map((e) => savedBreakFromApi(e as Map<String, dynamic>))
          .toList();
}

// ── Saved-break <-> API DTO mappers ───────────────────────────────────────────
// Kept separate from SavedBreak.toJson (which is the local-storage shape) so the
// API's snake_case + date-only contract stays explicit.

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

Map<String, dynamic> savedBreakToApi(SavedBreak b) => {
      'id': b.id,
      'label': b.label,
      'start': _ymd(b.start),
      'end': _ymd(b.end),
      'pto_cost': b.ptoCost,
      'kind': b.kind,
      'updated_at': (b.updatedAt ?? DateTime.now().toUtc()).toIso8601String(),
      'deleted_at': b.deletedAt?.toIso8601String(),
    };

SavedBreak savedBreakFromApi(Map<String, dynamic> m) => SavedBreak(
      id: m['id'] as String,
      label: m['label'] as String,
      start: DateTime.parse(m['start'] as String),
      end: DateTime.parse(m['end'] as String),
      ptoCost: m['pto_cost'] as int,
      kind: m['kind'] as String,
      updatedAt:
          m['updated_at'] != null ? DateTime.parse(m['updated_at'] as String) : null,
      deletedAt:
          m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
    );
