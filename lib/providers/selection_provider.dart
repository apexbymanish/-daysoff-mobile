import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

/// Reads a value from get_storage, tolerating an uninitialized store.
/// Returns null when [storageReady] is false so providers use coded defaults.
T? _read<T>(String key) {
  if (!storageReady) return null;
  try {
    return GetStorage().read<T>(key);
  } catch (_) {
    return null;
  }
}

/// Writes to get_storage only when [storageReady] is true (no-op in tests
/// that never call GetStorage.init() — no async flush, no file I/O).
void _write(String key, Object value) {
  if (!storageReady) return;
  try {
    GetStorage().write(key, value);
  } catch (_) {/* silently ignored */}
}

final selectedCountryProvider = StateProvider<String>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => _write(StorageKeys.country, next));
  return _read<String>(StorageKeys.country) ?? 'KR';
});

final selectedYearProvider = StateProvider<int>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => _write(StorageKeys.year, next));
  return _read<int>(StorageKeys.year) ?? 2026;
});
