import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

ThemeMode _readThemeMode() {
  if (!storageReady) return ThemeMode.light;
  String? stored;
  try {
    stored = GetStorage().read<String>(StorageKeys.themeMode);
  } catch (_) {
    stored = null;
  }
  return ThemeMode.values.firstWhere(
    (m) => m.name == stored,
    orElse: () => ThemeMode.light,
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) {
    if (!storageReady) return; // no-op in tests that skip GetStorage.init()
    try {
      GetStorage().write(StorageKeys.themeMode, next.name);
    } catch (_) {/* silently ignored */}
  });
  return _readThemeMode();
});
