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
}
