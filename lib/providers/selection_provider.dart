import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage_io.dart';
import '../core/storage_keys.dart';

final selectedCountryProvider = StateProvider<String>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.country, next));
  return storageRead<String>(StorageKeys.country) ?? 'KR';
});

final selectedYearProvider = StateProvider<int>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.year, next));
  return storageRead<int>(StorageKeys.year) ?? 2026;
});
