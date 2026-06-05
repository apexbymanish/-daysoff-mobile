import 'package:get_storage/get_storage.dart';

import 'storage_keys.dart';

/// Reads a value from get_storage, tolerating an uninitialized store.
/// Returns null when [storageReady] is false so callers use coded defaults.
T? storageRead<T>(String key) {
  if (!storageReady) return null;
  try {
    return GetStorage().read<T>(key);
  } catch (_) {
    return null;
  }
}

/// Writes to get_storage only when [storageReady] is true (a no-op in tests
/// that never call GetStorage.init() — no async flush, no file I/O).
void storageWrite(String key, Object value) {
  if (!storageReady) return;
  try {
    GetStorage().write(key, value);
  } catch (_) {/* silently ignored */}
}
