import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

/// The user's chosen app locale. null = follow the system locale.
/// Persisted as the language code (e.g. "ko"); null clears it.
final localeProvider = StateProvider<Locale?>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) {
    if (!storageReady) return;
    if (next == null) {
      GetStorage().remove(StorageKeys.language);
    } else {
      GetStorage().write(StorageKeys.language, next.languageCode);
    }
  });
  if (!storageReady) return null;
  final code = GetStorage().read<String>(StorageKeys.language);
  return (code == null || code.isEmpty) ? null : Locale(code);
});

/// Languages offered in the picker (code → native display name).
const supportedLanguages = <String, String>{
  'en': 'English',
  'ko': '한국어',
  'es': 'Español',
  'fr': 'Français',
  'zh': '中文',
  'vi': 'Tiếng Việt',
  'id': 'Bahasa Indonesia',
  'pt': 'Português',
};
