/// REST paths exposed by daysoff-api.
///
/// The base URL is injected via --dart-define=API_BASE_URL=...
/// at build time. See [ApiClient].
class Endpoints {
  Endpoints._();

  static const healthz = '/v1/healthz';
  static const countries = '/v1/countries';
  static const holidays = '/v1/holidays';
  static const compare = '/v1/compare';
  static const sandwiches = '/v1/sandwiches';
  static const plan = '/v1/plan';

  // Accounts + sync
  static const authRegister = '/v1/auth/register';
  static const authLogin = '/v1/auth/login';
  static const authRefresh = '/v1/auth/refresh';
  static const authLogout = '/v1/auth/logout';
  static const me = '/v1/me';
  static const savedBreaks = '/v1/saved-breaks';
  static const savedBreaksSync = '/v1/saved-breaks/sync';
}
