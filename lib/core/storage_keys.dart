/// Keys for the on-device key-value store (get_storage).
class StorageKeys {
  StorageKeys._();
  static const country = 'selected_country';
  static const year = 'selected_year';
  static const themeMode = 'theme_mode';
  static const onboardingSeen = 'onboarding_seen';
}

/// Tracks whether [GetStorage.init()] has completed.
/// Providers guard all reads/writes behind this flag so that tests that
/// never call init() see no file-I/O side-effects (writes are no-ops,
/// reads return null → providers fall back to their coded defaults).
bool storageReady = false;

/// Call once, immediately after [await GetStorage.init()] returns, to
/// enable real persistence in the running app (and in tests that opt in).
void markStorageReady() => storageReady = true;
